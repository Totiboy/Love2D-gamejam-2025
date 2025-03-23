player = require("player")
hitbox = require("hitbox")
hurtbox = require("hurtbox")
Luca = {}

function Luca:load()
    self.name = "Luca the Titled"
    self.health = 75
    self.baseSpeed = 350  -- Slightly faster than player
    self.speed = 350
    self.fireRate = 1.2  -- Lower fire rate for shotgun
    self.fireCooldown = 0
    self.bulletSpeed = 400
    self.sprite = love.graphics.newImage("assets/Bosses/Luca The Tilted.png")
    self.gunSprite = love.graphics.newImage("assets/Bosses/Sawed-Off.png")
    self.bulletSprite = love.graphics.newImage("assets/EnemyBullet.png")
    self.x = love.graphics.getWidth() / 2
    self.y = -100
    self.attackTimer = math.random(5, 6)  -- Special attack interval
    self.specialAttack = false
    self.halfHealthTriggered = false
    self.bullets = {}
    self.alive = true
    self.gunAngle = 0
    self.hurtbox = HurtBox.new(self.x, self.y, self.sprite:getWidth()/5, self.sprite:getHeight()/5)
    
    -- Position movement variables
    self.repositionTimer = math.random(3, 5)  -- Time between position changes
    self.targetX = self.x
    self.targetY = self.y
    self.isRepositioning = false
end
    
-- General AI: Movement (hit and run tactics)
function Luca:movement(dt)
    local dx, dy = player.x - self.x, player.y - self.y
    local distance = math.sqrt(dx^2 + dy^2)

    if not self.specialAttack then
        -- Reposition timer
        self.repositionTimer = self.repositionTimer - dt
        if self.repositionTimer <= 0 or self.isRepositioning then
            if not self.isRepositioning then
                -- Choose a new position at window edge or center
                self:chooseNewPosition()
                self.isRepositioning = true
            end
            
            -- Move to the target position
            local targetDx = self.targetX - self.x
            local targetDy = self.targetY - self.y
            local targetDistance = math.sqrt(targetDx^2 + targetDy^2)
            
            if targetDistance > 10 then
                self.x = self.x + (targetDx / targetDistance) * self.speed * dt
                self.y = self.y + (targetDy / targetDistance) * self.speed * dt
            else
                -- Reached the target position
                self.isRepositioning = false
                self.repositionTimer = math.random(3, 5)
            end
        else
            -- Regular movement - keep distance from player
            if distance < 150 then  -- REDUCED: If too close, back away (was 350)
                self.x = self.x - (dx / distance) * self.speed * 0.8 * dt
                self.y = self.y - (dy / distance) * self.speed * 0.8 * dt
            elseif distance > 250 then  -- REDUCED: If too far, get closer (was 500)
                self.x = self.x + (dx / distance) * self.speed * 0.5 * dt
                self.y = self.y + (dy / distance) * self.speed * 0.5 * dt
            else
                -- At good distance, strafe sideways
                local perpX = -dy / distance
                local perpY = dx / distance
                self.x = self.x + perpX * self.speed * 0.4 * dt
                self.y = self.y + perpY * self.speed * 0.4 * dt
            end
        end
    end

    -- Keep within bounds
    self.x = math.max(50, math.min(love.graphics.getWidth() - 50, self.x))
    self.y = math.max(50, math.min(love.graphics.getHeight() - 50, self.y))
end

-- Choose a new position to move to (edge or center)
function Luca:chooseNewPosition()
    local choice = math.random(1, 5)
    local padding = 100
    local width = love.graphics.getWidth()
    local height = love.graphics.getHeight()
    
    if choice == 1 then  -- Center
        self.targetX = width / 2
        self.targetY = height / 2
    elseif choice == 2 then  -- Top edge
        self.targetX = math.random(padding, width - padding)
        self.targetY = padding
    elseif choice == 3 then  -- Right edge
        self.targetX = width - padding
        self.targetY = math.random(padding, height - padding)
    elseif choice == 4 then  -- Bottom edge
        self.targetX = math.random(padding, width - padding)
        self.targetY = height - padding
    else  -- Left edge
        self.targetX = padding
        self.targetY = math.random(padding, height - padding)
    end
end

