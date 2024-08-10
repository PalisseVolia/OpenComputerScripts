-- Sender computer

local component = require("component")
local os = require("os")
-- local event = require("event")

-- Make sure you have a wireless network card installed
local modem = component.modem

-- Open a port for communication (choose any number between 1 and 65535)
local port = 1234
local sum = 0
modem.open(port)

-- Find all agricraft_peripheral components
local analyzers = {}
for address, componentType in component.list() do
    if componentType == "agricraft_peripheral" then
        table.insert(analyzers, address)
    end
end

-- Function to send a message
local function sendMessage(message)
modem.broadcast(port, message)
print("Message sent: " .. message)
end

local orientation = "EAST"

print("Give orientation (EAST/WEST/NORTH/SOUTH) ?")
local input = io.read()
while input ~= "EAST" and input ~= "WEST" and input ~= "NORTH" and input ~= "SOUTH" do
    print("Invalid input. Please enter EAST/WEST/NORTH/SOUTH.")
    input = io.read()
end

while true do
    for i, analyzerAddress in ipairs(analyzers) do
        local analyzer = component.proxy(analyzerAddress)
    
        if analyzer.hasPlant(input) then
            sendMessage("Plant at line " .. tostring(i))
        end

        if analyzer.getSpecimen() ~= "Air" then
            analyzer.analyze()
            os.sleep(3)
            local a, b, c = analyzer.getSpecimenStats()
            if analyzer.getSpecimen() ~= "Air" then
                sum = a + b + c
            end
            if sum < 30 then
                sendMessage("Line " .. tostring(i) .. " not done")
            else
                sendMessage("Line " .. tostring(i) .. " done")
            end
        end
    end
end