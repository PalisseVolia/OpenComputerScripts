local component = require("component")
local computer = require("computer")

-- Check if we have a modem
if not component.isAvailable("modem") then
  print("No modem found!")
  return
end

local modem = component.modem

-- Check if the modem is wireless
print("Is wireless: " .. tostring(modem.isWireless()))

-- Check modem's max range
print("Max range: " .. modem.getStrength())

-- Open a test port
local port = 1234
modem.open(port)

-- List open ports
print("Open ports:")
for i = 1, 65535 do
    if modem.isOpen(i) then
        print(i)
    end
end

-- Try to broadcast a message
print("Attempting to broadcast...")
local success = modem.broadcast(port, "Test message")
print("Broadcast success: " .. tostring(success))

-- Computer uptime and memory info
print("Uptime: " .. computer.uptime() .. " seconds")
print("Free memory: " .. computer.freeMemory() / 1024 .. " KB")

print("Sender diagnostic complete.")