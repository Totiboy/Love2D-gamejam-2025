Gamestatesmanager = require("gamestatesmanager")

waves = {}
waves.bossesDefeated = 0
waves.killsleft = 0

function waves:startWave()
    Game:changestates("firstselection")
end

function waves:nextWave()
    if Game.states.firstselection then
        Game:changestates("running")
    elseif Game.states.running then
        Game:changestates("selection")
    elseif Game.states.selection and waves.bossesDefeated < 4 then
        Game:changestates("boss")
    elseif Game.states.boss then
        Game:changestates("running")
    elseif Game.states.selection and waves.bossesDefeated > 3 then
        Game:changestates("finalboss")
    end
end



return waves
--[[function waves:nextState()
    if waves.state == "selection" then
        UpgradesManager:Load()
        self.kills = 0
        self.enemyCount = 10 + (5 * self.currentWave)
        waves.state = "running"
    elseif waves.state == "running" then
        self.currentWave = self.currentWave + 1
        self.kills = 0

        if self.currentWave == 2 then  -- ✅ After Wave 1, go to Item Selection
            waves.state = "selection"
        elseif self.currentWave == 3 then  -- ✅ After Item Selection, spawn Boss
            Game:changestates("boss")
            bosses:spawnBoss(1)  -- Spawns Two-Faced Diamante
            waves.bossSpawned = true
        else
            waves.state = "selection"
        end
    elseif waves.state == "boss" then
        if self.bossSpawned and bosses.currentBoss and not bosses.currentBoss.alive then
            waves.state = "selection"
            self.bossSpawned = false
        end
    end
end

function waves:update()
    local aliveEnemies = #enemy:getEnemies()  -- ✅ Count enemies properly

    if self.state == "running" and aliveEnemies == 0 then
        self:nextState()
    elseif self.state == "boss" and bosses.currentBoss and not bosses.currentBoss.alive then
        self:nextState()
    end
end

function waves:enemyDefeated()
    self.kills = self.kills + 1
end]]
