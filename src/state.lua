local class = require("middleclass")

local State = class("State")

function State:initialize()
    self.data = {}
    self.listeners = setmetatable({}, { __mode = "k" })
end

function State:set(key, value)
    if self.data[key] == value then return end

    self.data[key] = value
    if self.listeners[key] then
        for listener, _ in pairs(self.listeners[key]) do
            listener(value)
        end
    end
end

function State:get(key)
    return self.data[key]
end

function State:get_all()
    local data = {}
    for key, value in pairs(self.data) do
        data[key] = value
    end
    return data
end

function State:clear()
    self.data = {}
    self.listeners = setmetatable({}, { __mode = "k" })
end

function State:set_listener(key, listener)
    if not self.listeners[key] then
        self.listeners[key] = setmetatable({}, { __mode = "k" })
    end
    
    if not self.listeners[key][listener] then
        self.listeners[key][listener] = true
    end
end

function State:get_listeners(key)
    if not self.listeners[key] then return {} end

    local listeners = {}
    for listener, _ in pairs(self.listeners[key]) do
        table.insert(listeners, listener)
    end
    return listeners
end

function State:remove_listener(key, target_listener)
    if self.listeners[key] then
        self.listeners[key][target_listener] = nil
        if next(self.listeners[key]) == nil then
            self.listeners[key] = nil
        end
    end
end

local instance = nil

local function get_instance()
    if not instance then
        instance = State:new()
    end
    return instance
end

return setmetatable({}, {
    __index = function(_, key)
        local instance = get_instance()
        local value = instance[key]
        if type(value) == "function" then
            return function(_, ...) return value(instance, ...) end
        end
        return value
    end,
    __newindex = function()
        error("Unable to modify state instance")
    end
})

