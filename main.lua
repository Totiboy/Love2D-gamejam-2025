--loading libraries and setting up the game states
love = require("love")
player = require("player")
Gamestatesmanager = require("gamestatesmanager")
Button = require("Button")
bullet = require("bullet")
gun = require("weapon")
Game = Game()


--loading the game's necessary stuff
function love.load()
    StartButton = Button.new(love.graphics.getWidth()/2,love.graphics.getHeight()/2,200,100,"start")
    ResumeButton = Button.new(10,love.graphics.getHeight()-110,200,100,"Resume")
    
    --this line makes it so the game starts with the menu state.
    Game:changestates("menu")
    --------
    --this of course loads the player.
    player:load()

    locations = {1,2,3,4,5}
    
end

function love.update(dt)
    --this sets up the logic for different states.

    --menu state logic
    if Game.states.menu then
        if StartButton:isClicked() then
            Game:changestates("running")
        end
    end

    --running state logic --
    if Game.states.running then
        player:move(dt)
        gun:update()
        Firing() -- Replaced mousepressed with this
        bullet.reload() -- In Bullet.lua
        bullet.update(dt)
    end

    --pause state logic
    if Game.states.pause then
        if ResumeButton:isClicked() then
            Game:changestates("running")
        end
    end
    
    --selection state logic
    if Game.states.selection then
        
    end
end

--this displays different stuff on the screen based on the game state.
function love.draw()

    --the menu state
    if Game.states.menu then
        StartButton:draw()
    end

    --the running state
    if Game.states.running then
        love.graphics.setBackgroundColor(87/255, 151/255, 255/255)
        --drawing both the player and the bullets
        player:draw()
        bullet.draw()
        weapon:draw()
        --drawing the ammo displayer
        love.graphics.setColor(1,1,1)
        love.graphics.print("AMMO :"..ammo, 10, love.graphics.getHeight() - 100,0,4)
        --uh calling the reload function (do we really need one?)
        
    end

    --the pause state
    if Game.states.pause then
        love.graphics.setColor(1,1,1)
        love.graphics.print("PAUSED",300 ,210,0,10)
        ResumeButton:draw()
    end

    --selection state 
    if Game.states.selection then
        
    end
end


--if the escape key is pressed while the game is running , the game gets paused.
function love.keypressed(key)
    if Game.states.running then
        if key == "escape" then
            Game:changestates("pause")
        end
    end
end

function Firing() -- Replaced love.mousepressed with this so the button can be held down
    if love.mouse.isDown(1) and ammo > 0 then
        local mouseX, mouseY = love.mouse.getX(), love.mouse.getY()

        -- Gun barrel offset (Adjust this based on your sprite size)
        local barrelOffset = weapon.sprite:getWidth() * 0.25 -- Since scale is 0.25

        -- Calculate the exact bullet spawn position at the barrel tip
        local spawnX = weapon.x + math.cos(weapon.angle) * barrelOffset
        local spawnY = weapon.y + math.sin(weapon.angle) * barrelOffset

        -- Spawn the bullet from the barrel, not the player's center
        bullet.spawn(spawnX, spawnY, mouseX, mouseY, 500)
    end
end
-- Reload and Ammo Variables have been moved to Bullet