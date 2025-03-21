--loading libraries and setting up the game states
love = require("love")
player = require("player")
Gamestatesmanager = require("gamestatesmanager")
Button = require("Button")
bullet = require("bullet")
gun = require("weapon")
PICKTHEMITEMS = require("UpgradesManager")
Game = Game()
enemy = require("enemy")



--loading the game's necessary stuff
function love.load()
    TITLE  = "Operation - Quad-Father"
    titlefont = love.graphics.newFont("assets/Fonts/ka1.ttf",40)
    normalfont = love.graphics.newFont("assets/Fonts/alagard.ttf",20)
    StartButton = Button.new(love.graphics.getWidth()/2-100,love.graphics.getHeight()/2+100,200,100,"start",30)
    ResumeButton = Button.new(10,love.graphics.getHeight()-110,200,100,"Resume",20)
    selectbutton1 = Button.new(200,500,200,100,"Select 1",20)
    selectbutton2 = Button.new(200+300,500,200,100,"Select 2",20)
    selectbutton3 = Button.new(200+300+300,500,200,100,"Select 3",20)

    
    
    --this line makes it so the game starts with the menu state.
    Game:changestates("menu")
    --------
    --this of course loads the player.
    player:load()
-- Loads Items that change stats/mechanics
    player:applyUpgrades()

    -- Enemy Spawn Timer
    enemySpawnTimer = 0
    enemySpawnInterval = 2  -- Spawns every 2 seconds
end

function love.update(dt)
    --this sets up the logic for different states.

    --menu state logic
    if Game.states.menu then
        if StartButton:isClicked() then
            Game:changestates("selection")
        end
    end

    --running state logic
    if Game.states.running then
        player:move(dt)
        player:update(dt)
        gun:update()
        Firing() -- Replaced mousepressed with this
        bullet.reload() -- In Bullet.lua
        bullet.update(dt)
        enemy:update(dt)
        enemy:updateBullets(dt)
        --killing the player
        if player.isded then
            Game:changestates("menu")
        end

        -- Enemy spawning logic (Fixed)
        enemySpawnTimer = enemySpawnTimer + dt
        if enemySpawnTimer >= enemySpawnInterval then
            enemy.spawn()
            enemySpawnTimer = 0  -- Reset timer
        end
    end
    
    --pause state logic
    if Game.states.pause then
        if ResumeButton:isClicked() then
            Game:changestates("running")
        end
    end

    --selection state
    if Game.states.selection then

        --horrible code? absolutely , do I care? fuck no.
        PICKTHEMITEMS:Load()
     
        
        if selectbutton1:isClicked() then
            PICKTHEMITEMS:addtoplayer(1)
            PICKTHEMITEMS:Recover()
            
            Game:changestates("running")
        end
        if selectbutton2:isClicked() then
            PICKTHEMITEMS:addtoplayer(2)
            PICKTHEMITEMS:Recover()
            Game:changestates("running")
        end
        if selectbutton3:isClicked() then
            PICKTHEMITEMS:addtoplayer(3)
            PICKTHEMITEMS:Recover()
            Game:changestates("running")
        end
    
        
    end
end

--this displays different stuff on the screen based on the game state.
function love.draw()

    --the menu state
    if Game.states.menu then
        love.graphics.setFont(titlefont)
        love.graphics.setColor(1,1,1)
        love.graphics.printf(TITLE,love.graphics.getWidth()/4,love.graphics.getHeight()/3,1000,"left")
        
        StartButton:draw()
        love.graphics.setFont(normalfont)
    end

    --the running state
    if Game.states.running then
        
        player:draw()
        bullet.draw()
        weapon:draw()
        enemy:draw() -- ✅ Make sure enemy.draw() exists in enemy.lua
        --drawing the ammo displayer
        love.graphics.setColor(1,1,1)
        love.graphics.setFont(normalfont)
        love.graphics.print("AMMO :"..player.ammo, 10, love.graphics.getHeight() - 100,0,4)
       
        
    end

    --the pause state
    if Game.states.pause then
        love.graphics.setColor(1,1,1)
        love.graphics.setFont(titlefont)
        love.graphics.print("PAUSED",500 ,300,0,2,2)
        ResumeButton:draw()
    end

    --selection state
    if Game.states.selection then
        PICKTHEMITEMS:Draw()
        selectbutton1:draw()
        selectbutton2:draw()
        selectbutton3:draw()
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

function Firing() -- Replaced love.mousepressed with this so the button can be held down
    if love.mouse.isDown(1) and player.ammo > 0 then
        local mouseX, mouseY = love.mouse.getX(), love.mouse.getY()

        -- Gun barrel offset (Adjust this based on your sprite size)
        local barrelOffset = weapon.sprite:getWidth() * 0.25 -- Since scale is 0.25

        -- Calculate the exact bullet spawn position at the barrel tip
        local spawnX = weapon.x + math.cos(weapon.angle) * barrelOffset
        local spawnY = weapon.y + math.sin(weapon.angle) * barrelOffset

        -- Spawn the bullet from the barrel, not the player's center
        bullet.spawn(spawnX, spawnY, mouseX, mouseY, player.bullet_speed)
        --implementing audio
    end
end


