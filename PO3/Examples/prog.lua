local component = require("component")
local term = require("term")
local gpu = component.gpu
local event = require("event")

local function drawProgressBar(percent, length, height, x, y)
    local filledLength = math.floor(percent / 100 * length)
    gpu.setBackground(0x00FF00)
    gpu.fill(x, y, filledLength, height, " ")
    gpu.setBackground(0xFF0000)
    gpu.fill(x + filledLength, y, length - filledLength, height, " ")
    gpu.setBackground(0x000000)
    local percentageText = string.format("%d%%", percent)
    local textX = x + math.floor((length - #percentageText) / 2)
    local textY = y + math.floor(height / 2)
    gpu.set(textX, textY, percentageText)
end

local barLength = 50
local barHeight = 3
local startX = 5
local startY = 5

term.clear()

for percent = 0, 100, 5 do
    drawProgressBar(percent, barLength, barHeight, startX, startY)
    --os.sleep(0.5) -- Wait for half a second before updating
end

print("Progress complete.")
