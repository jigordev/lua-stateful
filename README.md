# Lua-Stateful

A simple Lua library for managing application state with reactive capabilities.

## Installation

You can install `stateful` via [LuaRocks](https://luarocks.org/):

```sh
luarocks install stateful
```

## Features

- Create instances of individual states
- Store and retrieve application state dynamically
- React to state changes using listeners
- Clear or reset state values
- React-inspired state manipulation functions

## Usage

### Importing the Library

```lua
local stateful = require("stateful")
```

### Basic State Management

```lua
local counter_get, counter_set = stateful.use_state("counter", 0)

print(counter_get()) -- Output: 0

counter_set(10)
print(counter_get()) -- Output: 10
```

### Checking if a State Exists

```lua

local state = stateful.create_state()
state:set("counter", 0)

print(state.has("counter")) -- Output: true
print(state.has("non_existent")) -- Output: false
```

### Removing a State

```lua
state:unset("counter")
print(state:has("counter")) -- Output: false
```

### Clearing All States

```lua
state:clear()
print(state:all()) -- Output: {}
```

### Using Effects (Reactivity)

```lua
local count_get, count_set, effect = stateful.use_state("count", 0)

local cleanup = effect(function()
    print("State changed to:", count_get())
end)

count_set(5)  -- Output: "State changed to: 5"
count_set(10) -- Output: "State changed to: 10"

cleanup() -- Removes the effect listener
count_set(15) -- No output since the effect was removed
```

### Retrieving All States

```lua
local state = stateful.create_state()
state:set("name", "Lua")

for key, value in pairs(state:all()) do
    print(key, value)
end
-- Output: name Lua
```

## Use Cases

- Managing global or shared state in Lua applications
- Implementing simple reactive state management for UI frameworks
- Caching computed values across function calls
- Observing changes in state variables

## License

This project is licensed under the MIT License.

