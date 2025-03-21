local bosses = {}
local enemy = require("enemy") -- Reusing general enemy movement AI

bosses.list = {
    {
        name = "Boss #1",
        health = 500,
        speed = 1.5,
        fireRate = 1.2,
        bulletSpeed = 300,
        sprite = love.graphics.newImage("assets/Boss1.png"),
        attacks = {"Charge Attack", "Bullet Spread", "Ground Slam"},
        attackPattern = function(self)
            self.isPerformingSpecial = true
            local attack = self.attacks[math.random(#self.attacks)]
            if attack == "Charge Attack" then
                -- Charge attack logic
            elseif attack == "Bullet Spread" then
                -- Bullet spread attack logic
            elseif attack == "Ground Slam" then
                -- Ground slam attack logic
            end
            self.isPerformingSpecial = false
        end
    }
}

function bosses:spawnBoss(index)
    if self.list[index] then
        local boss = self.list[index]
        
        -- Spawn at a random side outside the screen
        local side = math.random(4)
        if side == 1 then
            boss.x = math.random(0, love.graphics.getWidth())
            boss.y = -100
        elseif side == 2 then
            boss.x = math.random(0, love.graphics.getWidth())
            boss.y = love.graphics.getHeight() + 100
        elseif side == 3 then
            boss.x = -100
            boss.y = math.random(0, love.graphics.getHeight())
        elseif side == 4 then
            boss.x = love.graphics.getWidth() + 100
            boss.y = math.random(0, love.graphics.getHeight())
        end
        
        boss.movement = enemy.movement -- Use general enemy AI
        boss.shoot = enemy.shoot -- Use enemy shooting logic
        boss.alive = true
        boss.health = self.list[index].health -- Reset boss health on spawn
        boss.attackTimer = 0
        boss.avoidanceActive = false
        boss.avoidanceTimer = 0
        boss.avoidanceDuration = 3 -- Toggle every few seconds
        boss.isPerformingSpecial = false
        
        -- Waddle Variables
        boss.waddleTimer = 0
        boss.waddleDirection = 1
        boss.waddleSpeed = 10
        boss.waddleAmount = 0.05
        
        function boss:update(dt)
            if self.health > 0 then
                if not self.isPerformingSpecial then
                    self.movement(self, dt) -- Use enemy movement logic
                    self.attackTimer = self.attackTimer + dt
                    self.avoidanceTimer = self.avoidanceTimer + dt
                    
                    -- Random attack every 3-5 seconds
                    if self.attackTimer >= math.random(3, 5) then
                        self:attackPattern()
                        self.attackTimer = 0
                    else
                        -- If not attacking, perform normal shooting behavior
                        if self.attackTimer % self.fireRate < dt then
                            self.shoot(self)
                        end
                    end
                    
                    -- Toggle avoidance zones every few seconds
                    if self.avoidanceTimer >= self.avoidanceDuration then
                        self.avoidanceActive = not self.avoidanceActive
                        self.avoidanceTimer = 0
                    end
                end
                
                -- Waddle Effect
                self.waddleTimer = self.waddleTimer + dt * self.waddleSpeed
                if self.waddleTimer >= 1 then
                    self.waddleTimer = 0
                    self.waddleDirection = -self.waddleDirection
                end
            end
        end
        
        function boss:draw()
            love.graphics.draw(self.sprite, self.x, self.y, self.waddleDirection * self.waddleAmount, 0.3, 0.3, self.sprite:getWidth() / 2, self.sprite:getHeight() / 2)
        end
        
        function boss:takeDamage(damage)
            self.health = self.health - damage
            if self.health <= 0 then
                self.alive = false
                waves:nextWave()
            end
        end
        
        return boss
    else
        return nil
    end
end

return bosses
