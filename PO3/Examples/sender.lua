-- Sender computer

local component = require("component")
local event = require("event")

-- Make sure you have a wireless network card installed
local modem = component.modem

-- Open a port for communication (choose any number between 1 and 65535)
local port = 1234
modem.open(port)

-- Function to send a message
local function sendMessage(message)
  modem.broadcast(port, message)
  print("Message sent: " .. message)
end

-- Send a message
sendMessage("Hello from sender!")

-- Keep the program running to receive responses
while true do
  local _, _, from, port, _, message = event.pull("modem_message")
  print("Received from " .. from .. ": " .. message)
end