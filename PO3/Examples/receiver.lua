-- Receiver computer

local component = require("component")
local event = require("event")

-- Make sure you have a wireless network card installed
local modem = component.modem

-- Open the same port as the sender
local port = 1234
modem.open(port)

print("Waiting for messages...")

-- Listen for incoming messages
while true do
  local _, _, from, port, _, message = event.pull("modem_message")
  print("Received from " .. from .. ": " .. message)
  
  -- Send a response
  modem.send(from, port, "Message received!")
end