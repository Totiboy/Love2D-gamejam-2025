Hurtbox = require("hurtbox")
player = {}

--loading basic player stats
function player:load()
    self.x = 100
    self.y = 0
    self.health = 3
    self.height = 100
    self.sprite = love.graphics.newImage("assets/Cop (Fixed Export).png")
    self.width = 50
    self.speed = 200
    self.fire_rate = 0.4
    self.damage = 1
    self.health = 3
    self.max_ammo = 12
    self.bullet_speed = 500
    self.ammo = self.max_ammo
    self.damage_taken = 1
    self.passives = {}
    self.hurtbox = HurtBox.new(self.x,self.y,self.sprite:getWidth()/6.2,self.sprite:getHeight()/6.2)
    self.isded = false
-------------------------------------------------------------- DASH VARIABLES
    self.dash_speed = 1400   -- Speed during dash
    self.dash_duration = 0.1 -- How long the dash lasts
    self.dash_cooldown = 1 -- Time before dashing again
    self.dash_timer = 0
    self.cooldown_timer = 0
    self.is_dashing = false
    self.dir_x = 0
    self.dir_y = 0
-------------------------------------------------------------- WADDLE VARIABLES (Slight Tilts for the Illusion of Movement)
    self.waddle_timer = 0
    self.waddle_direction = 1 -- Controls the tilt direction
    self.waddle_speed = 10 -- Speed of the waddle effect
    self.waddle_amount = 0.05 -- How much the player tilts

    self.angle = 0
-------------------------------------------------------------- PLAYER HIT VARIABLES
    self.invincible = false
    self.invincibilityTime = 1  -- Time for invincibility
    self.invincibilityTimer = 0
    self.screenshake = 0  -- Track screenshake intensity

end

function player:move(dt)
    --THIS WHOLE BLOCK OF CODE'S PURPOSE IS TO SET THE DIRECTION OF THE MOVEMENT AND NORMALIZE IT USING THE PYTHAGOREAN THEOREM
    --------------------------------------------------------------
    d = {x = 0, y = 0}
    length = math.sqrt(d.x ^ 2 + d.y ^ 2)

    if length>0 then
        d.x = d.x / length
        d.y = d.y / length
    end

    if love.keyboard.isDown("right") or love.keyboard.isDown("d") then
        d.x = d.x + 1
    end
    if love.keyboard.isDown("left") or love.keyboard.isDown("a") then
        d.x = d.x - 1
    end
    if love.keyboard.isDown("up") or love.keyboard.isDown("w") then
        d.y = d.y - 1
    end
    if love.keyboard.isDown("down") or love.keyboard.isDown("s") then
        d.y = d.y + 1
    end
--------------------------------------------------------------------------
---this sets up the speed to correspond with the direction of the movement and deltatime
    self.x = self.x + self.speed * d.x * dt
    self.y = self.y + self.speed * d.y * dt
    self.hurtbox:update(self.x,self.y)
end

