player = require("player")
enemy = require("enemy")
hitbox = require("hitbox")

bullet = {}
bullet.list = {} 
bullet.cooldown = 0
bullet.reload_time = 2  -- How long the Reload is
bullet.reload_timer = 0
bullet.is_reloading = false

function bullet.spawn(x, y, targetX, targetY, speed)
    if bullet.cooldown <= 0 and not bullet.is_reloading then
        -- Calculate direction --
        local angle = math.atan2(targetY - y, targetX - x)
        local velocityX = math.cos(angle) * speed
        local velocityY = math.sin(angle) * speed
        local audio = love.audio.newSource("assets/Audio/PistolGunshot.wav","static")
        audio:setVolume(0.08)
        love.audio.play(audio)

        local bulletX = weapon.x + weapon.sprite:getWidth() * 0.25 * math.cos(angle)
        local bulletY = weapon.y + weapon.sprite:getHeight() * 0.25 * math.sin(angle)
        
        table.insert(bullet.list, {
            x = bulletX,
            y = bulletY,
            vx = velocityX,
            vy = velocityY,
            speed = speed,
            startX = x,  -- Store the starting position
            startY = y,
            distanceTraveled = 0, -- Track the distance moved
            sprite = love.graphics.newImage("assets/PlayerBullet.png"), -- Add Bullet Sprite
            hitbox = Hitbox.new(bulletX, bulletY, 20, 20)  -- Make sure hitbox is at the bullet position
        })

        bullet.cooldown = player.fire_rate -- Reset cooldown
        player.ammo = player.ammo - 1
    end
end

function bullet.update(dt)
    bullet.cooldown = math.max(0, bullet.cooldown - dt) -- Reduce cooldown over time

    -- Handle reload timer
    if bullet.is_reloading then
        bullet.reload_timer = bullet.reload_timer - dt
        if bullet.reload_timer <= 0 then
            bullet.is_reloading = false
            player.ammo = player.max_ammo  -- Fully reload ammo
        end
    end

    -- Update bullet positions
    for i = #bullet.list, 1, -1 do
        local b = bullet.list[i]
        b.x = b.x + b.vx * dt
        b.y = b.y + b.vy * dt
        b.hitbox.x = b.x - 10  -- Move hitbox with bullet
        b.hitbox.y = b.y - 10

        -- Calculate distance traveled
        local traveled = math.sqrt((b.x - b.startX)^2 + (b.y - b.startY)^2)
        b.distanceTraveled = traveled

        -- Check for collision with enemies
        for j, e in ipairs(enemy:getEnemies()) do
            if b.hitbox:detectcollision(e.hurtbox) then
                e.health = e.health - player.damage  -- ✅ Deal damage to enemy
                
                -- ✅ Calculate Knockback Direction (Push Enemy Away from Bullet Impact)
                local knockbackForce = 300  -- Strength of knockback
                local dx, dy = e.x - b.x, e.y - b.y  -- Direction from bullet to enemy
                local dist = math.sqrt(dx^2 + dy^2)
                
                if dist > 0 then
                    e.knockbackX = (dx / dist) * knockbackForce  -- Set knockback velocity
                    e.knockbackY = (dy / dist) * knockbackForce
                    e.knockbackTimer = 0.2  -- Knockback lasts for 0.2 seconds
                end
                
                table.remove(bullet.list, i)  -- Remove bullet on hit
                break
            end
        end
                
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
    if love.keyboard.isDown("r") and player.ammo < player.max_ammo and not bullet.is_reloading then
        bullet.is_reloading = true
        bullet.reload_timer = bullet.reload_time  -- Start countdown
        local audio = love.audio.newSource("assets/Audio/Reload.wav","static")
        audio:setVolume(0.1)
        love.audio.play(audio)
    end
end

return bullet