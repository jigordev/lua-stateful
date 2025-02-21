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
    self._call_stack = {}
    self._data = setmetatable(proxy, {
        __index = function(_, k) return rawget(proxy, k) end,
    })
    self._listeners = {}
end

function State:set(key, value)
    if self._data[key] == value then return end
    if self._call_stack[key] then
        error("Recursive state update detected for key: " .. key)
    end

    self._call_stack[key] = true
    self._data[key] = deep_copy(value)

    if self._batching then
        self._batch_updates = self._batch_updates or {}
        self._batch_updates[key] = deep_copy(value)
    else
        self:_notify_listeners(key, value)
    end

    self._call_stack[key] = nil
end

function State:has(key)
    return self:get(key) ~= nil
end

function State:unset(key)
    self:set(key, nil)
    self._listeners[key] = nil
end

function State:_notify_listeners(key, value)
    if self._listeners[key] and next(self._listeners[key]) then
        local listeners_snapshot = {}
        for listener in pairs(self._listeners[key]) do
            table.insert(listeners_snapshot, listener)
        end
        for _, listener in ipairs(listeners_snapshot) do
            listener(value)
        end
    end 
end

function State:get(key)
    return self._data[key]
end

function State:get_all()
    local data = {}
    for key, value in pairs(self._data) do
        data[key] = deep_copy(value)
    end
    return data
end

function State:clear()
    local proxy = {}
    self._call_stack = {}
    self._data = setmetatable(proxy, {
        __index = function(_, k) return rawget(proxy, k) end,
    })
    self._listeners = {}
end

function State:set_listener(key, listener)
    if not self._listeners[key] then
        self._listeners[key] = {}
    end
    
    self._listeners[key][listener] = true
end

function State:get_listeners(key)
    if not self._listeners[key] then return {} end

    local listeners = {}
    for listener, _ in pairs(self._listeners[key]) do
        table.insert(listeners, listener)
    end
    return listeners
end

function State:remove_listener(key, target_listener)
    local listeners = self._listeners[key]
    if not listeners then return end

    listeners[target_listener] = nil
    if not next(listeners) then
        self._listeners[key] = nil
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

return State
