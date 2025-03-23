hurtbox = require("hurtbox")
hitbox = require("hitbox")
waves = require("waves")
------------------------------------- Enemy Assets and Other Variables -------------------------------------------------------------
enemy = {}
local enemies = {}
local spawnTimer = 0
local maxEnemies = 20
local spawnRate = 4 -- Seconds
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
        y = -70
    elseif side == 2 then
        -- Spawn below the screen
        x = math.random(0, love.graphics.getWidth())
        y = love.graphics.getHeight() + 70
    elseif side == 3 then
        -- Spawn to the left of the screen
        x = -70
        y = math.random(0, love.graphics.getHeight())
    elseif side == 4 then
        -- Spawn to the right of the screen
        x = love.graphics.getWidth() + 70
        y = math.random(0, love.graphics.getHeight())
    end

    local chosenSprite = enemySprites[math.random(#enemySprites)]
    ------------------------------------------------------------ Add the enemy to the game ------------------------------------------------------------ 
    table.insert(enemies, {
        x = x, y = y, 
        speed = 250, -- Increased speed
        sprite = chosenSprite,
        gunSprite = enemyGunSprite,
        angle = 0, -- Ensure angle is initialized
        
        health = 2,
        shootingTimer = 0,
        bulletsFired = 0,
        reloading = false,
        behavior = math.random() < 0.5 and "aggressive" or "defensive", -- Randomized behavior

        waddleTimer = 0,
        waddleDirection = 1,
        waddleSpeed = 10, -- Adjusted to match player waddle
        waddleAmount = 0.05, -- Waddle magnitude

        hurtbox = HurtBox.new(x, y,chosenSprite:getWidth()/6,chosenSprite:getHeight()/6),

        knockbackX = 0,
        knockbackY = 0,
        knockbackTimer = 0

    })
end

-------------------------------------------- Enemy Updates on Mechanics
function enemy:update(dt)
------------------------------------------------------------ Avoidance Zone Logic (Circle in Mid) ------------------------------------------------------------ 
    -- Avoidance Zone Variables
local avoidanceActive = false
local avoidanceTimer = 0
local avoidanceDuration = 2 -- Duration before toggling (Timer for On and Off basically)

local function avoidanceZone(e, dt)
    local centerX, centerY = love.graphics.getWidth() / 2, love.graphics.getHeight() / 2
    local avoidRadius = 1000 -- Size of the avoidance area

    -- Toggle the avoidance zone every few seconds
    avoidanceTimer = avoidanceTimer + dt
    if avoidanceTimer >= avoidanceDuration then
        avoidanceActive = not avoidanceActive -- Toggle active/inactive
        avoidanceTimer = 0
    end

    -- If the avoidance zone is active, push enemies away
    if avoidanceActive then
        local dx, dy = e.x - centerX, e.y - centerY
        local dist = math.sqrt(dx^2 + dy^2)

        if dist < avoidRadius then
            -- Move enemy away from the center
            e.x = e.x + (dx / dist) * e.speed * dt * 2
            e.y = e.y + (dy / dist) * e.speed * dt * 2
        end
    end
end

for i, e in ipairs(enemies) do
    avoidanceZone(e, dt) -- Call the function for each enemy
end

------------------------------------------------------------ Enemy Spawning Logic ------------------------------------------------------------ 
    spawnTimer = spawnTimer + dt
    if spawnTimer >= spawnRate then
        if #enemies > 5 then
            enemy:spawn()
        elseif #enemies < 10 then 
            enemy:spawn()
            enemy:spawn()
        end
        if #enemies < 0 then 
            enemy:spawn()
            enemy:spawn()
        end
        spawnTimer = 0
    end
------------------------------------------------------------ Distance Variables for Enemy AI ------------------------------------------------------------ 
    for i, e in ipairs(enemies) do
        local dx, dy = player.x - e.x, player.y - e.y
        local distance = math.sqrt(dx^2 + dy^2)
        local targetDistance = e.behavior == "aggressive" and 200 or 300
------------------------------------------------------------ AI Moves enemies to Edges or Center ------------------------------------------------------------ 
        if not e.moveType then
            e.moveType = math.random() < 0.5 and "edges" or "center"
            e.switchTimer = math.random(2, 4) -- Switch every x, y seconds
        end
------------------------------------------------------------ Hurtbox follows Enemy ---------------------------------------------------------------------- 
    e.hurtbox:update(e.x - 15,e.y - 50)

        -- Countdown for switching movement type
        e.switchTimer = e.switchTimer - dt
        if e.switchTimer <= 0 then
            e.moveType = (e.moveType == "edges") and "center" or "edges"
            e.switchTimer = math.random(4, 7) -- Reset timer
        end

        -- Movement logic
        if e.moveType == "edges" then
            -- Move along the edges (random horizontal/vertical shifting)
            if e.x < 150 then
                e.x = e.x + e.speed * dt
            elseif e.x > love.graphics.getWidth() - 150 then
                e.x = e.x - e.speed * dt
            end
            if e.y < 150 then
                e.y = e.y + e.speed * dt
            elseif e.y > love.graphics.getHeight() - 150 then
                e.y = e.y - e.speed * dt
            end
        else
            -- Move around the center area
            local targetX = love.graphics.getWidth() / 2 + math.random(-200, 200)
            local targetY = love.graphics.getHeight() / 2 + math.random(-150, 150)
            local dx, dy = targetX - e.x, targetY - e.y
            local dist = math.sqrt(dx^2 + dy^2)
            if dist > 10 then -- Prevent jittering near target
                e.x = e.x + (dx / dist) * e.speed * 0.5 * dt
                e.y = e.y + (dy / dist) * e.speed * 0.5 * dt
            end
        end

------------------------------------------------------------ Avoid Enemy Gathering/Overlapping ------------------------------------------------------------ 
        for j, other in ipairs(enemies) do
            if i ~= j then
                local diffX, diffY = e.x - other.x, e.y - other.y
                local dist = math.sqrt(diffX^2 + diffY^2)
                local minDistance = math.random(170, 220) -- Randomize required distance
                if dist < minDistance then
                    local moveAway = ((minDistance - dist) / minDistance) * e.speed * dt * 2
                    e.x = e.x + (diffX / dist) * moveAway
                    e.y = e.y + (diffY / dist) * moveAway
                end
            end
        end

------------------------------------ Player Avoidance Logic (Enemy Avoid Player if near)------------------------------------------------------------ 
        local diffX, diffY = e.x - player.x, e.y - player.y
        local playerDist = math.sqrt(diffX^2 + diffY^2)

        if playerDist > 0 and playerDist < 350 then  -- Avoid player if too close
            local moveAway = ((350 - playerDist) / 350) * e.speed * dt * 3  -- Increased force
            e.x = e.x + (diffX / playerDist) * moveAway
            e.y = e.y + (diffY / playerDist) * moveAway
        end


--------------------------------------------------- Enemy Aiming ------------------------------------------------------------ 
        local dx, dy = player.x - e.x, player.y - e.y
        local targetAngle = math.atan2(dy, dx) + math.rad(math.random(-10, 10)) -- Smaller randomness for stability
        e.angle = e.angle + (targetAngle - e.angle) * dt * 5 -- Smooth rotation

--------------------------------------------------- Waddle Effect --------------------------------------------------- 
        e.waddleTimer = e.waddleTimer + dt * e.waddleSpeed
        if e.waddleTimer >= 1 then
            e.waddleTimer = 0
            e.waddleDirection = -e.waddleDirection
        end

---------------------------------------- Tactical Enemy Reloading Movement ---------------------------------------------
        if e.reloading then
            e.x = e.x - (dx / distance) * e.speed * dt * 1.5
            e.y = e.y - (dy / distance) * e.speed * dt * 1.5
        end

---------------------------------------------- Enemy Shooting Logic --------------------------------------------------- 
        if not e.reloading then
            e.shootingTimer = e.shootingTimer + dt
            if e.shootingTimer >= 1.5 then
                enemy:shoot(e)
                local audio = love.audio.newSource("assets/Audio/EnemyGunshot.wav","static")
                audio:setVolume(0.014)
                love.audio.play(audio)
                e.bulletsFired = e.bulletsFired + 1
                e.shootingTimer = 0
            end
            if e.bulletsFired >= 6 then
                e.reloading = true
                e.bulletsFired = 0
                e.shootingTimer = -1
            end
        else
            e.shootingTimer = e.shootingTimer + dt
            if e.shootingTimer >= 0 then
                e.reloading = false
            end
        end
--------------------------------------------------- Knockback Duration ---------------------------------------------------
        for i, e in ipairs(enemies) do
            -- ✅ Apply knockback if active
            if e.knockbackTimer > 0 then
                e.x = e.x + e.knockbackX * dt
                e.y = e.y + e.knockbackY * dt
        
                -- ✅ Reduce knockback over time (Smooth Decay)
                e.knockbackX = e.knockbackX * (1 - dt * 10)
                e.knockbackY = e.knockbackY * (1 - dt * 10)
        
                e.knockbackTimer = e.knockbackTimer - dt
            end
        end
--------------------------------------------------- Remove if dead --------------------------------------------------- 
        if e.health <= 0 then
            table.remove(enemies, i)
            waves:enemyDefeated()
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
        sprite = enemyBulletSprite,
        hitbox = Hitbox.new(e.x, e.y, 10, 10)
    })
