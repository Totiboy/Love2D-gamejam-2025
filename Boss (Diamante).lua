player = require("player")
hitbox = require("hitbox")
hurtbox = require("hurtbox")
Diamante = {}

function Diamante:load()
    self.name = "Two-Faced Diamante"
    self.addedtotalHP = 25
    self.health = self.addedtotalHP
    self.baseSpeed = 300
    self.speed = 300
    self.fireRate = 0.3  -- Base fire rate
    self.fireCooldown = 0
    self.bulletSpeed = 375
    self.sprite = love.graphics.newImage("assets/Bosses/Two-Faced Diamante.png")
    self.gunSprite = love.graphics.newImage("assets/Bosses/Uzi.png")
    self.bulletSprite = love.graphics.newImage("assets/EnemyBullet.png")
    self.x = love.graphics.getWidth() / 2
    self.y = -100
    self.attackTimer = math.random(4, 6)  -- Changed to 4-6 seconds interval
    self.specialAttack = false
    self.halfHealthTriggered = false
    self.bullets = {}
    self.alive = true
    self.gunAngle = 0
    self.hurtbox = HurtBox.new(self.x,self.y,self.sprite:getWidth()/5,self.sprite:getHeight()/5)
    
    -- Add waddle motion variables
    self.waddleTimer = 0
    self.waddleDirection = 1
    self.waddleSpeed = 10
    self.waddleAmount = 0.05
end
    
-- General AI: Movement
function Diamante:movement(dt)
    local dx, dy = player.x - self.x, player.y - self.y
    local distance = math.sqrt(dx^2 + dy^2)

    if not self.specialAttack then
        -- Smooth movement towards the player
        local moveX = (dx / distance) * self.speed * dt
        local moveY = (dy / distance) * self.speed * dt

        if distance > 400 then
            self.x = self.x + moveX
            self.y = self.y + moveY
        elseif distance < 200 then
            self.x = self.x - moveX * 0.5
            self.y = self.y - moveY * 0.5
        end
        
        -- Add waddle motion for movement illusion
        self.waddleTimer = self.waddleTimer + dt * self.waddleSpeed
        if self.waddleTimer >= 1 then
            self.waddleTimer = 0
            self.waddleDirection = -self.waddleDirection
        end
        
        -- Apply waddle effect
        self.x = self.x + math.sin(self.waddleTimer * math.pi) * self.waddleAmount * self.waddleDirection
    end
end

-- General AI: Shooting
function Diamante:shoot(dt)
    if self.fireCooldown <= 0 then
        self.fireCooldown = self.fireRate -- Reset cooldown

        local gunLength = self.gunSprite:getWidth() / 2 * 0.2 -- Adjust if needed (0.2 is scale of gun sprite)
        local bulletX = self.x + math.cos(self.gunAngle) * gunLength
        local bulletY = self.y + math.sin(self.gunAngle) * gunLength

        local bullet = {
            x = bulletX,
            y = bulletY,
            dx = math.cos(self.gunAngle) * self.bulletSpeed,
            dy = math.sin(self.gunAngle) * self.bulletSpeed,
            sprite = self.bulletSprite,
            hitbox = Hitbox.new(bulletX, bulletY, 10, 10)
        }
        table.insert(self.bullets, bullet)
    end
end

-- Special Attack Handler
function Diamante:triggerSpecialAttack()
    self.specialAttack = true
    local attackType = math.random(1, self.halfHealthTriggered and 4 or 3)
    --local attackType = math.random(3,3)
    
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
function Diamante:attack1()
    self.specialAttack = true
    self.speed = 600  -- Increased speed for rushing
    self.fireRate = 0.1  -- Faster fire rate
    self.bulletsFired = 0
    self.stopDistance = 100  -- Stop when close to the player
    self.attackPhase = "rushing"
end

