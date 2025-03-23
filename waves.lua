Gamestatesmanager = require("gamestatesmanager")
Diamante = require("Boss (Diamante)")
Luca = require("Boss (Luca)")
HollowHagen = require("Boss (Hagen)")

waves = {}
waves.bossesDefeated = 0
waves.currentWave = 0
waves.killsNeeded = 1 + 5 * waves.currentWave
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
        --Game:changestates("boss")

    elseif Game.states.running and waves.killsLeft <= 0 then
        enemy.clearEnemies()
        Game:changestates("selection")

    elseif Game.states.selection and waves.bossesDefeated < 4 then
        Diamante:fullReset()
        Luca:fullReset()
        Game:changestates("boss")

    elseif Game.states.boss then
        waves.currentWave = waves.currentWave + 1
        waves.bossesDefeated = waves.bossesDefeated + 1
        waves.killsLeft = waves.killsNeeded
        Game:changestates("running")
        --Game:changestates("selection")

    --elseif Game.states.selection and waves.bossesDefeated >= 4 then
        --Game:changestates("finalboss")
    end
end

function waves:enemyDefeated()
    waves.killsLeft = waves.killsLeft - 1
    
    if waves.killsLeft <= 0 then
        waves:nextWave()
    end
end

function waves:nextBoss(dt)
    if not waves.next_boss then  -- Ensures it persists
        waves.next_boss = Diamante
        if waves.currentWave == 0 then
            waves.next_boss = Diamante
        elseif waves.currentWave == 1 then
            waves.next_boss = Diamante --or Luca
        elseif waves.currentWave == 2 then
            waves.next_boss = Diamante --or GalloBrothers
        elseif waves.currentWave > 2 then
            waves.next_boss = Diamante --or Hagen
        end

        if waves.next_boss and waves.next_boss.load then
            waves.next_boss:load()  -- Initialize only once
        end
    end

    -- Update the boss only if it exists
    if waves.next_boss then
        waves.next_boss:update(dt)
    end
end

function waves:drawBoss()
    -- Draw the boss if it exists
    if waves.next_boss then
        waves.next_boss:draw()
    end
end

return waves
