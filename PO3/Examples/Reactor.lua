local component = require "component"
local term = require "term"
local computer = require "computer"
local gpu = component.gpu
local event = require("event")

Reactor = component.nc_fission_reactor

local screenWidth, screenHeight = gpu.maxResolution()
gpu.setResolution(screenWidth / 2, screenHeight / 2)

local barLength = 50
local barHeight = 3
local startX = 16
local startY = 3

OldHeat = 0
OldEnergy = 0

local function drawProgressBar(percent, length, height, x, y, label)
    local filledLength = math.floor(percent / 100 * length)
    gpu.setBackground(0x00FF00)
    gpu.fill(x, y, filledLength, height, " ")
    gpu.setBackground(0xFF0000)
    gpu.fill(x + filledLength, y, length - filledLength, height, " ")
    gpu.setBackground(0x000000)
    local percentageText = label .. " " .. string.format("%d%%", percent)
    local textX = x + math.floor((length - #percentageText) / 2)
    local textY = y + math.floor(height / 2)
    gpu.set(textX, textY, percentageText)
end

computer.beep()

print("Initialising...")

repeat
    if (Reactor.isProcessing()) then
        gpu.set(startX+17, 13, "Reactor ONLINE")
        gpu.setBackground(0x00FF00)
        gpu.fill(startX+17, 14, 15, 1, " ")
        gpu.setBackground(0x000000)
    else
        gpu.set(startX+17, 13, "Reactor OFFLINE")
        gpu.setBackground(0xFF0000)
        gpu.fill(startX+17, 14, 15, 1, " ")
        gpu.setBackground(0x000000)
    end

    CurrentHeat = math.floor(Reactor.getHeatLevel())
    MaxHeat = Reactor.getMaxHeatLevel()
    HeatRatio = math.floor(CurrentHeat / MaxHeat * 100)
    
    CurrentEnergy = math.floor(Reactor.getEnergyStored())
    MaxEnergy = Reactor.getMaxEnergyStored()
    EnergyRatio = math.floor(CurrentEnergy / MaxEnergy * 100)
    
    if HeatRatio < 50 and EnergyRatio < 50 then
        Reactor.activate()
    else
        Reactor.deactivate()
    end
    
    if (CurrentHeat ~= OldHeat or CurrentEnergy ~= OldEnergy) then
        computer.beep()
        term.clear()
        startY = 5
        drawProgressBar(HeatRatio, barLength, barHeight, startX, startY, "Heat")
        startY = 20
        drawProgressBar(EnergyRatio, barLength, barHeight, startX, startY, "Energy")
        OldHeat = CurrentHeat
        OldEnergy = CurrentEnergy
    end
until event.pull(1) == "interrupted"