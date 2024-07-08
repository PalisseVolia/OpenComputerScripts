local component = require "component"
local term = require "term"
local computer = require "computer"
local gpu = component.gpu
local event = require("event")

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
-- Example usage
-- ========================================

-- Create a main window
local mainWindow = Window:new(5, 5, 30, 10)

-- Define the button click action
local function onButtonClick()
    -- Create a new window when the button is clicked
    local newWindow = Window:new(40, 5, 30, 10)
    newWindow:draw()
end

-- Create a button and add it to the main window
local myButton = Button:new(5, 3, 20, 3, "Click Me!", onButtonClick)
mainWindow:addChild(myButton)

-- Redraw the main window to include the button
mainWindow:draw()

-- Event loop to handle mouse click events
while true do
    local _, _, clickX, clickY = event.pull("touch")
    for _, child in ipairs(mainWindow.children) do
        if child.handleClick then
            child:handleClick(clickX, clickY, mainWindow.x, mainWindow.y)
        end
    end
end
