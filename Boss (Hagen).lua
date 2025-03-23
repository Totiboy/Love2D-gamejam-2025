player = require("player")
hitbox = require("hitbox")
hurtbox = require("hurtbox")
HollowHagen = {}

function HollowHagen:load()
    self.name = "Hollow Hagen"
    self.health = 75
    self.baseSpeed = 250  -- Slightly slower than player
    self.speed = 250
    self.fireRate = 0.8   -- Slower fire rate than shotgun
    self.fireCooldown = 0
    self.bulletSpeed = 1000
    self.sprite = love.graphics.newImage("assets/Bosses/Hollow Hagen.png")
    self.gunSprite = love.graphics.newImage("assets/Bosses/M1 Carbine.png")
    self.bulletSprite = love.graphics.newImage("assets/EnemyBullet.png")
    self.x = love.graphics.getWidth() / 2
    self.y = -100
    self.attackTimer = math.random(5, 6)  -- 5-6 seconds interval
    self.specialAttack = false
    self.halfHealthTriggered = false
    self.bullets = {}
    self.alive = true
    self.gunAngle = 0
    self.hurtbox = HurtBox.new(self.x, self.y, self.sprite:getWidth()/5, self.sprite:getHeight()/5)
    
    -- Add waddle motion variables
    self.waddleTimer = 0
    self.waddleDirection = 1
    self.waddleSpeed = 10
    self.waddleAmount = 0.05
    
    -- Ricochet bullets for big attack
    self.ricochetBullets = {}
end

-- General AI: Movement
function HollowHagen:movement(dt)
    local playerPos = self:getPlayerPosition()
    local distanceToPlayer = self:distanceToPlayer()
    
    -- Keep distance from player (further than Diamante)
    local preferredDistance = 500
    
    -- If player is near edges, boss moves to center, if player is at center, boss moves to edges
    local isPlayerAtEdge = self:isPlayerAtEdge()
    local moveToCenter = isPlayerAtEdge
    
    if not self.specialAttack then
        if moveToCenter then
            -- Move to center
            local centerX, centerY = love.graphics.getWidth() / 2, love.graphics.getHeight() / 2
            local dx, dy = centerX - self.x, centerY - self.y
            local dist = math.sqrt(dx^2 + dy^2)
            
            if dist > 50 then  -- Only move if not already at center
                self.x = self.x + (dx / dist) * self.speed * dt
                self.y = self.y + (dy / dist) * self.speed * dt
            end
        else
            -- Move to edge opposite of player
            local screenWidth, screenHeight = love.graphics.getWidth(), love.graphics.getHeight()
            local targetX, targetY
            
            -- Determine which quadrant to move to (opposite of player)
            if player.x < screenWidth / 2 then
                targetX = screenWidth * 0.8  -- Right side
            else
                targetX = screenWidth * 0.2  -- Left side
            end
            
            if player.y < screenHeight / 2 then
                targetY = screenHeight * 0.8  -- Bottom side
            else
                targetY = screenHeight * 0.2  -- Top side
            end
            
            local dx, dy = targetX - self.x, targetY - self.y
            local dist = math.sqrt(dx^2 + dy^2)
            
            if dist > 50 then
                self.x = self.x + (dx / dist) * self.speed * dt
                self.y = self.y + (dy / dist) * self.speed * dt
            end
        end
        
        -- Maintain distance from player
        local dx, dy = player.x - self.x, player.y - self.y
        local dist = math.sqrt(dx^2 + dy^2)
        
        if dist < preferredDistance - 100 then
            -- Move away from player if too close
            self.x = self.x - (dx / dist) * self.speed * 1.2 * dt
            self.y = self.y - (dy / dist) * self.speed * 1.2 * dt
        elseif dist > preferredDistance + 100 then
            -- Move toward player if too far
            self.x = self.x + (dx / dist) * self.speed * 0.8 * dt
            self.y = self.y + (dy / dist) * self.speed * 0.8 * dt
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

-- Check if player is at edge of screen
function HollowHagen:isPlayerAtEdge()
    local edgeThreshold = 200
    local screenWidth, screenHeight = love.graphics.getWidth(), love.graphics.getHeight()
    
    return player.x < edgeThreshold or 
           player.x > screenWidth - edgeThreshold or
           player.y < edgeThreshold or
           player.y > screenHeight - edgeThreshold
end

-- Get player position
function HollowHagen:getPlayerPosition()
    return {x = player.x, y = player.y}
end

-- Calculate distance to player
function HollowHagen:distanceToPlayer()
    local dx, dy = player.x - self.x, player.y - self.y
    return math.sqrt(dx^2 + dy^2)
end

