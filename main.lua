love = require("love")
player = require("player")
bullet = require("bullet")

function love.load()
    player:load()
end

function love.update(dt)
    player:move(dt)
    if love.mouse.isDown(1) then -- Left mouse button is held down
        local mouseX, mouseY = love.mouse.getPosition()
        bullet.spawn(player.x, player.y, mouseX, mouseY, 500) -- Example speed
    end
    bullet.update(dt)
end

function love.draw()
    player:draw()
    bullet.draw()
end