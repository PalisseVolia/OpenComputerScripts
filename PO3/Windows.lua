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

function TextLine:new(x, y, text, color)
    -- Create a TextLine instance
    local self = setmetatable({}, TextLine)
    self.x = x
    self.y = y
    self.text = text
    self.color = color or 0xFFFFFF -- Default to white if no color is provided
    return self
end

function TextLine:draw(parentX, parentY, parentWidth)
    -- Calculate the maximum length of the text that can fit in the window
    local maxLength = parentWidth - (self.x + 2) -- account for the corners and spaces
    local displayText = self.text
    
    if #self.text > maxLength then
        displayText = string.sub(self.text, 1, maxLength - 3) .. "..."
    end
    
    -- Set the text color
    local oldColor = gpu.getForeground()
    gpu.setForeground(self.color)
    
    -- Draw the text line at a fixed position relative to the parent window
    gpu.set(parentX + self.x + 1, parentY + self.y + 1, displayText)
    
    -- Restore the previous color
    gpu.setForeground(oldColor)
end

-- ========================================
-- ProgressBar class
-- ========================================

ProgressBar = setmetatable({}, {__index = Window})
ProgressBar.__index = ProgressBar

function ProgressBar:new(x, y, progress, color)
    -- Create a ProgressBar instance
    local self = setmetatable({}, ProgressBar)
    self.x = x
    self.y = y
    self.progress = progress or 0 -- Progress is a percentage (0-100)
    self.color = color or 0xFFFFFF -- Default to white if no color is provided
    return self
end

function ProgressBar:draw(parentX, parentY, parentWidth)
    -- Calculate the length of the progress bar
    local barLength = parentWidth - (self.x + 11) -- account for the corners and spaces, and the percentage text
    local filledLength = math.floor(barLength * self.progress / 100)
    local emptyLength = barLength - filledLength

    -- Create the progress bar string
    local bar = string.rep("█", filledLength) .. string.rep("░", emptyLength)
    local percentageText = string.format("%3d%%", self.progress)

    -- Set the progress bar color
    local oldColor = gpu.getForeground()
    gpu.setForeground(self.color)

    -- Draw the progress bar at a fixed position relative to the parent window
    gpu.set(parentX + self.x + 1, parentY + self.y + 1, bar .. " " .. percentageText)

    -- Restore the previous color
    gpu.setForeground(oldColor)
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

-- Create a window
local myWindow = Window:new(5, 5, 30, 10)

-- Create a Title and add it to the window
local myTitle = Title:new("Hello, World! This is a very long title")
myWindow:addChild(myTitle)

-- Create TextLines and add them to the window
local textLine1 = TextLine:new(0, 1, "First line of text")
local textLine2 = TextLine:new(0, 2, "Second line of text, which is also quite long")
myWindow:addChild(textLine1)
myWindow:addChild(textLine2)

-- Create a ProgressBar and add it to the window
local myProgressBar = ProgressBar:new(0, 3, 75)
myWindow:addChild(myProgressBar)

-- Redraw the window to include the Title, TextLines, and ProgressBar
myWindow:draw()



-- Create a second window
local myWindow2 = Window:new(35, 25, 50, 20)

-- Create a Title and add it to the second window
local myTitle2 = Title:new("Hello, World! too")
myWindow2:addChild(myTitle2)

-- Create TextLines and add them to the second window
local textLine3 = TextLine:new(0, 1, "Third line of text")
local textLine4 = TextLine:new(0, 2, "Fourth line of text, which is also quite long")
myWindow2:addChild(textLine3)
myWindow2:addChild(textLine4)

-- Create a ProgressBar and add it to the window
local myProgressBar = ProgressBar:new(0, 3, 23)
myWindow2:addChild(myProgressBar)

-- Redraw the second window to include the Title and TextLines
myWindow2:draw()
