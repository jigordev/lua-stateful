local State = require("stateful.state")

local stateful = {}

function stateful.create_state()
    return State:new()
end

function stateful.use_state(key, value)
    local state = State:new()

    state:set(key, value)

    local getter = function()
        return state:get(key)
    end

    local setter = function(new_value)
        if state:get(key) ~= new_value then
            state:set(key, new_value)
        end
    end

    local effect = function (effect_func)
        state:set_listener(key, effect_func)
        return function ()
            state:remove_listener(key, effect_func)
        end
    end

    return getter, setter, effect
end

return stateful
