local bosses = {}
local enemy = require("enemy")  -- Keep this only if needed

-- Store boss functions
local bossFunctions = {
    [1] = TwoFacedDiamante,  -- Ensure this function exists
    [2] = LucaBoss           -- Ensure this function exists
}

-- Function to Spawn Bosses by Number
function bosses:spawnBoss(bossIndex)
    if bossFunctions[bossIndex] then
        bosses.currentBoss = bossFunctions[bossIndex]()
    end
end

-- Update function for boss state
function bosses:update(dt)
    if bosses.currentBoss and bosses.currentBoss.alive then
        bosses.currentBoss:update(dt)
    end
end

-- Draw function for boss state
function bosses:draw()
    if bosses.currentBoss and bosses.currentBoss.alive then
        bosses.currentBoss:draw()
    end
end



function TwoFacedDiamante()
    local boss = {
        name = "Two-Faced Diamante",
        health = 100,
        baseSpeed = 300,
        speed = 300,
        fireRate = 0.3,  -- Increased to match Uzi's fire rate
        bulletSpeed = 350,
        sprite = love.graphics.newImage("assets/Bosses/Two-Faced Diamante.png"),
        gunSprite = love.graphics.newImage("assets/Bosses/Uzi.png"),
        bulletSprite = love.graphics.newImage("assets/EnemyBullet.png"),
        x = love.graphics.getWidth() / 2,
        y = -100,
        attackTimer = math.random(8, 13),
        specialAttack = false,
        halfHealthTriggered = false,
        bullets = {},
        alive = true,
        gunAngle = 0
    }

    -- General AI: Movement
    function boss:movement(dt)
        local dx, dy = player.x - boss.x, player.y - boss.y
        local distance = math.sqrt(dx^2 + dy^2)

        if not boss.specialAttack then
            if distance > 400 then
                boss.x = boss.x + (dx / distance) * boss.speed * dt * 100
                boss.y = boss.y + (dy / distance) * boss.speed * dt * 100
            elseif distance < 200 then
                boss.x = boss.x - (dx / distance) * boss.speed * dt * 50
                boss.y = boss.y - (dy / distance) * boss.speed * dt * 50
            end
        end
    end

    -- General AI: Shooting
    function boss:shoot()
        if not boss.specialAttack then
            local spread = math.rad(math.random(-10, 10))
            local bullet = {
                x = boss.x,
                y = boss.y,
                dx = math.cos(math.atan2(player.y - boss.y, player.x - boss.x) + spread) * boss.bulletSpeed,
                dy = math.sin(math.atan2(player.y - boss.y, player.x - boss.x) + spread) * boss.bulletSpeed,
                sprite = boss.bulletSprite
            }
            table.insert(boss.bullets, bullet)
        end
    end

    -- Special Attack Handler
    function boss:triggerSpecialAttack()
        boss.specialAttack = true
        local attackType = math.random(1, boss.halfHealthTriggered and 4 or 3)
        if attackType == 1 then
            boss:attack1()
        elseif attackType == 2 then
            boss:attack2()
        elseif attackType == 3 then
            boss:attack3()
        elseif attackType == 4 then
            boss:bigAttack()
        end
    end

    -- ATK #1: Rush and Rapid Fire
    function boss:attack1()
        boss.speed = 600
        while math.sqrt((boss.x - player.x)^2 + (boss.y - player.y)^2) > 100 do
            local dx, dy = player.x - boss.x, player.y - boss.y
            boss.x = boss.x + dx * 0.1
            boss.y = boss.y + dy * 0.1
        end
        boss.speed = 100
        for _ = 1, 10 do
            boss:shoot()
        end
        boss:resetStats()
    end

    -- ATK #2: Wide Bullet Spam
    function boss:attack2()
        boss.speed = 100
        for i = -5, 5 do
            for _ = 1, 3 do
                local bullet = {
                    x = boss.x,
                    y = boss.y,
                    dx = math.cos(math.rad(i * 10)) * boss.bulletSpeed,
                    dy = math.sin(math.rad(i * 10)) * boss.bulletSpeed,
                    sprite = boss.bulletSprite
                }
                table.insert(boss.bullets, bullet)
            end
        end
        boss:resetStats()
    end

    -- ATK #3: Leave & Surprise Attack
    function boss:attack3()
        -- Instantly reappear outside the screen near the player
        local reappearOffset = 150
        local spawnSide = math.random(1, 4)
        if spawnSide == 1 then -- Left
            boss.x, boss.y = player.x - reappearOffset, player.y
        elseif spawnSide == 2 then -- Right
            boss.x, boss.y = player.x + reappearOffset, player.y
        elseif spawnSide == 3 then -- Top
            boss.x, boss.y = player.x, player.y - reappearOffset
        elseif spawnSide == 4 then -- Bottom
            boss.x, boss.y = player.x, player.y + reappearOffset
        end

        boss.speed = 500
        for _ = 1, 10 do
            boss:shoot()
        end
        boss:resetStats()
    end

    -- Big ATK: 100 Bullet Spiral
    function boss:bigAttack()
        boss.x = love.graphics.getWidth() / 2
        boss.y = love.graphics.getHeight() / 2
        for i = 1, 100 do
            local bullet = {
                x = boss.x,
                y = boss.y,
                dx = math.cos(math.rad(i * 3.6)) * boss.bulletSpeed,
                dy = math.sin(math.rad(i * 3.6)) * boss.bulletSpeed,
                sprite = boss.bulletSprite
            }
            table.insert(boss.bullets, bullet)
        end
        boss:resetStats()
    end

    -- Reset Stats After Special Attack
    function boss:resetStats()
        boss.speed = boss.baseSpeed
        boss.specialAttack = false
        boss.attackTimer = math.random(8, 13)
    end

    -- Update Function
    function boss:update(dt)
        if boss.health <= 0 then
            boss.alive = false
            waves:nextWave()
        end
        if not boss.specialAttack then
            boss:movement(dt)
            boss:shoot()
        end
        if boss.attackTimer <= 0 then
            boss:triggerSpecialAttack()
        else
            boss.attackTimer = boss.attackTimer - dt
        end
        if boss.health <= 50 and not boss.halfHealthTriggered then
            boss.halfHealthTriggered = true
        end

        -- Move bullets
        for i = #boss.bullets, 1, -1 do
            local b = boss.bullets[i]
            b.x = b.x + b.dx * dt
            b.y = b.y + b.dy * dt
            if b.x < 0 or b.x > love.graphics.getWidth() or b.y < 0 or b.y > love.graphics.getHeight() then
                table.remove(boss.bullets, i)
            end
        end
    end

    -- Draw Function
    function boss:draw()
        love.graphics.draw(boss.sprite, boss.x, boss.y, boss.gunAngle, 0.3, 0.3, boss.sprite:getWidth() / 2, boss.sprite:getHeight() / 2)
        love.graphics.draw(boss.gunSprite, boss.x, boss.y, boss.gunAngle, 0.2, 0.2, boss.gunSprite:getWidth() / 2, boss.gunSprite:getHeight() / 2)

        -- Draw Bullets
        for _, b in ipairs(boss.bullets) do
            love.graphics.draw(b.sprite, b.x, b.y, 0, 0.5, 0.5, b.sprite:getWidth() / 2, b.sprite:getHeight() / 2)
        end
    end

    return boss
end

return bosses