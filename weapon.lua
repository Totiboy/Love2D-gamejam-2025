weapon ={}
--updates position and direction of the GUN according to the player position and the mouse's
function weapon:update()
    self.x = player.x+player.sprite:getWidth()*.25/2
    self.y = player.y+player.sprite:getHeight()*.25/2
    self.sprite = love.graphics.newImage("assets/Pistol.png")
    self.angle = math.atan2(love.mouse.getY()-self.y,love.mouse.getX()-self.x)
end

--draws the GUN
function weapon:draw()
    love.graphics.draw(self.sprite,self.x,self.y,self.angle,.25,.25,0,self.sprite:getHeight()/2)
end

return weapon