-- General AI: Shotgun Shooting (40 degree cone pattern, 6 bullets)
function Luca:shoot(dt)
    if self.fireCooldown <= 0 then
        self.fireCooldown = self.fireRate -- Reset cooldown

        -- Shotgun blast (40-degree cone pattern with 6 bullets)
        local angleSpread = math.rad(40) -- Convert spread to radians
        local numBullets = 6
        local startAngle = self.gunAngle - (angleSpread / 2)
        local angleStep = angleSpread / (numBullets - 1)

        -- Sound effect
        local audio = love.audio.newSource("assets/Audio/ShotgunBlast.wav", "static")
        audio:setVolume(0.03)
        love.audio.play(audio)

        for i = 1, numBullets do
            local currentAngle = startAngle + (i - 1) * angleStep
            local gunLength = (self.gunSprite:getWidth() / 2) * 0.2

            local bulletX = self.x + math.cos(currentAngle) * gunLength
            local bulletY = self.y + math.sin(currentAngle) * gunLength

            local bullet = {
                x = bulletX,
                y = bulletY,
                dx = math.cos(currentAngle) * self.bulletSpeed,
                dy = math.sin(currentAngle) * self.bulletSpeed,
                sprite = self.bulletSprite,
                hitbox = Hitbox.new(bulletX, bulletY, 10, 10),
                damage = 1  -- Default damage multiplier
            }
            table.insert(self.bullets, bullet)
        end
    end
end

-- Special Attack Handler
function Luca:triggerSpecialAttack()
    self.specialAttack = true
    --local attackType = math.random(1, self.halfHealthTriggered and 4 or 3)
    local attackType = math.random(4, 4)
    
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

-- ATK #1: Shotgun Recoil Dash
function Luca:attack1()
    self.specialAttack = true
    self.speed = 100  -- Slow speed for windup
    self.attackPhase = "windup"
    self.delayTimer = 0.03  -- 1 second delay
    
    -- Store player's position for the dash target
    self.dashTargetX = player.x
    self.dashTargetY = player.y
end

-- ATK #2: Shotgun Chase
function Luca:attack2()
    self.specialAttack = true
    self.speed = 350  -- Chase speed
    self.attackPhase = "chasing"
    self.attackTimer = 5  -- 5 seconds duration
    self.shotTimer = 0    -- For tracking shot timing
    self.shotInterval = 0.8  -- Time between double shots
    self.shotPairDelay = 0.2  -- Delay between shots in a pair
    self.shotPairCount = 0    -- Tracking which shot in the pair
end

-- ATK #3: Cocking Shotgun for Power Shot
function Luca:attack3()
    self.specialAttack = true
    self.attackPhase = "cocking"
    self.speed = 50  -- Very slow during cocking
    self.cockingTimer = 2  -- 2 seconds to cock
end

-- Big ATK: Off-screen Ambush
function Luca:bigAttack()
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
    
    self.ambushCount = 0  -- Track number of ambush shots
end

-- Reset Stats After Special Attack
function Luca:resetStats()
    self.speed = self.baseSpeed
    self.fireRate = 1.2      -- Reset to base fire rate
    self.specialAttack = false
    self.attackPhase = nil
    self.attackTimer = math.random(5, 6)
end