-- ATK #2: Wide Bullet Spam (1/3 Circle Pattern)
function Diamante:attack2()
    self.specialAttack = true
    self.speed = 100
    self.attackPhase = "pattern_shooting"
    
    -- Save player position to direct the pattern toward them
    self.targetX = player.x
    self.targetY = player.y
    
    -- Setup for 1/3 circle pattern (60 degrees total, -30 to +30 from center)
    self.patternAngle = -30  -- Start at -30 degrees from player direction
    self.patternStep = 5    -- 5 degree steps
    self.patternTimer = 0
    self.patternDelay = 0.05  -- Delay between shots
end

-- ATK #3: Leave & Surprise Attack
function Diamante:attack3()
    self.specialAttack = true
    self.attackPhase = "leaving"
    self.speed = 600  -- Fast speed to exit
    
    -- Decide which screen edge to exit from
    if self.x < love.graphics.getWidth() / 2 then
        self.exitX = -150
    else
        self.exitX = love.graphics.getWidth() + 150
    end

    if self.y < love.graphics.getHeight() / 2 then
        self.exitY = -150
    else
        self.exitY = love.graphics.getHeight() + 150
    end
end

-- Big ATK: Gradual 360 degree + 180 degree Circle Pattern
function Diamante:bigAttack()
    self.specialAttack = true
    self.attackPhase = "moving_to_center"
    
    -- Target center of screen
    self.targetX = love.graphics.getWidth() / 2
    self.targetY = love.graphics.getHeight() / 2
    
    -- Setup for spiral pattern
    self.spiralAngle = 0
    self.spiralStep = 8      -- Degrees per bullet (60 bullets for a full circle)
    self.spiralTimer = 0
    self.spiralDelay = 0.04  -- Time between bullets
    self.bulletsToFire = 100 -- Total bullets to fire
end

-- Reset Stats After Special Attack
function Diamante:resetStats()
    self.speed = self.baseSpeed
    self.fireRate = 0.3      -- Reset to base fire rate
    self.specialAttack = false
    self.attackPhase = nil
    self.bulletsFired = 0
    self.attackTimer = math.random(4, 6)  -- Changed to 4-6 seconds
    self.spiralAngle = nil
    self.patternAngle = nil
end

