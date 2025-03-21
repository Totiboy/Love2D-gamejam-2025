player = require("player")

bullet = {}
bullet.list = {} 
bullet.cooldown = 0

function bullet.spawn(x, y, targetX, targetY, speed)
    if bullet.cooldown <= 0 then
        -- Calculate direction --
        local angle = math.atan2(targetY - y, targetX - x)
        local velocityX = math.cos(angle) * speed
        local velocityY = math.sin(angle) * speed
        local audio = love.audio.newSource("assets/Audio/PistolGunshot.wav","static")
        audio:setVolume(0.04)
        love.audio.play(audio)

        table.insert(bullet.list, {
            x = weapon.x + weapon.sprite:getWidth() * 0.25 * math.cos(angle),
            y = weapon.y + weapon.sprite:getHeight() * 0.25 * math.sin(angle),
            vx = velocityX,
            vy = velocityY,
            speed = speed,
            startX = x,  -- Store the starting position
            startY = y,
            distanceTraveled = 0, -- Track the distance moved
            sprite = love.graphics.newImage("assets/PlayerBullet.png") -- Add Bullet Sprite
        })

        bullet.cooldown = player.fire_rate -- Reset cooldown
        player.ammo = player.ammo - 1
    end
end

function bullet.update(dt)
    bullet.cooldown = math.max(0, bullet.cooldown - dt) -- Reduce cooldown over time

    for i = #bullet.list, 1, -1 do
        local b = bullet.list[i]
        b.x = b.x + b.vx * dt
        b.y = b.y + b.vy * dt

        -- Calculate distance traveled --
        local traveled = math.sqrt((b.x - b.startX)^2 + (b.y - b.startY)^2)
        b.distanceTraveled = traveled

        -- Remove bullet if it has traveled 1500 units
        if b.distanceTraveled > 1500 then
            table.remove(bullet.list, i)
        end
    end
end

function bullet.draw()
    for _, b in ipairs(bullet.list) do
        love.graphics.draw(b.sprite, b.x, b.y, 0, 0.5, 0.5, b.sprite:getWidth() / 2, b.sprite:getHeight() / 2)
    end
    love.graphics.setColor(1, 1, 1)
end

function bullet.reload()
    if love.keyboard.isDown("r") then
        player.ammo = player.max_ammo
    end
    if player.ammo == 0 then
        player.ammo = player.max_ammo
    end
end

return bullet