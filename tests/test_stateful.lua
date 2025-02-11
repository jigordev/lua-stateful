local stateful = require("stateful")

local function test_utils()
    stateful.use_state("x", 100)
    stateful.use_state("y", 200)
    assert(stateful.has("x") and stateful.has("y"))
    assert(stateful.all()["x"] == 100)
    stateful.unset("y")
    assert(not stateful.has("y"))
    stateful.clear()
    assert(not stateful.has("x"))
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
    test_getter_setter()
    test_effect()
    test_cleanup()
    print("All tests passed successfully!")
end

runtests()