-- Update Function
function Luca:update(dt)
    -- Check if dead
    if self.health <= 0 then
        self.alive = false
        waves:nextWave()
        return
    end
    
    -- Check for half-health special ability unlock
    if self.health <= 37 and not self.halfHealthTriggered then
        self.halfHealthTriggered = true
    end
    
    -- Update gun angle to face player
    local dx, dy = player.x - self.x, player.y - self.y
    self.gunAngle = math.atan2(dy, dx) -- Calculate angle to player
    
    -- Handle special attacks
    if self.specialAttack then
        if self.attackPhase == "windup" then
            -- Attack 1 - Slow movement and delay
            self.delayTimer = self.delayTimer - dt
            
            if self.delayTimer <= 0 then
                -- Fire in the opposite direction for recoil
                local oppositeAngle = self.gunAngle + math.pi
                local gunLength = self.gunSprite:getWidth() / 2 * 0.2
                
                local bulletX = self.x + math.cos(oppositeAngle) * gunLength
                local bulletY = self.y + math.sin(oppositeAngle) * gunLength
                
                -- Shotgun blast in opposite direction
                local angleSpread = math.rad(40)  -- CHANGED: 45 to 40 degree spread
                local numBullets = 6
                local startAngle = oppositeAngle - angleSpread / 2
                local angleStep = angleSpread / (numBullets - 1)
                
                -- Sound effect
                local audio = love.audio.newSource("assets/Audio/ShotgunBlast.wav", "static")
                audio:setVolume(0.03)
                love.audio.play(audio)
                
                for i = 1, numBullets do
                    local currentAngle = startAngle + (i - 1) * angleStep
                    local bullet = {
                        x = bulletX,
                        y = bulletY,
                        dx = math.cos(currentAngle) * self.bulletSpeed,
                        dy = math.sin(currentAngle) * self.bulletSpeed,
                        sprite = self.bulletSprite,
                        hitbox = Hitbox.new(bulletX, bulletY, 10, 10)
                    }
                    table.insert(self.bullets, bullet)
                end
                
                -- Switch to dash phase
                self.attackPhase = "dashing"
                self.speed = 800  -- Very fast dash speed
            end
        elseif self.attackPhase == "dashing" then
            -- Attack 1 - Dash toward player's original position
            local dx = self.dashTargetX - self.x
            local dy = self.dashTargetY - self.y
            local distance = math.sqrt(dx^2 + dy^2)
            
            if distance > 50 then  -- REDUCED: Keep dashing until within range (was 150)
                -- Move toward target
                self.x = self.x + (dx / distance) * self.speed * dt
                self.y = self.y + (dy / distance) * self.speed * dt
            else
                -- Close enough, shoot again
                self.attackPhase = "final_shot"
                self.gunAngle = math.atan2(player.y - self.y, player.x - self.x) -- Update aim
            end
        elseif self.attackPhase == "final_shot" then
            -- Attack 1 - Final close-range shot
            local gunLength = self.gunSprite:getWidth() / 2 * 0.2
            local bulletX = self.x + math.cos(self.gunAngle) * gunLength
            local bulletY = self.y + math.sin(self.gunAngle) * gunLength
            
            -- Shotgun blast
            local angleSpread = math.rad(40)  -- CHANGED: 45 to 40 degree spread
            local numBullets = 6
            local startAngle = self.gunAngle - angleSpread / 2
            local angleStep = angleSpread / (numBullets - 1)
            
            -- Sound effect
            local audio = love.audio.newSource("assets/Audio/ShotgunBlast.wav", "static")
            audio:setVolume(0.03)
            love.audio.play(audio)
            
            for i = 1, numBullets do
                local currentAngle = startAngle + (i - 1) * angleStep
                local bullet = {
                    x = bulletX,
                    y = bulletY,
                    dx = math.cos(currentAngle) * self.bulletSpeed,
                    dy = math.sin(currentAngle) * self.bulletSpeed,
                    sprite = self.bulletSprite,
                    hitbox = Hitbox.new(bulletX, bulletY, 10, 10)
                }
                table.insert(self.bullets, bullet)
            end
            
            -- End attack
            self:resetStats()
        elseif self.attackPhase == "chasing" then
            -- Attack 2 - Chase and spam shots
            self.attackTimer = self.attackTimer - dt
            self.shotTimer = self.shotTimer - dt
            
            -- Move toward player
            local dx, dy = player.x - self.x, player.y - self.y
            local distance = math.sqrt(dx^2 + dy^2)
            self.x = self.x + (dx / distance) * self.speed * dt
            self.y = self.y + (dy / distance) * self.speed * dt
            
            -- Update aim
            self.gunAngle = math.atan2(dy, dx)
            
            -- Handle shot timing
            if self.shotTimer <= 0 then
                if self.shotPairCount == 0 then
                    -- First shot in pair
                    self:shotgunBlast()
                    self.shotPairCount = 1
                    self.shotTimer = self.shotPairDelay
                else
                    -- Second shot in pair
                    self:shotgunBlast()
                    self.shotPairCount = 0
                    self.shotTimer = self.shotInterval
                end
            end
            
            -- End attack after timer expires
            if self.attackTimer <= 0 then
                self:resetStats()
            end
        elseif self.attackPhase == "cocking" then
            -- Attack 3 - Cocking the shotgun
            self.cockingTimer = self.cockingTimer - dt
            
            -- Slight movement toward player
            local dx, dy = player.x - self.x, player.y - self.y
            local distance = math.sqrt(dx^2 + dy^2)
            
            if distance > 50 then  -- REDUCED: Don't get too close (was 50)
                self.x = self.x + (dx / distance) * self.speed * dt
                self.y = self.y + (dy / distance) * self.speed * dt
            end
            
            -- After cocking time, rush to player
            if self.cockingTimer <= 0 then
                self.attackPhase = "rushing"
                self.speed = 500  -- Fast rush
            end
        elseif self.attackPhase == "rushing" then
            -- Attack 3 - Rush to player after cocking
            local dx, dy = player.x - self.x, player.y - self.y
            local distance = math.sqrt(dx^2 + dy^2)
            
            -- Move toward player
            self.x = self.x + (dx / distance) * self.speed * dt
            self.y = self.y + (dy / distance) * self.speed * dt
            
            -- When close enough, fire the super shot
            if distance < 120 then  -- REDUCED: much closer super shot (was 200)
                self.attackPhase = "super_shot"
            end
        elseif self.attackPhase == "super_shot" then
            -- Attack 3 - Fire the super shot
            local gunLength = self.gunSprite:getWidth() / 2 * 0.2
            local bulletX = self.x + math.cos(self.gunAngle) * gunLength
            local bulletY = self.y + math.sin(self.gunAngle) * gunLength
            
            -- Tighter, more powerful shotgun blast
            local angleSpread = math.rad(30)  -- Tighter spread
            local numBullets = 8    -- More bullets
            local startAngle = self.gunAngle - angleSpread / 2
            local angleStep = angleSpread / (numBullets - 1)
            
            -- Sound effect (louder)
            local audio = love.audio.newSource("assets/Audio/ShotgunBlast.wav", "static")
            audio:setVolume(0.1)
            love.audio.play(audio)
            
            for i = 1, numBullets do
                local currentAngle = startAngle + (i - 1) * angleStep
                local bullet = {
                    x = bulletX,
                    y = bulletY,
                    dx = math.cos(currentAngle) * (self.bulletSpeed * 1.3), -- Faster bullets
                    dy = math.sin(currentAngle) * (self.bulletSpeed * 1.3),
                    sprite = self.bulletSprite,
                    hitbox = Hitbox.new(bulletX, bulletY, 10, 10),
                    damage = 2  -- Double damage
                }
                table.insert(self.bullets, bullet)
            end
            
            -- End attack
            self:resetStats()
        elseif self.attackPhase == "leaving" then
            -- Big Attack - Move offscreen
            local dx = self.exitX - self.x
            local dy = self.exitY - self.y
            local distance = math.sqrt(dx^2 + dy^2)
            
            if distance > 10 then
                -- Move toward exit
                self.x = self.x + (dx / distance) * self.speed * dt
                self.y = self.y + (dy / distance) * self.speed * dt
            else
                -- Off-screen, start ambushing
                self.attackPhase = "ambushing"
                self.ambushTimer = 0  -- Start immediately
                
                -- Determine which side to attack from
                self:determineAmbushPosition()
            end
        elseif self.attackPhase == "ambushing" then
            -- Big Attack - Off-screen ambush shots
            self.ambushTimer = self.ambushTimer - dt
            
            if self.ambushTimer <= 0 then
                -- Fire shotgun blast from edge
                self:ambushShot()
                
                self.ambushCount = self.ambushCount + 1
                
                if self.ambushCount >= 4 then
                    -- After 4 shots, prepare for final attack
                    self.attackPhase = "final_approach"
                    
                    -- Position for final approach
                    self:determineAmbushPosition()
                else
                    -- Set timer for next shot and new position
                    self.ambushTimer = math.random(10, 15) / 10  -- 1.0-1.5 seconds
                    self:determineAmbushPosition()
                end
            end
        elseif self.attackPhase == "final_approach" then
            -- Big Attack - Final rush from offscreen
            local dx = player.x - self.x
            local dy = player.y - self.y
            local distance = math.sqrt(dx^2 + dy^2)
            
            -- Move toward player
            self.x = self.x + (dx / distance) * self.speed * dt
            self.y = self.y + (dy / distance) * self.speed * dt
            
            -- When close enough, fire final blast
            if distance < 150 then  -- REDUCED: much closer final shot (was 200)
                self.attackPhase = "final_ambush_shot"
                self.gunAngle = math.atan2(player.y - self.y, player.x - self.x)
            end
        elseif self.attackPhase == "final_ambush_shot" then
            -- Big Attack - Final powerful shot
            local gunLength = self.gunSprite:getWidth() / 2 * 0.2
            local bulletX = self.x + math.cos(self.gunAngle) * gunLength
            local bulletY = self.y + math.sin(self.gunAngle) * gunLength
            
            -- Powerful shotgun blast
            local angleSpread = math.rad(40)  -- CHANGED: 60 to 40 degree spread
            local numBullets = 10   -- More bullets
            local startAngle = self.gunAngle - angleSpread / 2
            local angleStep = angleSpread / (numBullets - 1)
            
            -- Sound effect
            local audio = love.audio.newSource("assets/Audio/ShotgunBlast.wav", "static")
            audio:setVolume(0.05)
            love.audio.play(audio)
            
            for i = 1, numBullets do
                local currentAngle = startAngle + (i - 1) * angleStep
                local bullet = {
                    x = bulletX,
                    y = bulletY,
                    dx = math.cos(currentAngle) * self.bulletSpeed,
                    dy = math.sin(currentAngle) * self.bulletSpeed,
                    sprite = self.bulletSprite,
                    hitbox = Hitbox.new(bulletX, bulletY, 10, 10)
                }
                table.insert(self.bullets, bullet)
            end
            
            -- End attack
            self:resetStats()
        end
    else
        -- Normal behavior when not in special attack
        self:movement(dt)
        
        -- Normal shooting
        if self.fireCooldown > 0 then
            self.fireCooldown = self.fireCooldown - dt
        else
            self:shoot()
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
    
    -- Update hurtbox position
    self.hurtbox:update(self.x - 38, self.y - 32)