-- Update Function
function Diamante:update(dt)
    -- Check if dead
    if self.health <= 0 then
        self.alive = false
        waves:nextWave()
        return
    end
    
    -- Check for half-health special ability unlock
    if self.health <= 50 and not self.halfHealthTriggered then
        self.halfHealthTriggered = true
    end
    
    -- Update gun angle to face player
    local dx, dy = player.x - self.x, player.y - self.y
    self.gunAngle = math.atan2(dy, dx) -- Calculate angle to player
    
    -- Handle special attacks
    if self.specialAttack then
        if self.attackPhase == "rushing" then
            -- Attack 1 - Rush phase
            local distance = math.sqrt(dx^2 + dy^2)

            if distance > self.stopDistance then
                -- Move towards the player
                self.x = self.x + (dx / distance) * self.speed * dt
                self.y = self.y + (dy / distance) * self.speed * dt
            else
                -- Reached stopping point, switch to shooting phase
                self.speed = 100  -- Slow speed during shooting
                self.attackPhase = "rapid_fire"
                self.nextBulletTime = 0.05  -- Initial delay before firing
                self.bulletsFired = 0
            end
        elseif self.attackPhase == "rapid_fire" then
            -- Attack 1 - Rapid fire phase
            self.nextBulletTime = self.nextBulletTime - dt
            
            if self.nextBulletTime <= 0 then
                -- Fire a bullet
                self.fireCooldown = 0  -- Force immediate fire
                self:shoot()
                local audio = love.audio.newSource("assets/Audio/UziShot(1).wav","static")
                audio:setVolume(0.05)
                love.audio.play(audio)
                self.bulletsFired = self.bulletsFired + 1
                self.nextBulletTime = self.fireRate  -- Use current fire rate for next bullet
                
                if self.bulletsFired >= 10 then
                    -- Reset after 10 bullets
                    self:resetStats()
                end
            end
        elseif self.attackPhase == "pattern_shooting" then
            -- Attack 2 - 1/3 Circle Pattern
            self.patternTimer = self.patternTimer - dt
            
            if self.patternTimer <= 0 then
                -- Calculate direction to player's saved position
                local targetDx = self.targetX - self.x
                local targetDy = self.targetY - self.y
                local baseAngle = math.atan2(targetDy, targetDx)
                
                -- Calculate angle for this bullet in the pattern
                local currentAngle = baseAngle + math.rad(self.patternAngle)
                
                -- Spawn bullet at pattern angle
                local bullet = {
                    x = self.x,
                    y = self.y,
                    dx = math.cos(currentAngle) * self.bulletSpeed,
                    dy = math.sin(currentAngle) * self.bulletSpeed,
                    sprite = self.bulletSprite
                }
                table.insert(self.bullets, bullet)
                
                -- Increment pattern angle
                self.patternAngle = self.patternAngle + self.patternStep
                self.patternTimer = self.patternDelay
                local audio = love.audio.newSource("assets/Audio/UziShot(1).wav","static")
            audio:setVolume(0.05)
            love.audio.play(audio)
                
                -- End pattern after reaching +30 degrees
                if self.patternAngle > 30 then
                    self:resetStats()
                end
            end
        elseif self.attackPhase == "leaving" then
            -- Attack 3 - Move towards exit point
            local dx = self.exitX - self.x
            local dy = self.exitY - self.y
            local distance = math.sqrt(dx^2 + dy^2)
        
            if distance > 10 then
                -- Move towards exit
                self.x = self.x + (dx / distance) * self.speed * dt
                self.y = self.y + (dy / distance) * self.speed * dt
            else
                -- Off-screen wait
                self.attackPhase = "waiting"
                self.waitTimer = 0.5
            end
        elseif self.attackPhase == "waiting" then
            -- Attack 3 - Waiting phase
            self.waitTimer = self.waitTimer - dt
            
            if self.waitTimer <= 0 then
                -- Calculate player's position relative to screen boundaries
                local offset = 150
                local screenWidth = love.graphics.getWidth()
                local screenHeight = love.graphics.getHeight()
                
                -- Determine which edge is closest to the player
                local distToLeft = player.x
                local distToRight = screenWidth - player.x
                local distToTop = player.y
                local distToBottom = screenHeight - player.y
                
                -- Find the minimum distance to determine closest edge
                local minDist = math.min(distToLeft, distToRight, distToTop, distToBottom)
                
                -- Spawn from the edge closest to player
                if minDist == distToLeft then
                    -- Left edge
                    self.x = -offset
                    self.y = player.y
                elseif minDist == distToRight then
                    -- Right edge
                    self.x = screenWidth + offset
                    self.y = player.y
                elseif minDist == distToTop then
                    -- Top edge
                    self.x = player.x
                    self.y = -offset
                elseif minDist == distToBottom then
                    -- Bottom edge
                    self.x = player.x
                    self.y = screenHeight + offset
                end
                
                -- Start approaching player
                self.attackPhase = "approaching"
                self.fireRate = 0.1  -- Faster fire rate for attack
            end
        elseif self.attackPhase == "approaching" then
            -- Attack 3 - Approach player before firing
            local dx = player.x - self.x
            local dy = player.y - self.y
            local distance = math.sqrt(dx^2 + dy^2)
            
            -- Move toward player
            self.x = self.x + (dx / distance) * self.speed * dt
            self.y = self.y + (dy / distance) * self.speed * dt
            
            -- When close enough, start firing
            if distance < 200 then
                self.attackPhase = "surprise_fire"
                self.nextBulletTime = 0.3  -- Initial delay
                self.bulletsFired = 0
            end
        elseif self.attackPhase == "surprise_fire" then
            -- Attack 3 - Rapid fire after approach
            self.nextBulletTime = self.nextBulletTime - dt
            
            if self.nextBulletTime <= 0 then
                -- Fire a bullet
                self.fireCooldown = 0
                self:shoot()
                local audio = love.audio.newSource("assets/Audio/UziShot(1).wav","static")
                audio:setVolume(0.05)
                love.audio.play(audio)
                self.bulletsFired = self.bulletsFired + 1
                self.nextBulletTime = self.fireRate
                
                if self.bulletsFired >= 10 then
                    -- Reset after 10 bullets
                    self:resetStats()
                end
            end
        elseif self.attackPhase == "moving_to_center" then
            -- Big Attack - Move to center first
            local dx = self.targetX - self.x
            local dy = self.targetY - self.y
            local distance = math.sqrt(dx^2 + dy^2)
            
            if distance > 10 then
                -- Move toward center
                self.x = self.x + (dx / distance) * self.speed * dt
                self.y = self.y + (dy / distance) * self.speed * dt
            else
                -- Reached center, start spiral attack
                self.x = self.targetX  -- Snap exactly to center
                self.y = self.targetY
                self.attackPhase = "spiral_attack"
                self.spiralTimer = 0
                self.bulletsFired = 0
            end
        elseif self.attackPhase == "spiral_attack" then
            -- Big Attack - Fire bullets in spiral pattern
            self.spiralTimer = self.spiralTimer - dt
            
            if self.spiralTimer <= 0 and self.bulletsFired < self.bulletsToFire then
                -- Calculate bullet trajectory based on current angle
                local angle = math.rad(self.spiralAngle)
                
                -- Create bullet
                local bullet = {
                    x = self.x,
                    y = self.y,
                    dx = math.cos(angle) * self.bulletSpeed,
                    dy = math.sin(angle) * self.bulletSpeed,
                    sprite = self.bulletSprite
                }
                table.insert(self.bullets, bullet)
                
                -- Increment spiral
                self.spiralAngle = self.spiralAngle + self.spiralStep * 1.6
                self.bulletsFired = self.bulletsFired + 1
                self.spiralTimer = self.spiralDelay
                local audio = love.audio.newSource("assets/Audio/UziShot(1).wav","static")
                audio:setVolume(0.05)
                love.audio.play(audio)
                
                -- Update gun angle to match firing pattern
                self.gunAngle = angle
                
                -- Reset after firing all bullets
                if self.bulletsFired >= self.bulletsToFire then
                    self:resetStats()
                end
            end
        end
    else
        -- Normal behavior when not in special attack
        self:movement(dt)
        
        -- Normal shooting
        if self.fireCooldown > 0 then
            self.fireCooldown = self.fireCooldown - dt
        else
            self:shoot()
            local audio = love.audio.newSource("assets/Audio/UziShot(1).wav","static")
            audio:setVolume(0.05)
            love.audio.play(audio)
        end
        
        -- Special attack timer
        if self.attackTimer <= 0 then
            self:triggerSpecialAttack()
        else
            self.attackTimer = self.attackTimer - dt
        end
    end
    
    -- Always update bullets
    self:updateBullets(dt)
