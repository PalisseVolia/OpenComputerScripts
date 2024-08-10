local robot = require("robot")

-- ========================================
-- MoveTo function
-- ========================================

local currentX = 0
local currentY = 0
local currentZ = 0

local test

local function moveTo(x, y, z)
    local deltaX = x - currentX
    local deltaY = y - currentY
    local deltaZ = z - currentZ

    if deltaX > 0 then
        robot.turnRight()
        for i=1,deltaX do
            test = robot.forward()
            if test ~= nil then
                currentX = currentX + 1
            end
        end
        robot.turnLeft()
    elseif deltaX < 0 then
        robot.turnLeft()
        for i=1,-deltaX do
            test = robot.forward()
            if test ~= nil then
                currentX = currentX - 1
            end
        end
        robot.turnRight()
    end

    if deltaY > 0 then
        for i=1,deltaY do
            test = robot.up()
            if test ~= nil then
                currentY = currentY + 1
            end
        end
    elseif deltaY < 0 then
        for i=1,-deltaY do
            test = robot.down()
            if test ~= nil then
                currentY = currentY - 1
            end
        end
    end

    if deltaZ > 0 then
        for i=1,deltaZ do
            test = robot.forward()
            if test ~= nil then
                currentZ = currentZ + 1
            end
        end
    elseif deltaZ < 0 then
        test = robot.turnAround()
        for i=1,-deltaZ do
            test = robot.forward()
            if test ~= nil then
                currentZ = currentZ - 1
            end
        end
        robot.turnAround()
    end

    if currentX ~= x or currentY ~= y or currentZ ~= z then
        moveTo(x, y, z)
    end
end

moveTo(2, 1, 5)