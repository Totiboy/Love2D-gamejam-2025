weapon = {}
weapon.sprite = love.graphics.newImage("assets/Pistol.png") --I was told it was good practice to leave this lil line here.


--updates position and direction of the GUN according to the player position and the mouse's
function weapon:update()
    self.x = player.x + player.sprite:getWidth() * 0.2/2
    self.y = player.y + player.sprite:getHeight() * 0.2/2
    self.sprite = love.graphics.newImage("assets/Pistol.png")
    self.angle = math.atan2(love.mouse.getY() - self.y, love.mouse.getX() - self.x)
end

--draws the GUN
function weapon:draw()
    love.graphics.draw(self.sprite, self.x, self.y, self.angle, 0.2, 0.2, 0, self.sprite:getHeight()/2)
end

return weapon