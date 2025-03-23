require("Button")
require("player")

UpgradesManager = {}

UpgradesManager.Items = {
    "Trigger Crank (+Fire Rate)",
    "Long Barrell (+Bullet Speed)",
    "Army Helmet (+Health)",
    "Extended Magazine (+Ammo)",
    "Foregrip (+Movement Speed)",
    "+P Rounds (+DMG and -Fire Rate)",
    "Army Boots (-Dash Cooldown)",
    "Glock Switch (++Fire Rate and -Damage)",
    "Overdrive Serum (+All Stats and 2x Damage Taken)"
}

UpgradesManager.ChosenItems = {}
local cancall = true

function UpgradesManager:Load()
    if cancall then
        -- Reseed RNG
        love.math.setRandomSeed(os.time() + love.math.random(1, 1000000))

        -- Filter out items that were permanently selected
        local availableItems = {}
        for _, item in ipairs(self.Items) do
            table.insert(availableItems, item) -- Keep valid items
        end

        -- Pick 3 unique items (fill all three slots if possible)
        self.ChosenItems = {}
        for i = 1, math.min(3, #availableItems) do
            local index = love.math.random(1, #availableItems)
            table.insert(self.ChosenItems, availableItems[index])
            table.remove(availableItems, index) -- Prevent duplicates in the same selection
        end

        cancall = false
    end
end

function UpgradesManager:addtoplayer(num)
    local selectedItem = self.ChosenItems[num]
    if selectedItem and #player.passives < 3 then
        table.insert(player.passives, selectedItem)
        self:removeFromPool(selectedItem) -- ✅ Remove from future waves
        player:applyUpgrades()
    end
end

-- ✅ Removes an item permanently from the future upgrade pool
function UpgradesManager:removeFromPool(item)
    for i, v in ipairs(self.Items) do
        if v == item then
            table.remove(self.Items, i)
            break
        end
    end
end

function UpgradesManager:Recover()
    cancall = true -- Allow Load() to run again
end

function UpgradesManager:Draw()
    love.graphics.setColor(0.6, 0.5, 0.5)
    love.graphics.rectangle("fill", 100, 100, love.graphics.getWidth() - 210, love.graphics.getHeight() - 210)
    for index, value in ipairs(self.ChosenItems) do
        love.graphics.setColor(0, 0, 0)
        love.graphics.print(tostring(index) .. ": " .. value, 200, 100 + index * 100)
    end
end

function UpgradesManager:Reset()
    -- Restore all upgrades to the original pool
    self.Items = {
        "Trigger Crank (+Fire Rate)",
        "Long Barrell (+Bullet Speed)",
        "Army Helmet (+Health)",
        "Extended Magazine (+Ammo)",
        "Foregrip (+Movement Speed)",
        "+P Rounds (+DMG and -Fire Rate)",
        "Army Boots (-Dash Cooldown)",
        "Glock Switch (++Fire Rate and -Damage)",
        "Overdrive Serum (+All Stats and 2x Damage Taken)"
    }
    self.ChosenItems = {}
    cancall = true  -- Allow upgrades to generate again
end

return UpgradesManager
