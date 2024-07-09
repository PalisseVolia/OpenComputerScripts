local component = require "component"
local term = require "term"
local computer = require "computer"
local gpu = component.gpu
local event = require("event")
local os = require("os")

Reactor = component.nc_fission_reactor

-- ========================================
-- Utility functions to draw lines
-- ========================================

local function drawLineX(x, y, length)
    for i=1,length do
        gpu.set(x+i, y, "─")
    end
end

local function drawLineY(x, y, length)
    for i=1,length do
        gpu.set(x, y+i, "│")
    end
end

-- ========================================
-- Window class
-- ========================================

Window = {}
Window.__index = Window

function Window:new(x, y, width, height)
    local self = setmetatable({}, Window)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.children = {} -- To hold child elements
    return self
end

function Window:draw()
    -- Draw corners
    gpu.set(self.x, self.y, "╭")
    gpu.set(self.x + self.width, self.y, "╮")
    gpu.set(self.x, self.y + self.height, "╰")
    gpu.set(self.x + self.width, self.y + self.height, "╯")
    
    -- Draw edges
    drawLineX(self.x, self.y, self.width - 1)
    drawLineX(self.x, self.y + self.height, self.width - 1)
    drawLineY(self.x, self.y, self.height - 1)
    drawLineY(self.x + self.width, self.y, self.height - 1)

    -- Draw child elements
    for _, child in ipairs(self.children) do
        child:draw(self.x, self.y, self.width, self.height)
    end
end

function Window:addChild(child)
    table.insert(self.children, child)
end

-- ========================================
-- Title class
-- ========================================

Title = setmetatable({}, {__index = Window})
Title.__index = Title

function Title:new(text)
    -- Create a Title instance, no need for width and height here
    local self = setmetatable({}, Title)
    self.text = text
    return self
end

function Title:draw(parentX, parentY, parentWidth)
    -- Calculate the maximum length of the text that can fit in the window
    local maxLength = parentWidth - 4 -- account for the corners and spaces
    local displayText = self.text
    
    if #self.text > maxLength then
        displayText = string.sub(self.text, 1, maxLength - 3) .. "..."
    end
    
    -- Draw the title text at a fixed position relative to the parent window
    gpu.set(parentX + 2, parentY, displayText)
end

-- ========================================
-- TextLine class
-- ========================================

TextLine = setmetatable({}, {__index = Window})
TextLine.__index = TextLine

function TextLine:new(x, y, text)
    -- Create a TextLine instance
    local self = setmetatable({}, TextLine)
    self.x = x
    self.y = y
    self.text = text
    return self
end

function TextLine:draw(parentX, parentY, parentWidth)
    -- Calculate the maximum length of the text that can fit in the window
    local maxLength = parentWidth - (self.x + 2) -- account for the corners and spaces
    local displayText = self.text
    
    if #self.text > maxLength then
        displayText = string.sub(self.text, 1, maxLength - 3) .. "..."
    end
    
    -- Draw the text line at a fixed position relative to the parent window
    gpu.set(parentX + self.x + 1, parentY + self.y + 1, displayText)
end

-- ========================================
-- ProgressBar class
-- ========================================

ProgressBar = setmetatable({}, {__index = Window})
ProgressBar.__index = ProgressBar

function ProgressBar:new(x, y, progress)
    -- Create a ProgressBar instance
    local self = setmetatable({}, ProgressBar)
    self.x = x
    self.y = y
    self.progress = progress or 0 -- Progress is a percentage (0-100)
    return self
end

function ProgressBar:draw(parentX, parentY, parentWidth)
    -- Calculate the length of the progress bar
    local barLength = parentWidth - (self.x + 6) -- account for the corners and spaces, and the percentage text
    local filledLength = math.floor(barLength * self.progress / 100)
    local emptyLength = barLength - filledLength

    -- Create the progress bar string
    local bar = string.rep("█", filledLength) .. string.rep("░", emptyLength)
    local percentageText = string.format("%3d%%", self.progress)

    -- Draw the progress bar at a fixed position relative to the parent window
    gpu.set(parentX + self.x + 1, parentY + self.y + 1, bar .. " " .. percentageText)
end

-- ========================================
-- Button class
-- ========================================

Button = setmetatable({}, {__index = Window})
Button.__index = Button

function Button:new(x, y, width, height, label, onClick)
    -- Create a Button instance
    local self = setmetatable({}, Button)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.label = label
    self.onClick = onClick
    return self
end

function Button:draw(parentX, parentY)
    -- Draw the button border
    gpu.set(parentX + self.x, parentY + self.y, "╭")
    gpu.set(parentX + self.x + self.width, parentY + self.y, "╮")
    gpu.set(parentX + self.x, parentY + self.y + self.height, "╰")
    gpu.set(parentX + self.x + self.width, parentY + self.y + self.height, "╯")
    drawLineX(parentX + self.x, parentY + self.y, self.width - 1)
    drawLineX(parentX + self.x, parentY + self.y + self.height, self.width - 1)
    drawLineY(parentX + self.x, parentY + self.y, self.height - 1)
    drawLineY(parentX + self.x + self.width, parentY + self.y, self.height - 1)
    
    -- Draw the button label
    local labelX = parentX + self.x + math.floor((self.width - #self.label) / 2)
    local labelY = parentY + self.y + math.floor(self.height / 2)
    gpu.set(labelX, labelY, self.label)
end

function Button:handleClick(clickX, clickY, parentX, parentY)
    if clickX >= parentX + self.x and clickX <= parentX + self.x + self.width and
       clickY >= parentY + self.y and clickY <= parentY + self.y + self.height then
        self.onClick()
    end
end

-- ========================================
-- Reactor Panel
-- ========================================

-- Define the button click action
local function onButtonClick()
    -- When clicked, toggle the reactor state
    if Reactor.isProcessing() then
        Reactor.deactivate()
    else
        Reactor.activate()
    end
end

OldHeat = 0
OldEnergy = 0

-- Event loop to handle mouse click events
repeat
    -- Create the main window
    local reactorPanel = Window:new(5, 5, 50, 20)

    -- Create the title
    local reactorTitle = Title:new("Reactor Control Panel")
    reactorPanel:addChild(reactorTitle)

    -- Create the heat progress bar
    local heatProgressBar = ProgressBar:new(5, 3, 0)
    reactorPanel:addChild(heatProgressBar)

    -- Create the energy progress bar
    local energyProgressBar = ProgressBar:new(5, 5, 0)
    reactorPanel:addChild(energyProgressBar)

    -- Create the status text
    if Reactor.isProcessing() then
        local statusText = TextLine:new(5, 7, "Reactor Status: ONLINE")
        reactorPanel:addChild(statusText)
    else
        local statusText = TextLine:new(5, 7, "Reactor Status: OFFLINE")
        reactorPanel:addChild(statusText)
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
        OldHeat = CurrentHeat
        OldEnergy = CurrentEnergy
    end

    -- Create the toggle button
    local toggleButton = Button:new(5, 9, 20, 3, "Toggle Reactor", onButtonClick)
    reactorPanel:addChild(toggleButton)

    -- Redraw the reactor panel
    reactorPanel:draw()

    local _, _, clickX, clickY = event.pull("touch")
    for _, child in ipairs(reactorPanel.children) do
        if child.handleClick then
            child:handleClick(clickX, clickY, reactorPanel.x, reactorPanel.y)
        end
    end
    os.sleep(0.5)
until event.pull(1) == "interrupted"