end

-- Update bullets (extracted to separate function for clarity)
function Diamante:updateBullets(dt)
    for i = #self.bullets, 1, -1 do
        local b = self.bullets[i]
        b.x = b.x + b.dx * dt
        b.y = b.y + b.dy * dt
        self.hurtbox:update(self.x - 33, self.y - 50)
        
        -- Ensure every bullet has a hitbox
        if not b.hitbox then
            b.hitbox = Hitbox.new(b.x - 5, b.y - 5, 10, 10)
        else
            b.hitbox.x = b.x - 5  -- Move hitbox with bullet
            b.hitbox.y = b.y - 5
        end
        
        -- Check for collision with player
        if b.hitbox:detectcollision(player.hurtbox) and not player.invincible then
            player.health = player.health - player.damage_taken  -- Player takes damage
            
            -- Activate invincibility
            player.invincible = true
            player.invincibilityTimer = player.invincibilityTime  -- Use player's defined invincibility time
            
            -- Start screen shake
            player.screenshake = 10  -- Adjust shake intensity

            -- Play hit sound effect
            local audio = love.audio.newSource("assets/Audio/PlayerHit.mp3", "static")
            audio:setVolume(0.1)
            love.audio.play(audio)

            table.remove(self.bullets, i)  -- Remove bullet on hit
            goto continue  -- Skip the rest of this iteration
        end
        
        local bulletModule = require("bullet")  -- Make sure to add this at the top of the file
        if bulletModule and bulletModule.list then
            for j = #bulletModule.list, 1, -1 do
                local pb = bulletModule.list[j]
                if pb.hitbox and pb.hitbox:detectcollision(self.hurtbox) then
                    self.health = self.health - player.damage  -- Deal damage to Diamante
                    
                    -- Knockback Direction (Push Diamante Away from Bullet Impact)
                    local knockbackForce = 250
                    local dx, dy = self.x - pb.x, self.y - pb.y
                    local dist = math.sqrt(dx^2 + dy^2)
        
                    if dist > 0 then
                        self.knockbackX = (dx / dist) * knockbackForce
                        self.knockbackY = (dy / dist) * knockbackForce
                        self.knockbackTimer = 0.15
                    end
                    
                    -- Play hit sound effect
                    local audio = love.audio.newSource("assets/Audio/EnemyHit.mp3", "static")
                    if audio then
                        audio:setVolume(0.1)
                        love.audio.play(audio)
                    end
        
                    table.remove(bulletModule.list, j)  -- Remove the bullet upon hit
                    break
                end
            end
        end
        
        -- Remove bullets that go off-screen
        if b.x < -50 or b.x > love.graphics.getWidth() + 50 or 
           b.y < -50 or b.y > love.graphics.getHeight() + 50 then
            table.remove(self.bullets, i)
        end
        ::continue::
    end