end

-- Helper function for shotgun blast
function Luca:shotgunBlast()
    local gunLength = self.gunSprite:getWidth() / 2 * 0.2
    local bulletX = self.x + math.cos(self.gunAngle) * gunLength
    local bulletY = self.y + math.sin(self.gunAngle) * gunLength
    
    -- Shotgun blast - all pellets in one direction with spread
    local angleSpread = math.rad(30)  -- Keep the 20 degree spread
    local numBullets = 6
    local startAngle = self.gunAngle - angleSpread / 2
    local angleStep = angleSpread / (numBullets - 1)
    
    -- Sound effect
    local audio = love.audio.newSource("assets/Audio/ShotgunBlast.wav", "static")
    audio:setVolume(0.03)
    love.audio.play(audio)
    
    for i = 1, numBullets do
        local currentAngle = startAngle + (i - 1) * angleStep
        local bullet = {
            x = bulletX,
            y = bulletY,
            dx = math.cos(currentAngle) * self.bulletSpeed,
            dy = math.sin(currentAngle) * self.bulletSpeed,
            sprite = self.bulletSprite,
            hitbox = Hitbox.new(bulletX, bulletY, 10, 10)
        }
        table.insert(self.bullets, bullet)
    end
end

-- Determine ambush position for big attack
function Luca:determineAmbushPosition()
    local width = love.graphics.getWidth()
    local height = love.graphics.getHeight()
    local padding = 150
    
    -- Determine which side to attack from (closest to player)
    local distToLeft = player.x
    local distToRight = width - player.x
    local distToTop = player.y
    local distToBottom = height - player.y
    
    local minDist = math.min(distToLeft, distToRight, distToTop, distToBottom)
    
    -- Position just outside the nearest edge
    if minDist == distToLeft then
        -- Left edge
        self.x = -padding
        self.y = player.y + math.random(-50, 50)  -- REDUCED randomization
    elseif minDist == distToRight then
        -- Right edge
        self.x = width + padding
        self.y = player.y + math.random(-50, 50)  -- REDUCED randomization
    elseif minDist == distToTop then
        -- Top edge
        self.x = player.x + math.random(-50, 50)  -- REDUCED randomization
        self.y = -padding
    else
        -- Bottom edge
        self.x = player.x + math.random(-50, 50)  -- REDUCED randomization
        self.y = height + padding
    end
    
    -- Set gun angle to face player
    self.gunAngle = math.atan2(player.y - self.y, player.x - self.x)
