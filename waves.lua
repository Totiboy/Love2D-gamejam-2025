local bosses = require("bosses")
local UpgradesManager = require("UpgradesManager")

waves = {}

waves.currentWave = 1
waves.enemyCount = 50
waves.kills = 0
waves.state = "item" -- Start with item selection
waves.bossSpawned = false

function waves:nextState()
    if self.state == "item" then
        UpgradesManager:Load()
        self.state = "wave"
    elseif self.state == "wave" then
        self.currentWave = self.currentWave + 1
        self.enemyCount = 40 + (10 * self.currentWave)
        self.kills = 0
        if self.currentWave % 2 == 0 then
            self.state = "boss"
        else
            self.state = "item"
        end
    elseif self.state == "boss" then
        bosses:spawnBoss(self.currentWave // 2)
        self.bossSpawned = true
        self.state = "stats"
    elseif self.state == "stats" then
        UpgradesManager:Load()
        self.state = "wave"
    end
end

function waves:update()
    if self.state == "wave" and self.kills >= self.enemyCount then
        self:nextState()
    elseif self.state == "boss" and not self.bossSpawned then
        self:nextState()
    end
end

function waves:enemyDefeated()
    self.kills = self.kills + 1
end

return waves
