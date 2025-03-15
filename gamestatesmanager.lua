--as much as I hate to admit it I didn't come up with this , I watched a tutorial.

--this is a function that handles game states , it returns a table that contains
--a states table and a function that switches between states.
function Game()
    return {
        --the states table , you can add as many states as you like.
    states = {
        menu = false,
        running = false,
        pause = false,
        selection = false
    },

    --and this function handles the switching between states by checking whether the state you pass in the parameter corresponds
    --with the available states in the states table above.
    changestates = function (self,state)
        self.states.menu = state == "menu"
        self.states.running = state == "running"
        self.states.pause = state == "pause"
        self.states.selection = state == "selection"
        
    end
        } 
end