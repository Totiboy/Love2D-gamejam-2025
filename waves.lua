Gamestatesmanager = require("gamestatesmanager")

waves = {}
waves.bossesDefeated = 0
waves.currentWave = 0
waves.killsNeeded = 1 + 20 * waves.currentWave
waves.killsLeft = waves.killsNeeded

function waves:startWave()
    Game:changestates("firstselection")
    waves.bossesDefeated = 0
    waves.currentWave = 0
    waves.killsLeft = waves.killsNeeded
    if Game.states.menu then
        Game:changestates("firstselection")
        waves.bossesDefeated = 0
        waves.currentWave = 0
        waves.killsLeft = waves.killsNeeded
    end
end

function waves:nextWave()

    if Game.states.firstselection then
        Game:changestates("running")

    elseif Game.states.running and waves.killsLeft <= 0 then
        enemy.clearEnemies()
        Game:changestates("selection")

    elseif Game.states.selection and waves.bossesDefeated < 5 then
        Game:changestates("boss")

    elseif Game.states.boss then
        waves.currentWave = waves.currentWave + 1
        waves.bossesDefeated = waves.bossesDefeated + 1
        Game:changestates("stats")

    elseif Game.states.selection and waves.bossesDefeated >= 4 then
        Game:changestates("finalboss")
    end
end

function waves:enemyDefeated()
    waves.killsLeft = waves.killsLeft - 1
    
    if waves.killsLeft <= 0 then
        waves:nextWave()
    end
end

function waves:boss(dt)
    if not bosses.currentBoss then
        bosses:spawnBoss(self.currentWave)
    end

    if bosses.currentBoss and bosses.currentBoss.alive then
        bosses.currentBoss:update(dt)
    end
end


return waves
