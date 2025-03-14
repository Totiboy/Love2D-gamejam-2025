love = require("love")
player = require("player")

function love.load()
    player:load()
end

function love.update(dt)
    player:move(dt)
end

function love.draw()
    player:draw()
end