end

-- Fire ambush shot for big attack
function Luca:ambushShot()
    -- Show a warning effect at the edge
    -- (You would add visual effects here)
    
    local gunLength = self.gunSprite:getWidth() / 2 * 0.2
    local bulletX = self.x + math.cos(self.gunAngle) * gunLength
    local bulletY = self.y + math.sin(self.gunAngle) * gunLength
    
    -- Shotgun blast
    local angleSpread = math.rad(30)  -- CHANGED: 45 to 40 degree spread
    local numBullets = 6
    local startAngle = self.gunAngle - angleSpread / 2
    local angleStep = angleSpread / (numBullets - 1)
    
    -- Sound effect
    local audio = love.audio.newSource("assets/Audio/ShotgunBlast.wav", "static")
    audio:setVolume(0.03)
    love.audio.play(audio)
    
    for i = 1, numBullets do
        local currentAngle = startAngle + (i - 1) * angleStep
        local bullet = {
            x = bulletX,
            y = bulletY,
            dx = math.cos(currentAngle) * self.bulletSpeed,
            dy = math.sin(currentAngle) * self.bulletSpeed,
            sprite = self.bulletSprite,
            hitbox = Hitbox.new(bulletX, bulletY, 10, 10)
        }
        table.insert(self.bullets, bullet)
    end
