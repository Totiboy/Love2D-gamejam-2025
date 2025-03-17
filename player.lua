player = {}

--loading basic player stats
function player:load()
    self.x = 100
    self.y = 0
    self.health = 100
    self.sprite = love.graphics.newImage("assets/Cop.png")
    self.speed = 300
    self.candash = true
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
---------------------------------------------------------------------------
---this sets up the speed to correspond with the direction of the movement and deltatime
    self.x = self.x + self.speed * d.x * dt
    self.y = self.y + self.speed * d.y * dt
    
end

--this draws the player (who is a white square for now)
function player:draw()
    love.graphics.setColor(1,1,1)
    love.graphics.draw(self.sprite, self.x, self.y, 0, 0.25)
end
return player