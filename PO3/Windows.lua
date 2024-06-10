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
        displayText = string.sub(self.text, 1, maxLength - 4) .. "..."
    end
    
    -- Draw the title text at a fixed position relative to the parent window
    gpu.set(parentX + 2, parentY, displayText)
end

-- ========================================
-- Example usage
-- ========================================

-- Create a window
local myWindow = Window:new(5, 5, 30, 10)

-- Create a Title and add it to the window
local myTitle = Title:new("Hello, World! This is a very long title")
myWindow:addChild(myTitle)

-- Redraw the window to include the Title
myWindow:draw()


-- Create a window
local myWindow2 = Window:new(35, 25, 50, 20)

-- Create a Title and add it to the window
local myTitle2 = Title:new("Hello, World! too")
myWindow2:addChild(myTitle2)

-- Redraw the window to include the Title
myWindow2:draw()