end

-- Update bullets
function Luca:updateBullets(dt)
    for i = #self.bullets, 1, -1 do
        local b = self.bullets[i]
        b.x = b.x + b.dx * dt
        b.y = b.y + b.dy * dt
        
        -- Ensure every bullet has a hitbox
        if not b.hitbox then
            b.hitbox = Hitbox.new(b.x - 5, b.y - 5, 10, 10)
        else
            b.hitbox.x = b.x - 5  -- Move hitbox with bullet
            b.hitbox.y = b.y - 5
        end
        
        -- Check for collision with player
        if b.hitbox:detectcollision(player.hurtbox) and not player.invincible then
            -- Apply damage (normal or double based on bullet.damage)
            local damageMult = b.damage or 1
            player.health = player.health - (player.damage_taken * damageMult)
            
            -- Activate invincibility
            player.invincible = true
            player.invincibilityTimer = player.invincibilityTime
            
            -- Start screen shake
            player.screenshake = 10

            -- Play hit sound effect
            local audio = love.audio.newSource("assets/Audio/PlayerHit.mp3", "static")
            audio:setVolume(0.1)
            love.audio.play(audio)

            table.remove(self.bullets, i)  -- Remove bullet on hit
            goto continue  -- Skip the rest of this iteration
        end
        
        local bulletModule = require("bullet")
        if bulletModule and bulletModule.list then
            for j = #bulletModule.list, 1, -1 do
                local pb = bulletModule.list[j]
                if pb.hitbox and pb.hitbox:detectcollision(self.hurtbox) then
                    self.health = self.health - player.damage  -- Deal damage to Luca
                    
                    -- Knockback Direction
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
        if b.x < -300 or b.x > love.graphics.getWidth() + 300 or 
           b.y < -300 or b.y > love.graphics.getHeight() + 300 then
            table.remove(self.bullets, i)
        end
        ::continue::
    end
end

