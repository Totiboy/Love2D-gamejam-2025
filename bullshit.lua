-- hello there :)
-- Hello, please work :(
--WAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA (yes I'm sane thank you very much)
--WEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEe (Insanity Overdrive from AI)
-- 
        --[[ Waddle Variables
        boss.waddleTimer = 0
        boss.waddleDirection = 1
        boss.waddleSpeed = 10
        boss.waddleAmount = 0.05
        
        function boss:update(dt)
            
                -- Waddle Effect
                self.waddleTimer = self.waddleTimer + dt * self.waddleSpeed
                if self.waddleTimer >= 1 then
                    self.waddleTimer = 0
                    self.waddleDirection = -self.waddleDirection
                end
            end
        end
    end
end