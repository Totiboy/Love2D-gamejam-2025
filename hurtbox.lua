HurtBox = {}

--creates a new hurtbox object
function HurtBox.new(x,y,width,height)
    local instance = setmetatable({}, {__index = HurtBox})
    instance.x = x
    instance.y = y
    instance.width = width
    instance.height = height
    return instance
end

--detects collision with a given hitbox
function HurtBox:detectcollision(hitbox)
    if(self.x < hitbox.x + hitbox.width and
    self.x + self.width > hitbox.x and
    self.y <hitbox.y + hitbox.height and
    self.y + self.height > hitbox.y) then
        return true
    end
end
--updates the hurtbox object's position
function HurtBox:update(x,y)
    self.x = x
    self.y = y
end

--draws the hurtbox (used for debugging and seeing wtf is wrong with the code)
function HurtBox:draw()
    love.graphics.setColor(0,1,0)
    love.graphics.rectangle("line",self.x,self.y,self.width,self.height)
end

return HurtBox