-- General AI: Shooting
function HollowHagen:shoot(dt, angle)
    if self.fireCooldown <= 0 then
        self.fireCooldown = self.fireRate -- Reset cooldown
        
        -- Use provided angle or default to gun angle
        local shootAngle = angle or self.gunAngle
        
        local gunLength = self.gunSprite:getWidth() / 2 * 0.2 -- Adjust if needed (0.2 is scale of gun sprite)
        local bulletX = self.x + math.cos(shootAngle) * gunLength
        local bulletY = self.y + math.sin(shootAngle) * gunLength
        
        -- Play rifle shot sound
        local audio = love.audio.newSource("assets/Audio/RifleShot.wav", "static")
        audio:setVolume(0.05)
        love.audio.play(audio)
        
        local bullet = {
            x = bulletX,
            y = bulletY,
            dx = math.cos(shootAngle) * self.bulletSpeed,
            dy = math.sin(shootAngle) * self.bulletSpeed,
            sprite = self.bulletSprite,
            hitbox = Hitbox.new(bulletX, bulletY, 10, 10)
        }
        table.insert(self.bullets, bullet)
    end
end

-- Special Attack Handler
function HollowHagen:triggerSpecialAttack()
    self.specialAttack = true
    
    -- Decide which attack to use (4th attack only available at half health)
    --local attackOptions = self.halfHealthTriggered and 4 or 3
    --local attackType = math.random(1, attackOptions)
    local attackType = 4  -- For testing
    
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

-- ATK #1: Stands still for 0.4 secs and shoots a big fat one
function HollowHagen:attack1()
    self.specialAttack = true
    self.attackPhase = "charging"
    self.chargeTimer = 0.4  -- Stand still for 0.4 seconds
    
    -- Force boss to stop
    self.originalSpeed = self.speed
    self.speed = 0
end

-- ATK #2: Spawns 3 enemies or buffs existing ones
function HollowHagen:attack2()
    self.specialAttack = true
    self.attackPhase = "summoning"
    
    local enemies = enemy:getEnemies()
    
    if #enemies == 0 or #enemies < 3 then
        -- Spawn 3 enemies
        self.enemySpawnCount = 0
        self.enemySpawnTimer = 0.3  -- Time between spawns
        self.enemiesToSpawn = 3
    else
        -- Buff existing enemies
        self.attackPhase = "buffing"
        self:buffEnemies()
    end
end

-- ATK #3: Stands still and shoot 3 shots consecutively
function HollowHagen:attack3()
    self.specialAttack = true
    self.attackPhase = "rapid_shooting"
    
    -- Force boss to stop
    self.originalSpeed = self.speed
    self.speed = 0
    
    -- Setup for triple shot
    self.shotsFired = 0
    self.rapidFireTimer = 0.1  -- Initial delay before first shot
    self.rapidFireDelay = 0.15  -- Delay between shots
end

-- Big ATK: Shoot 3 shots that ricochet (5 bounces each)
function HollowHagen:bigAttack()
    self.specialAttack = true
    self.attackPhase = "ricochet_shooting"
    
    -- Force boss to slow down
    self.originalSpeed = self.speed
    self.speed = self.speed / 2
    
    -- Setup for ricochet shots
    self.ricochetShotsFired = 0
    self.ricochetTimer = 0.2  -- Initial delay
end

-- Create a ricochet bullet
function HollowHagen:createRicochetBullet(angle)
    local gunLength = self.gunSprite:getWidth() / 2 * 0.2
    local bulletX = self.x + math.cos(angle) * gunLength
    local bulletY = self.y + math.sin(angle) * gunLength
    
    -- Create a special bullet that can ricochet
    local bullet = {
        x = bulletX,
        y = bulletY,
        dx = math.cos(angle) * self.bulletSpeed * 0.8,  -- Slightly slower
        dy = math.sin(angle) * self.bulletSpeed * 0.8,
        sprite = self.bulletSprite,
        hitbox = Hitbox.new(bulletX, bulletY, 12, 12),  -- Slightly larger hitbox
        bounceCount = 0,
        maxBounces = 5,
        ricochet = true
    }
    
    table.insert(self.bullets, bullet)
    
    -- Play enhanced rifle sound
    local audio = love.audio.newSource("assets/Audio/RifleShot.wav", "static")
    audio:setVolume(0.08)
    audio:setPitch(0.8)  -- Lower pitch for ricochet shots
    love.audio.play(audio)
end

-- Buff existing enemies
function HollowHagen:buffEnemies()
    local enemiesList = enemy:getEnemies()
    
    for _, e in ipairs(enemiesList) do
        -- Increase speed, shot speed and fire rate
        e.speed = e.speed * 1.3
        if e.shootingTimer then
            -- Make them shoot faster
            e.shootingTimer = e.shootingTimer * 0.7
        end
    end
    
    -- Visual effect to show enemies are buffed
    -- Play buff sound
    local audio = love.audio.newSource("assets/Audio/ButtonClick.wav", "static")
    audio:setVolume(0.1)
    love.audio.play(audio)
    
    -- Finish this attack phase
    self:resetStats()
