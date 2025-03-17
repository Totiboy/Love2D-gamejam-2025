bullet = {}
bullet.list = {} 
bullet.cooldown = 0  
bullet.fireRate = 0.1 -- Adjust Fire Rate Here
ammo = 10

function bullet.spawn(x, y, targetX, targetY, speed)
    if bullet.cooldown <= 0 then
        -- Calculates the direction based on where the Mouse Pointer is --
        -----------------------------------------------------------------------------------------------------------------
        local angle = math.atan2(targetY - y, targetX - x)
        local velocityX = math.cos(angle) * speed
        local velocityY = math.sin(angle) * speed

        table.insert(bullet.list, {
            x = weapon.x + weapon.sprite:getWidth() * 0.25 * math.cos(angle),
            y = weapon.y + weapon.sprite:getHeight() * 0.25 * math.sin(angle),
            vx = velocityX,
            vy = velocityY,
            speed = speed
        })
        bullet.cooldown = bullet.fireRate -- Reset cooldown
        ammo = ammo - 1
    end
end

function bullet.update(dt)
    bullet.cooldown = math.max(0, bullet.cooldown - dt) -- Reduce cooldown over time
    for i = #bullet.list, 1, -1 do
        local b = bullet.list[i]
        b.x = b.x + b.vx * dt
        b.y = b.y + b.vy * dt
        
        -- Removes bullets if they go off-screen (Optional for now)--
        -------------------------------------------------------------------------------------------------------------
        if b.x < 0 or b.x > love.graphics.getWidth() or b.y < 0 or b.y > love.graphics.getHeight() then
            table.remove(bullet.list, i)
        end
    end
end

function bullet.draw()
    love.graphics.setColor(1, 0, 0)
    for _, b in ipairs(bullet.list) do
        love.graphics.circle("fill", b.x, b.y, 5)
    end
    love.graphics.setColor(1, 1, 1)
end

function bullet.reload()
    if love.keyboard.isDown("r") then
        ammo = 10
    end
end


return bullet