end

enemy.bullets = {}

----------------------------------------- Updates Enemy Bullets --------------------------------------------------------------------------
function enemy:updateBullets(dt)
    for i = #self.bullets, 1, -1 do
        local b = self.bullets[i]
        b.x = b.x + b.dx * dt
        b.y = b.y + b.dy * dt
        b.hitbox.x = b.x - 5  -- Move hitbox with bullet
        b.hitbox.y = b.y - 5

        -- Check if bullet hits the player AND player is not invincible
        if b.hitbox:detectcollision(player.hurtbox) and not player.invincible then
            player.health = player.health - player.damage_taken  -- Player takes damage
            
            -- Activate invincibility
            player.invincible = true
            player.invincibilityTimer = 1.5  -- Set invincibility duration
            
            -- Start screen shake
            player.screenshake = 10  -- Adjust shake intensity

            -- Play hit sound effect
            local audio = love.audio.newSource("assets/Audio/PlayerHit.mp3", "static")
            audio:setVolume(0.1)
            love.audio.play(audio)

            table.remove(self.bullets, i)  -- Remove bullet on hit
        end

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
        love.graphics.draw(b.sprite, b.x, b.y, 0, 0.5, 0.5, b.sprite:getWidth()/2, b.sprite:getHeight()/2)
    end
end

function enemy:getEnemies()
    return enemies
end

function enemy.clearEnemies()
    enemies = {}  -- ✅ Clears all active enemies
    enemy.bullets = {}  -- ✅ Clears all enemy bullets
end

return enemy