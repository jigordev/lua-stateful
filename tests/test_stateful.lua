local stateful = require("stateful")

local function test_utils()
    local state = stateful.create_state()
    state:set("x", 100)
    state:set("y", 200)
    assert(state:has("x") and state:has("y"))
    assert(state:get_all()["x"] == 100)
    state:unset("y")
    assert(not state:has("y"))
    state:clear()
    assert(not state:has("x"))
end

local function test_batching()
    local state = stateful.create_state()
    local count = 0
    state:set("x", 10)
    state:set_listener("x", function(value)
        count = count + 1
    end)
    state:begin_batch()
    state:set("x", 11)
    state:set("x", 12)
    state:set("x", 13)
    assert(count == 0)
    state:end_batch()
    assert(count == 1)
    assert(state:get("x") == 13)
end

local function test_getter_setter()
    local getter, setter = stateful.use_state("x", 10)
    assert(getter() == 10)
    setter(12)
    assert(getter() == 12)
end

local function test_effect()
    local v = 1
    local _, setter, effect = stateful.use_state("x", 10)
    effect(function (value)
        v = value
    end)
    setter(11)
    assert(v == 11)
end

local function test_cleanup()
    local count = 0
    local _, setter, effect = stateful.use_state("x", 1000)
    local cleanup = effect(function (value) count = count + 1 end)
    setter(10)
    cleanup()
    setter(20)
    assert(count == 1)
end

local function runtests()
    test_utils()
    test_batching()
    test_getter_setter()
    test_effect()
    test_cleanup()
    print("All tests passed successfully!")
end

runtests()