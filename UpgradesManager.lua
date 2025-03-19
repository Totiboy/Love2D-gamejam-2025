---let's break down this feature to simple components :
---1- the upgrade screen only works in the selection state of the game.
---2- it allows you to pick between different available upgrades.
---3- you're limited to 3 upgrades , forcing you to know what you're doing.
---4- after you pick the upgrade you go back to the running state and continue with the waves
---5- the system is activated every wave
--- 
--- ideas : 
--- an item list for the upgrade system to randomly pick from
--- a for loop to go through the items randomly and pick from them three times.
--- if you pick an item it gets added to a list in player.lua which keeps track of activated items
--- for every item in the player's list ,an active() method is called which basically allows them to be functional.
--- maybe it's an item's class to make them all have this active method?
--- hi blindFang

require("Button")
require("player")
--making a table for the upgradesmanager itself and the items
UpgradesManager = {}

--these items are placeholders , you should add actual items instead of these lmao
UpgradesManager.Items = {
    "Trigger Crank",
    "Long Barrell",
    "Army Helmet",
    "Extended Magazine",
    "Foregrip"
}

--a table that has the items that the player will pick from.
UpgradesManager.ChosenItems = {}

--this boolean prevents the function from getting called a million times.
local cancall = true

--this function picks from the Items list and adds them to the chosen items list to make the player take from them
function UpgradesManager:Load()
    
    if cancall then
        for i = 1, 3, 1 do
            local index = love.math.random(1,#self.Items)
            local pickeditem = self.Items[index]
            table.insert(self.ChosenItems,pickeditem)
            table.remove(self.Items,index)
        end
        cancall = false
    end
end

--this function adds the chosen item from the chosen item list to the player's passives list.
function UpgradesManager:addtoplayer(num)
   for index, value in ipairs(self.ChosenItems) do
    if index ==num and #player.passives<=3 then
        table.insert(player.passives,self.ChosenItems[index])
        table.remove(self.ChosenItems,index)
    end
   end
end

--this function adds everything that remains into the Items list
function UpgradesManager:Recover()
    
    for index, value in ipairs(self.ChosenItems) do
        table.insert(self.Items,value)
    end
    
end

--this draws everything
function UpgradesManager:Draw()
    love.graphics.setColor(0.6,0.5,0.5)
    love.graphics.rectangle("fill",100,100,love.graphics.getWidth()-210,love.graphics.getHeight()-210)
    for index, value in ipairs(self.ChosenItems) do
        love.graphics.setColor(0,0,0)
        love.graphics.print(tostring(index)..": "..value , 100 , 100+index*100)

    end
end

return UpgradesManager

