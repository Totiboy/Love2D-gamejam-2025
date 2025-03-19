local Button = {}

-- instantiating a new button
function Button.new(x, y, width, height, text)
    local instance = setmetatable({}, {__index = Button})
    instance.x = x
    instance.y = y
    instance.width = width
    instance.height = height
    instance.text = text
    instance.font = love.graphics.getFont()
    return instance
end

--drawing the button
function Button:draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    love.graphics.setColor(0, 0, 0)
    love.graphics.printf(self.text, self.x, (self.y+self.height/2) - self.font:getHeight()/2, self.width, "center")
end

--checking if the button is clicked and if it's in the range of the button rectangle
function Button:isClicked()
    if self.x < love.mouse.getX() and love.mouse.getX() < self.x + self.width and self.y < love.mouse.getY() and love.mouse.getY() < self.y + self.height then
        self.wasclicked = self.isclicked
        self.isclicked = love.mouse.isDown(1)
        if self.wasclicked == false and self.isclicked == true then
            local audio = love.audio.newSource("assets/Audio/ButtonClick.wav","stream")
            love.audio.play(audio)
            return true
        end
    end
end

return Button