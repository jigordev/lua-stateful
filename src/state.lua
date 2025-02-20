local class = require("middleclass")

local function deep_copy(obj)
    if type(obj) ~= "table" then return obj end
    local copy = {}
    for k, v in pairs(obj) do
        copy[k] = deep_copy(v)
    end
    return copy
end

local State = class("State")

function State:initialize()
    local proxy = {}
    self.data = setmetatable(proxy, {
        __index = function(_, k) return proxy[k] end,
        __newindex = function()
            error("Direct modification of state is not allowed. Use :set() instead.")
        end
    })
    self.listeners = setmetatable({}, { __mode = "k" })
end

local call_stack = {}

function State:set(key, value)
    if self.data[key] == value then return end
    if call_stack[key] then
        error("Recursive state update detected for key: " .. key)
    end

    call_stack[key] = true
    self.data[key] = deep_copy(value)

    if self._batching then
        self._batch_updates = self._batch_updates or {}
        self._batch_updates[key] = deep_copy(value)
    else
        self:_notify_listeners(key, value)
    end

    call_stack[key] = nil
end

function State:_notify_listeners(key, value)
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
        data[key] = deep_copy(value)
    end
    return data
end

function State:clear()
    local proxy = {}
    self.data = setmetatable(proxy, getmetatable(self.data))
    self.listeners = setmetatable({}, { __mode = "v" })
end

function State:set_listener(key, listener)
    if not self.listeners[key] then
        self.listeners[key] = setmetatable({}, { __mode = "v" })
    end
    
    self.listeners[key][listener] = true
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
    local listeners = self.listeners[key]
    if not listeners then return end

    listeners[target_listener] = nil
    if not next(listeners) then
        self.listeners[key] = nil
    end
end

function State:begin_batch()
    self._batching = true
end

function State:end_batch()
    self._batching = false
    for key, value in pairs(self._batch_updates or {}) do
        self:_notify_listeners(key, value)
    end
    self._batch_updates = nil
end

return {
    new = function ()
        return State:new()
    end
}