-- Draw Function
function Luca:draw()
    -- Draw the boss
    love.graphics.draw(self.sprite, self.x, self.y, 0, 0.2, 0.2, self.sprite:getWidth()/2, self.sprite:getHeight()/2)

    -- Draw the rotating gun
    love.graphics.draw(self.gunSprite, self.x, self.y, self.gunAngle, 0.2, 0.2, 0, self.gunSprite:getHeight()/2)
    
    -- Draw bullets
    for _, bullet in ipairs(self.bullets) do
        love.graphics.draw(bullet.sprite, bullet.x, bullet.y, 0, 0.7, 0.7, bullet.sprite:getWidth()/2, bullet.sprite:getHeight()/2)
    end
    
    -- Draw health bar
    local healthBarWidth = 200
    local healthBarHeight = 20
    local healthBarX = love.graphics.getWidth()/2 - healthBarWidth/2
    local healthBarY = 20
    
    -- Health bar background
    love.graphics.setColor(0.3, 0.3, 0.3)
    love.graphics.rectangle("fill", healthBarX, healthBarY, healthBarWidth, healthBarHeight)
    
    -- Health bar fill
    local healthPercentage = self.health / 75 -- 75 is max health
    love.graphics.setColor(0.8, 0.2, 0.2)
    love.graphics.rectangle("fill", healthBarX, healthBarY, healthBarWidth * healthPercentage, healthBarHeight)
    
    -- Health bar border
    love.graphics.setColor(0.1, 0.1, 0.1)
    love.graphics.rectangle("line", healthBarX, healthBarY, healthBarWidth, healthBarHeight)
    
    -- Boss name above health bar
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(self.name, healthBarX + healthBarWidth/2 - 40, healthBarY - 20)
    
    --[[] Debug: draw hurtbox
    if debug then
        love.graphics.setColor(1, 0, 0, 0.5)
        love.graphics.rectangle("fill", self.hurtbox.x, self.hurtbox.y, self.hurtbox.width, self.hurtbox.height)
        love.graphics.setColor(1, 1, 1, 1)  -- Reset color
    end]]--
    
    -- Reset color
    love.graphics.setColor(1, 1, 1)
    
    -- Visual indicators for special attack states
    --[[if self.specialAttack then
        if self.attackPhase == "cocking" then
            -- Show charging effect for Attack 3
            local chargeProgress = 1 - (self.cockingTimer / 3)
            local radius = 50 * chargeProgress
            love.graphics.setColor(0.8, 0.6, 0.1, 0.5)
            love.graphics.circle("fill", self.x, self.y, radius)
            love.graphics.setColor(1, 1, 1)
        elseif self.attackPhase == "ambushing" and self.ambushTimer < 0.5 then
            -- Warning flash for ambush attacks
            love.graphics.setColor(1, 0, 0, 0.3)
            if self.x < 0 then -- Left edge
                love.graphics.rectangle("fill", 0, self.y - 50, 100, 100)
            elseif self.x > love.graphics.getWidth() then -- Right edge
                love.graphics.rectangle("fill", love.graphics.getWidth() - 100, self.y - 50, 100, 100)
            elseif self.y < 0 then -- Top edge
                love.graphics.rectangle("fill", self.x - 50, 0, 100, 100)
            elseif self.y > love.graphics.getHeight() then -- Bottom edge
                love.graphics.rectangle("fill", self.x - 50, love.graphics.getHeight() - 100, 100, 100)
            end
            love.graphics.setColor(1, 1, 1)
        end]]--
    end


-- Full Reset Function: Reverts all stats to base values
function Luca:fullReset()
    -- Base stats
    self.health = 75
    self.baseSpeed = 350
    self.speed = 350
    self.fireRate = 1.2
    self.fireCooldown = 0
    self.bulletSpeed = 400
    
    -- Position reset (centered at top of screen)
    self.x = love.graphics.getWidth() / 2
    self.y = -100
    
    -- Attack timers
    self.attackTimer = math.random(5, 6)
    self.repositionTimer = math.random(3, 5)
    
    -- Attack state flags
    self.specialAttack = false
    self.halfHealthTriggered = false
    self.isRepositioning = false
    self.attackPhase = nil
    
    -- Clear all bullets
    self.bullets = {}
    
    -- Reset gun angle
    self.gunAngle = 0
    
    -- Reset knockback values if they exist
    self.knockbackX = 0
    self.knockbackY = 0
    self.knockbackTimer = 0
    
    -- Reset alive status
    self.alive = true
    
    -- Reset any remaining special attack variables
    self.cockingTimer = 0
    self.delayTimer = 0
    self.ambushCount = 0
    self.ambushTimer = 0
    self.shotTimer = 0
    self.shotPairCount = 0
    
    -- Reset targeting
    self.targetX = self.x
    self.targetY = self.y
    self.dashTargetX = nil
    self.dashTargetY = nil
    self.exitX = nil
    self.exitY = nil
end

return Luca