end

-- Draw Function
function Diamante:draw()
    -- Draw the boss
    love.graphics.draw(self.sprite, self.x, self.y, 0, 0.3, 0.3, self.sprite:getWidth()/2, self.sprite:getHeight()/2)

    -- Draw the rotating gun
    love.graphics.draw(self.gunSprite, self.x, self.y, self.gunAngle, 0.2, 0.2, self.gunSprite:getWidth()/2, self.gunSprite:getHeight()/2)

    -- Draw bullets
    for _, b in ipairs(self.bullets) do
        love.graphics.draw(b.sprite, b.x, b.y, 0, 0.3, 0.3, b.sprite:getWidth()/2, b.sprite:getHeight()/2)
    end
    
    -- Optional: Draw health bar
    local healthBarWidth = 200
    local healthBarHeight = 20
    local healthX = love.graphics.getWidth() / 2 - healthBarWidth / 2
    local healthY = 50
    
    -- Health bar background
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.rectangle("fill", healthX, healthY, healthBarWidth, healthBarHeight)
    
    -- Health bar fill
    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle("fill", healthX, healthY, healthBarWidth * (self.health / self.addedtotalHP), healthBarHeight)
    
    -- Health bar border
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("line", healthX, healthY, healthBarWidth, healthBarHeight)
    
    -- Reset color
    love.graphics.setColor(0, 0, 0)
    self.hurtbox:draw()
end

function Diamante:fullReset()
    self.addedtotalHP = 25 * waves.currentWave
    self.speed = self.baseSpeed
    self.fireRate = 0.3
    self.fireCooldown = 0
    self.bullets = {}  -- Clear all bullets
    self.alive = true
    self.specialAttack = false
    self.halfHealthTriggered = false
    self.attackPhase = nil
    self.attackTimer = math.random(4, 6)
    self.bulletsFired = 0
    self.spiralAngle = nil
    self.patternAngle = nil
    self.x = love.graphics.getWidth() / 2  -- Respawn at the center
    self.y = -100
end

return Diamante