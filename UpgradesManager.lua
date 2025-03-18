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

require("Button")
UpgradesManager = {}
UpgradesManager.Items = {"key","ball","rose","shoes","deez","waa"}
UpgradesManager.ChosenItems = {}
local cancall = true

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
function UpgradesManager:Draw()
    love.graphics.setColor(0.6,0.5,0.5)
    love.graphics.rectangle("fill",100,100,love.graphics.getWidth()-210,love.graphics.getHeight()-210)
    for index, value in ipairs(self.ChosenItems) do
        love.graphics.setColor(0,0,0)
        love.graphics.printf(tostring(index)..": "..value , 100 , 100+index*10,1000,"left")
    end
end

return UpgradesManager