end

-- Reset Stats After Special Attack
function HollowHagen:resetStats()
    if self.originalSpeed then
        self.speed = self.originalSpeed
        self.originalSpeed = nil
    else
        self.speed = self.baseSpeed
    end
    
    self.fireRate = 0.8      -- Reset to base fire rate
    self.bulletSpeed = 700
    self.specialAttack = false
    self.attackPhase = nil
    self.attackTimer = math.random(5, 6)
end

-- Update Function
function HollowHagen:update(dt)
    -- Check if dead
    if self.health <= 0 then
        self.alive = false
        waves:nextWave()
        return
    end
    
    -- Check for half-health special ability unlock
    if self.health <= 37.5 and not self.halfHealthTriggered then
        self.halfHealthTriggered = true
    end
    
    -- Update gun angle to face player
    local dx, dy = player.x - self.x, player.y - self.y
    self.gunAngle = math.atan2(dy, dx) -- Calculate angle to player
    
    -- Update hurtbox position
    self.hurtbox:update(self.x - 33, self.y - 50)
    
    -- Handle special attacks
    if self.specialAttack then
        if self.attackPhase == "charging" then
            -- Attack 1 - Charge phase
            self.chargeTimer = self.chargeTimer - dt
            
            if self.chargeTimer <= 0 then
                -- Fire the big shot
                local bigShotSize = 1.5  -- Bullet is 1.5x normal size
                
                -- Create a bigger bullet
                local gunLength = self.gunSprite:getWidth() / 2 * 0.2
                local bulletX = self.x + math.cos(self.gunAngle) * gunLength
                local bulletY = self.y + math.sin(self.gunAngle) * gunLength
                
                -- Play enhanced rifle sound
                local audio = love.audio.newSource("assets/Audio/RifleShot.wav", "static")
                audio:setVolume(0.1)
                audio:setPitch(0.7)  -- Lower pitch for big shot
                love.audio.play(audio)
                
                local bullet = {
                    x = bulletX,
                    y = bulletY,
                    dx = math.cos(self.gunAngle) * self.bulletSpeed * 1.2,
                    dy = math.sin(self.gunAngle) * self.bulletSpeed * 1.2,
                    sprite = self.bulletSprite,
                    hitbox = Hitbox.new(bulletX, bulletY, 15, 15),  -- Bigger hitbox
                    scale = bigShotSize  -- For drawing
                }
                table.insert(self.bullets, bullet)
                
                -- Reset after firing
                self:resetStats()
            end
        elseif self.attackPhase == "summoning" then
            -- Attack 2 - Spawning enemies
            self.enemySpawnTimer = self.enemySpawnTimer - dt
            
            if self.enemySpawnTimer <= 0 and self.enemySpawnCount < self.enemiesToSpawn then
                -- Spawn an enemy
                enemy:spawn()
                self.enemySpawnCount = self.enemySpawnCount + 1
                self.enemySpawnTimer = 0.3  -- Reset timer
                
                -- Reset after spawning all enemies
                if self.enemySpawnCount >= self.enemiesToSpawn then
                    self:resetStats()
                end
            end
        elseif self.attackPhase == "rapid_shooting" then
            -- Attack 3 - Triple shot
            self.rapidFireTimer = self.rapidFireTimer - dt
            
            if self.rapidFireTimer <= 0 and self.shotsFired < 3 then
                -- Force immediate fire
                self.fireCooldown = 0
                self:shoot(dt)
                
                self.shotsFired = self.shotsFired + 1
                self.rapidFireTimer = self.rapidFireDelay
                
                -- Reset after firing all shots
                if self.shotsFired >= 3 then
                    self:resetStats()
                end
            end
        elseif self.attackPhase == "ricochet_shooting" then
            -- Big Attack - Ricochet shots
            self.bulletSpeed = 1800
            self.ricochetTimer = self.ricochetTimer - dt
            
            if self.ricochetTimer <= 0 and self.ricochetShotsFired < 3 then
                -- Calculate slight spread for multiple shots
                local spreadAngle = 0.05  -- Small angle in radians
                
                if self.ricochetShotsFired == 0 then
                    -- First shot straight at player
                    self:createRicochetBullet(self.gunAngle)
                elseif self.ricochetShotsFired == 1 then
                    -- Second shot slightly to the left
                    self:createRicochetBullet(self.gunAngle - spreadAngle)
                else
                    -- Third shot slightly to the right
                    self:createRicochetBullet(self.gunAngle + spreadAngle)
                end
                
                self.ricochetShotsFired = self.ricochetShotsFired + 1
                self.ricochetTimer = 0.3  -- Time between ricochet shots
                
                -- Reset after firing all ricochet shots
                if self.ricochetShotsFired >= 3 then
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
            self:shoot(dt)
        end
        
        -- Special attack timer
        if self.attackTimer > 0 then
            self.attackTimer = self.attackTimer - dt
        else
            self:triggerSpecialAttack()
        end
    end
    
    -- Always update bullets
    self:updateBullets(dt)
