------------------------------------- Enemy Assets and Other Variables -------------------------------------------------------------
enemy = {}
local enemies = {}
local spawnTimer = 0
local maxEnemies = 8
local spawnRate = 4 -- seconds
local enemySprites = {
    love.graphics.newImage("assets/Associates1.png"),
    love.graphics.newImage("assets/Associates2.png"),
    love.graphics.newImage("assets/Associates3.png"),
    love.graphics.newImage("assets/Associates4.png")
}
local enemyGunSprite = love.graphics.newImage("assets/Revolver.png")
local enemyBulletSprite = love.graphics.newImage("assets/EnemyBullet.png")

---------------------------------- Enemy Creation/Spawning ---------------------------------------------------------------------------
function enemy:spawn()
    if #enemies >= maxEnemies then
        return
    end
    local x, y
    local side = math.random(4) -- Randomly choose a side to spawn from outside the screen

    if side == 1 then
        -- Spawn above the screen
        x = math.random(0, love.graphics.getWidth())
        y = -50
    elseif side == 2 then
        -- Spawn below the screen
        x = math.random(0, love.graphics.getWidth())
        y = love.graphics.getHeight() + 50
    elseif side == 3 then
        -- Spawn to the left of the screen
        x = -50
        y = math.random(0, love.graphics.getHeight())
    elseif side == 4 then
        -- Spawn to the right of the screen
        x = love.graphics.getWidth() + 50
        y = math.random(0, love.graphics.getHeight())
    end


    ------------------------------------------------------------ Add the enemy to the game
    table.insert(enemies, {
        x = x, y = y, 
        speed = 180, -- Increased speed
        sprite = enemySprites[math.random(#enemySprites)],
        gunSprite = enemyGunSprite,
        angle = 0, -- Ensure angle is initialized
        
        health = 3,
        shootingTimer = 0,
        bulletsFired = 0,
        reloading = false,
        behavior = math.random() < 0.5 and "aggressive" or "defensive", -- Randomized behavior

        waddleTimer = 0,
        waddleDirection = 1,
        waddleSpeed = 10, -- Adjusted to match player waddle
        waddleAmount = 0.05 -- Waddle magnitude
    })
end
-------------------------------------------- Enemy Updates on Mechanics ------------------------------------------------------------------------
function enemy:update(dt)
    spawnTimer = spawnTimer + dt
    if spawnTimer >= spawnRate then
        if #enemies > 5 then
            enemy:spawn()
        elseif #enemies < 4 then 
            enemy:spawn()
            enemy:spawn()
        end
        spawnTimer = 0
    end

    for i, e in ipairs(enemies) do
        local dx, dy = player.x - e.x, player.y - e.y
        local distance = math.sqrt(dx^2 + dy^2)
        local targetDistance = e.behavior == "aggressive" and 200 or 300

        ------------------------------------------------------------ Maintain a set distance from the player
        if distance < targetDistance - 20 then
            e.x = e.x - (dx / distance) * e.speed * dt
            e.y = e.y - (dy / distance) * e.speed * dt
        elseif distance > targetDistance + 20 then
            e.x = e.x + (dx / distance) * e.speed * dt
            e.y = e.y + (dy / distance) * e.speed * dt
        end
        ------------------------------------------------------------ Enemy dodging behavior
        if math.abs(player.angle - e.angle) < 0.3 then
            local dodgeDir = math.random(0, 1) == 0 and -1 or 1
            e.x = e.x + dodgeDir * e.speed * dt * 1.5
        end

        ------------------------------------------------------------ Avoid clustering with other enemies
        for j, other in ipairs(enemies) do
            if i ~= j then
                local diffX, diffY = e.x - other.x, e.y - other.y
                local dist = math.sqrt(diffX^2 + diffY^2)
                if dist < 200 then
                    e.x = e.x + (diffX / dist) * e.speed * dt * 3
                    e.y = e.y + (diffY / dist) * e.speed * dt * 3
                end
            end
        end

        ------------------------------------------------------------ Enemy aiming
        e.angle = math.atan2(dy, dx) + math.rad(math.random(-8, 8))

        ------------------------------------------------------------ Waddle effect
        e.waddleTimer = e.waddleTimer + dt * e.waddleSpeed
        if e.waddleTimer >= 1 then
            e.waddleTimer = 0
            e.waddleDirection = -e.waddleDirection -- Swap tilt direction
        end

        ------------------------------------------------------------ Tactical reloading movement
        if e.reloading then
            e.x = e.x - (dx / distance) * e.speed * dt * 1.5
            e.y = e.y - (dy / distance) * e.speed * dt * 1.5
        end

        ------------------------------------------------------------ Shooting logic
        if not e.reloading then
            e.shootingTimer = e.shootingTimer + dt
            if e.shootingTimer >= 2 then
                enemy:shoot(e)
                e.bulletsFired = e.bulletsFired + 1
                e.shootingTimer = 0
            end
            if e.bulletsFired >= 6 then
                e.reloading = true
                e.bulletsFired = 0
                e.shootingTimer = -0.8
            end
        else
            e.shootingTimer = e.shootingTimer + dt
            if e.shootingTimer >= 0 then
                e.reloading = false
            end
        end

        ------------------------------------------------------------ Remove if dead
        if e.health <= 0 then
            table.remove(enemies, i)
        end
    end
end



---------------------------------------- Enemy shooting function ---------------------------------------------------------------------------
function enemy:shoot(e)
    local bulletSpeed = 250
    table.insert(enemy.bullets, {
        x = e.x + math.cos(e.angle) * 20,
        y = e.y + math.sin(e.angle) * 20,
        dx = math.cos(e.angle) * bulletSpeed,
        dy = math.sin(e.angle) * bulletSpeed,
        sprite = enemyBulletSprite
    })
end

enemy.bullets = {}

----------------------------------------- Updates Enemy Bullets --------------------------------------------------------------------------
function enemy:updateBullets(dt)
    for i, b in ipairs(self.bullets) do
        b.x = b.x + b.dx * dt
        b.y = b.y + b.dy * dt
        
        -- Remove bullets outside the screen
        if b.x < -10 or b.x > love.graphics.getWidth() + 10 or b.y < -10 or b.y > love.graphics.getHeight() + 10 then
            table.remove(self.bullets, i)
        end
    end
end

----------------------------------------- Draw enemies and bullets ------------------------------------------------------------------------
function enemy:draw()
    for _, e in ipairs(enemies) do
        love.graphics.draw(e.sprite, e.x, e.y, e.waddleDirection * e.waddleAmount, 0.2, 0.2, e.sprite:getWidth()/2, e.sprite:getHeight()/2)
        love.graphics.draw(e.gunSprite, e.x, e.y, e.angle, 0.1, 0.1, e.gunSprite:getWidth()/2, e.gunSprite:getHeight()/2)
    end
    for _, b in ipairs(self.bullets) do
        love.graphics.draw(b.sprite, b.x, b.y, 0, 0.3, 0.3, b.sprite:getWidth()/2, b.sprite:getHeight()/2)
    end
end

return enemy