function player:update(dt)
    local mouseX, mouseY = love.mouse.getPosition()
    self.angle = math.atan2(mouseY - player.y, mouseX - player.x)

    -- Dash Cooldown Timer --
    if self.cooldown_timer > 0 then
        self.cooldown_timer = self.cooldown_timer - dt
    end
    -- Handle Invincibility Timer for when Hit
    if player.invincible then
        player.invincibilityTimer = player.invincibilityTimer - dt
        if player.invincibilityTimer <= 0 then
            player.invincible = false  -- ✅ Player can be hit again
        end
    end
    
    -- Handle Screenshake Effect
    if player.screenshake > 0 then
        player.screenshake = player.screenshake - dt * 30  -- ✅ Reduce shake over time
    end
    -------------------------------------- Handle Dashing -------------------------------------------------------------
    if self.is_dashing then
        self.dash_timer = self.dash_timer - dt
        if self.dash_timer <= 0 then
            self.is_dashing = false
            self.cooldown_timer = self.dash_cooldown
        end
        self.x = self.x + self.dir_x * self.dash_speed * dt
        self.y = self.y + self.dir_y * self.dash_speed * dt
        return -- Stop normal movement during dash
    end

    self:move(dt) -- Continue normal movement if not dashing

    -- Dash Activation
    if not self.is_dashing and self.cooldown_timer <= 0 and 
    (love.keyboard.isDown("space") or love.keyboard.isDown("lshift")) then
        self:startDash()
    end

    function playFootsteps()
        local sounds = {
            love.audio.newSource("assets/Audio/Footstep1.wav", "static"),
            love.audio.newSource("assets/Audio/Footstep2.wav", "static"),
            love.audio.newSource("assets/Audio/Footstep3.wav", "static"),
            love.audio.newSource("assets/Audio/Footstep4.wav", "static")
        }
        local randomIndex = love.math.random(1, #sounds)
        local sound = sounds[randomIndex]
        sound:setVolume(0.01)
        sound:play()
    end
-------------------------------------------- Waddle Movement ---------------------------------------------------------
    if d.x ~= 0 or d.y ~= 0 then -- Only waddle when moving
        self.waddle_timer = self.waddle_timer + dt * self.waddle_speed
        if self.waddle_timer >= 1 then
            self.waddle_timer = 0
            self.waddle_direction = -self.waddle_direction -- Swap tilt direction
            playFootsteps()
        end
    end
    ---------------------------------------------Handling HEALTH-----------------------------------------------------
    if self.health<=0 then
        self.isded = true
    end
end

----------------------------------------------- During Dash ---------------------------------------------------------
function player:startDash()
    local d = {x = 0, y = 0}

    if love.keyboard.isDown("right") or love.keyboard.isDown("d") then
        d.x = d.x + 1
    end
    if love.keyboard.isDown("left") or love.keyboard.isDown("a") then
        d.x = d.x - 1
    end
    if love.keyboard.isDown("up") or love.keyboard.isDown("w") then
        d.y = d.y - 1
    end
    if love.keyboard.isDown("down") or love.keyboard.isDown("s") then
        d.y = d.y + 1
    end

    -- Normalize direction
    local length = math.sqrt(d.x^2 + d.y^2)
    if length > 0 then
        self.dir_x, self.dir_y = d.x / length, d.y / length
        self.is_dashing = true
        self.dash_timer = self.dash_duration
    end
end

----------------------------------------------- Item Upgrades ---------------------------------------------------------
function player:applyUpgrades()
    -- Store base stats to reset before applying upgrades
    self.baseFireRate = self.baseFireRate or 0.4
    self.baseBulletSpeed = self.baseBulletSpeed or 500
    self.baseHealth = self.baseHealth or 3
    self.baseMaxAmmo = self.baseMaxAmmo or 12
    self.baseSpeed = self.baseSpeed or 200

    -- Reset stats to base values before applying upgrades
    self.fire_rate = self.baseFireRate
    self.bullet_speed = self.baseBulletSpeed
    self.health = self.baseHealth
    self.max_ammo = self.baseMaxAmmo
    self.speed = self.baseSpeed

    -- Apply active upgrades
    for _, upgrade in ipairs(self.passives) do
        if upgrade == "Trigger Crank (+Fire Rate)" then
            self.fire_rate = self.fire_rate - 0.1
        elseif upgrade == "Long Barrell (+Bullet Speed)" then
            self.bullet_speed = self.bullet_speed + 250
        elseif upgrade == "Army Helmet (+Health)" then
            self.health = self.health + 1
        elseif upgrade == "Extended Magazine (+Ammo)" then
            self.max_ammo = self.max_ammo + 8
        elseif upgrade == "Foregrip (+Movement Speed)" then
            self.speed = self.speed * 1.2
        end
    end
end



--this draws the player
function player:draw()
    love.graphics.setColor(1,1,1)
    -- love.graphics.draw(self.sprite, self.x, self.y, 0, 0.25)
    love.graphics.draw(self.sprite, self.x, self.y, self.waddle_direction * self.waddle_amount, 0.2, 0.2, self.width / 2, self.height / 2)

    -- ✅ Apply Screenshake Offset
    local shakeX = math.random(-player.screenshake, player.screenshake)
    local shakeY = math.random(-player.screenshake, player.screenshake)

    love.graphics.draw(player.sprite, player.x + shakeX, player.y + shakeY, player.waddle_direction * player.waddle_amount, 0.2, 0.2, player.width / 2, player.height / 2)

    -- ✅ Blink effect for invincibility (flashes every 0.1s)
    if player.invincible and math.floor(player.invincibilityTimer * 10) % 2 == 0 then
        love.graphics.setColor(1, 1, 1, 0.2)  -- Make player semi-transparent
    else
        love.graphics.setColor(1, 1, 1, 1)
    end
end

return player