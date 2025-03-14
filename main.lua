--loading libraries and setting up the game states
love = require("love")
player = require("player")
Gamestatesmanager = require("gamestatesmanager")
Button = require("Button")
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
    end

    --pause state logic
    if Game.states.pause then
        if ResumeButton:isClicked() then
            Game:changestates("running")
        end
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
        player:draw()
    end

    --the pause state
    if Game.states.pause then
        love.graphics.setColor(1,1,1)
        love.graphics.print("PAUSED",300 ,210,0,10)
        ResumeButton:draw()
    end
end

--if the escape key is pressed while the game is running , the game gets paused.
function love.keypressed(key)
    if key == "escape" then
        if Game.states.running then
            Game:changestates("pause")
        end
    end
end
