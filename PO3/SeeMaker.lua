local component = require("component")
local sides = require("sides")
local event = require("event")
local os = require("os")

local k = 0

local function Break()
    k = k + 1
    print("Breaking plant " .. k .. "...")
    component.redstone.setOutput(sides.right, 0)
    component.redstone.setOutput(sides.left, 15)
    os.sleep(0.1)
    component.redstone.setOutput(sides.left, 0)
    os.sleep(0.1)
end

local function Place()
    print("Placing plant...")
    component.redstone.setOutput(sides.right, 15)
end

local running = true

while running do
    if component.agricraft_peripheral.hasPlant("DOWN") then
        Break()
    else
        Place()
    end
    os.sleep(0.1)
end

-- Wait for user interruption to stop the program
event.pull("interrupted")
running = false