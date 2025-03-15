--loading libraries and setting up the game states
love = require("love")
player = require("player")
Gamestatesmanager = require("gamestatesmanager")
Button = require("Button")
bullet = require("bullet")
gun = require("weapon")
local ammo = 10
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
    
end

function love.update(dt)
    --this sets up the logic for different states.

    --menu state logic
    if Game.states.menu then
        if StartButton:isClicked() then
            Game:changestates("running")
        end
    end

    --running state logic
    if Game.states.running then
        player:move(dt)
        gun:update()
        Reload()
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
        love.graphics.print("AMMO :"..ammo,10,love.graphics.getHeight()-100,0,4)
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

--limiting the shooting you can do lmao
function love.mousepressed(x,y,istouch)
    x = love.mouse.getX()
    y = love.mouse.getY()
    if istouch == 1 and Game.states.running and ammo>0 then
        bullet.spawn(player.x,player.y,x,y,500)
        ammo = ammo-1
    end
end

--do I need to explain this?
function Reload()
    if love.keyboard.isDown("r") then
        ammo = 10
    end
end
