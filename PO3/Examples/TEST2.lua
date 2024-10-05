local component = require "component"
local term = require "term"
local computer = require "computer"
local gpu = component.gpu
local event = require("event")
local os = require("os")
local thread = require("thread")

gpu.setForeground(0xFF0000) -- Set text color to red
term.write("Hello, World!\n")
gpu.setForeground(0xFFFFFF) -- Reset text color to white