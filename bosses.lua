local bosses = {}
local enemy = require("enemy") -- Reusing general enemy movement AI

function TwoFacedDiamante()
    local boss = {
        name = "Two-Faced Diamante",
        health = 100,
        baseSpeed = 300,
        speed = 300,
        fireRate = 0.3,
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
        local dx, dy = player.x - self.x, player.y - self.y
        local distance = math.sqrt(dx^2 + dy^2)

        if not self.specialAttack then
            if distance > 400 then
                self.x = self.x + (dx / distance) * self.speed * dt * 100
                self.y = self.y + (dy / distance) * self.speed * dt * 100
            elseif distance < 200 then
                self.x = self.x - (dx / distance) * self.speed * dt * 50
                self.y = self.y - (dy / distance) * self.speed * dt * 50
            end
        end
    end

    -- General AI: Shooting
    function boss:shoot(dt)
        if not self.specialAttack and self.attackTimer <= 0 then
            local spread = math.rad(math.random(-10, 10))
            local bullet = {
                x = self.x,
                y = self.y,
                angle = math.atan2(player.y - self.y, player.x - self.x) + spread,
                speed = self.bulletSpeed,
                sprite = self.bulletSprite
            }
            table.insert(self.bullets, bullet)
            self.attackTimer = self.fireRate
        else
            self.attackTimer = self.attackTimer - dt
        end
    end

    -- Special Attack Handler
    function boss:triggerSpecialAttack()
        self.specialAttack = true
        local attackType = math.random(1, self.halfHealthTriggered and 4 or 3)
        if attackType == 1 then
            self:attack1()
        elseif attackType == 2 then
            self:attack2()
        elseif attackType == 3 then
            self:attack3()
        elseif attackType == 4 then
            self:bigAttack()
        end
    end

    -- ATK #1: Rush and Rapid Fire
    function boss:attack1()
        self.speed = 600
        while math.sqrt((self.x - player.x)^2 + (self.y - player.y)^2) > 100 do
            local dx, dy = player.x - self.x, player.y - self.y
            self.x = self.x + dx * 0.1
            self.y = self.y + dy * 0.1
        end
        self.speed = 100
        for i = 1, 10 do
            self:shoot(0)
        end
        self:resetStats()
    end

    -- ATK #2: Wide Bullet Spam
    function boss:attack2()
        self.speed = 100
        for i = -5, 5 do
            for j = 1, 3 do
                local bullet = {
                    x = self.x,
                    y = self.y,
                    angle = math.rad(i * 10) + math.random(-5, 5),
                    speed = self.bulletSpeed,
                    sprite = self.bulletSprite
                }
                table.insert(self.bullets, bullet)
            end
        end
        self:resetStats()
    end

    -- ATK #3: Leave & Surprise Attack
    function boss:attack3()
        -- Leave screen in a random direction
        local exitSide = math.random(1, 4)
        if exitSide == 1 then -- Left
            self.x, self.y = -100, math.random(0, love.graphics.getHeight())
        elseif exitSide == 2 then -- Right
            self.x, self.y = love.graphics.getWidth() + 100, math.random(0, love.graphics.getHeight())
        elseif exitSide == 3 then -- Top
            self.x, self.y = math.random(0, love.graphics.getWidth()), -100
        elseif exitSide == 4 then -- Bottom
            self.x, self.y = math.random(0, love.graphics.getWidth()), love.graphics.getHeight() + 100
        end
        
        -- Instantly reappear outside the screen near the player
        local reappearOffset = 150
        local spawnSide = math.random(1, 4)
        if spawnSide == 1 then -- Left
            self.x, self.y = player.x - reappearOffset, player.y
        elseif spawnSide == 2 then -- Right
            self.x, self.y = player.x + reappearOffset, player.y
        elseif spawnSide == 3 then -- Top
            self.x, self.y = player.x, player.y - reappearOffset
        elseif spawnSide == 4 then -- Bottom
            self.x, self.y = player.x, player.y + reappearOffset
        end
        
        self.speed = 500
        for i = 1, 10 do
            self:shoot(0)
        end
        self:resetStats()
    end


    -- Big ATK: 100 Bullet Spiral
    function boss:bigAttack()
        self.x = love.graphics.getWidth() / 2
        self.y = love.graphics.getHeight() / 2
        for i = 1, 100 do
            local bullet = {
                x = self.x,
                y = self.y,
                angle = math.rad(i * 3.6),
                speed = self.bulletSpeed,
                sprite = self.bulletSprite
            }
            table.insert(self.bullets, bullet)
        end
        self:resetStats()
    end

    -- Reset Stats After Special Attack
    function boss:resetStats()
        self.speed = self.baseSpeed
        self.specialAttack = false
        self.attackTimer = math.random(8, 13)
    end

    -- Update Function
    function boss:update(dt)
        if self.health <= 0 then
            self.alive = false
            waves:nextState()
        end
        if not self.specialAttack then
            self:movement(dt)
            self:shoot(dt)
        end
        if self.attackTimer <= 0 then
            self:triggerSpecialAttack()
        else
            self.attackTimer = self.attackTimer - dt
        end
        if self.health <= 50 and not self.halfHealthTriggered then
            self.halfHealthTriggered = true
        end
    end

    -- Draw Function
    function boss:draw()
        love.graphics.draw(self.sprite, self.x, self.y, self.gunAngle, 0.3, 0.3, self.sprite:getWidth() / 2, self.sprite:getHeight() / 2)
        love.graphics.draw(self.gunSprite, self.x, self.y, self.gunAngle, 0.2, 0.2, self.gunSprite:getWidth() / 2, self.gunSprite:getHeight() / 2)
    end

    return boss
end

        -- Waddle Variables
        boss.waddleTimer = 0
        boss.waddleDirection = 1
        boss.waddleSpeed = 10
        boss.waddleAmount = 0.05
        
        function boss:update(dt)
            
                -- Waddle Effect
                self.waddleTimer = self.waddleTimer + dt * self.waddleSpeed
                if self.waddleTimer >= 1 then
                    self.waddleTimer = 0
                    self.waddleDirection = -self.waddleDirection
                end
            end
        end
    end
end

return bosses
