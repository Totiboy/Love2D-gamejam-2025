Hitbox = {}

function Hitbox.new(x,y,width,height)
    local instance = setmetatable({}, {__index = Hitbox})
    instance.x = x
    instance.y = y
    instance.width = width
    instance.height = height
    return instance
end

function Hitbox:detectcollision(hurtbox)
    if(self.x < hurtbox.x + hurtbox.width and
    self.x + self.width > hurtbox.x and
    self.y <hurtbox.y + hurtbox.height and
    self.y + self.height > hurtbox.y) then
        print("gottem!")
    end

end

function Hitbox:draw()
    love.graphics.setColor(1,0,0)
    love.graphics.rectangle("line",self.x,self.y,self.width,self.height)
end

return Hitbox