end

-- Update bullets (with ricochet support)
function HollowHagen:updateBullets(dt)
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
            player.health = player.health - player.damage_taken  -- Player takes damage
            
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
        
        -- Handle bullet-to-boss collision
        local bulletModule = require("bullet")
        if bulletModule and bulletModule.list then
            for j = #bulletModule.list, 1, -1 do
                local pb = bulletModule.list[j]
                if pb.hitbox and pb.hitbox:detectcollision(self.hurtbox) then
                    self.health = self.health - player.damage  -- Deal damage to HollowHagen
                    
                    -- Knockback
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
                    
                    table.remove(bulletModule.list, j)
                    break
                end
            end
        end
        
        -- Handle ricochet bullets
        if b.ricochet then
            local screenWidth = love.graphics.getWidth()
            local screenHeight = love.graphics.getHeight()
            local bounced = false
            
            -- Check for wall collisions and bounce
            if b.x < 0 then
                b.dx = math.abs(b.dx)  -- Bounce right
                b.x = 0
                bounced = true
            elseif b.x > screenWidth then
                b.dx = -math.abs(b.dx)  -- Bounce left
                b.x = screenWidth
                bounced = true
            end
            
            if b.y < 0 then
                b.dy = math.abs(b.dy)  -- Bounce down
                b.y = 0
                bounced = true
            elseif b.y > screenHeight then
                b.dy = -math.abs(b.dy)  -- Bounce up
                b.y = screenHeight
                bounced = true
            end
            
            -- If bounced, increment counter and play sound
            if bounced then
                b.bounceCount = b.bounceCount + 1
                
                -- Play bounce sound
                local audio = love.audio.newSource("assets/Audio/Footstep4.wav", "static")
                audio:setVolume(0.05)
                love.audio.play(audio)
                
                -- Remove if max bounces reached
                if b.bounceCount >= b.maxBounces then
                    table.remove(self.bullets, i)
                    goto continue
                end
            end
        else
            -- Remove non-ricochet bullets that go off-screen
            if b.x < -50 or b.x > love.graphics.getWidth() + 50 or 
               b.y < -50 or b.y > love.graphics.getHeight() + 50 then
                table.remove(self.bullets, i)
            end
        end
        
        ::continue::
    end
end

-- Draw Function
function HollowHagen:draw()
    -- Draw the boss
    love.graphics.draw(self.sprite, self.x, self.y, 0, 0.2, 0.2, self.sprite:getWidth()/2, self.sprite:getHeight()/2)
    
    -- Draw the rotating gun
    love.graphics.draw(self.gunSprite, self.x, self.y, self.gunAngle, 0.2, 0.2, self.gunSprite:getWidth()/2, self.gunSprite:getHeight()/2)
    
    -- Draw bullets
    for _, b in ipairs(self.bullets) do
        local scale = b.scale or 0.5  -- Default scale if not specified
        love.graphics.draw(b.sprite, b.x, b.y, 0, scale, scale, b.sprite:getWidth()/2, b.sprite:getHeight()/2)
    end
    
    -- Draw health bar
    local healthBarWidth = 200
    local healthBarHeight = 20
    local healthX = love.graphics.getWidth() / 2 - healthBarWidth / 2
    local healthY = 50
    
    -- Health bar background
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.rectangle("fill", healthX, healthY, healthBarWidth, healthBarHeight)
    
    -- Health bar fill
    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle("fill", healthX, healthY, healthBarWidth * (self.health / 75), healthBarHeight)
    
    -- Health bar border
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("line", healthX, healthY, healthBarWidth, healthBarHeight)
    
    -- Draw boss name
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(self.name, healthX, healthY - 20)
    
    -- Reset color
    love.graphics.setColor(1, 1, 1)
    
    -- Debug: Draw hurtbox
     self.hurtbox:draw()
end

function HollowHagen:fullReset()
    self.health = 75
    self.speed = self.baseSpeed
    self.fireRate = 0.8
    self.fireCooldown = 0
    self.bulletSpeed = 700
    self.bullets = {}  -- Clear all bullets
    self.alive = true
    self.specialAttack = false
    self.halfHealthTriggered = false
    self.attackPhase = nil
    self.attackTimer = math.random(5, 6)
    self.x = love.graphics.getWidth() / 2  -- Respawn at the center
    self.y = -100
end

return HollowHagen