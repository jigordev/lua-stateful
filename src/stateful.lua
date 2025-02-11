local state = require("stateful.state")

local stateful = {}

function stateful.has(key)
    return state:get(key) ~= nil
end

function stateful.unset(key)
    state:set(key, nil)
end

function stateful.clear()
    state:clear()
end

function stateful.all()
    return state:get_all()
end

function stateful.use_state(key, value)
    if state:get(key) == nil then
        state:set(key, value)
    end

    local getter = function()
        local v = state:get(key)
        return type(v) == "function" and v() or v
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
