local component = require("component")
local event = require("event")
local robot = require("robot")
local sides = require("sides")

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

local function getItem(x, y, z, slot, amount)
    moveTo(x, y, z)
    robot.turnAround()
    robot.select(slot)
    robot.suck(amount, sides.front)
    robot.turnAround()
end

local function useItem(slot)
    robot.select(slot)
    component.inventory_controller.equip()
    robot.use(sides.front)
end

print("========================================")
print("GETTING MATERIALS")
print("========================================")
print("Getting catalyst 1")
getItem(1, 0, 0, 1, 1)
print("Getting catalyst 2")
getItem(2, 0, 0, 2, 1)
print("Getting catalyst 3")
getItem(2, 1, 0, 3, 1)
print("Getting catalyst 4")
getItem(1, 1, 0, 4, 1)
print("Getting center item")
getItem(1, 2, 0, 5, 1)
print("Getting Ashes")
getItem(2, 2, 0, 6, 30)
getItem(2, 2, 0, 7, 30)

print("========================================")
print("INPUTTING MATERIALS")
print("========================================")
print("Inputting catalyst 1")
moveTo(0, 0, 1)
useItem(1)
print("Inputting catalyst 2")
moveTo(1, 0, 2)
robot.turnLeft()
useItem(2)
robot.turnRight()
print("Inputting Ashes 1")
moveTo(1, 1, 2)
robot.turnRight()
useItem(6)
robot.turnLeft()
print("Inputting catalyst 3")
moveTo(0, 0, 3)
robot.turnAround()
useItem(3)
robot.turnAround()
print("Inputting Ashes 1")
moveTo(-1, 1, 2)
robot.turnLeft()
useItem(7)
robot.turnRight()
print("Inputting catalyst 4")
moveTo(-1, 0, 2)
robot.turnRight()
useItem(4)
robot.turnLeft()
print("Inputting center item")
moveTo(0, 1, 2)
robot.select(5)
component.inventory_controller.equip()
robot.useDown()

print("========================================")
print("SENDING PULSE")
print("========================================")
moveTo(0, 2, 1)
component.redstone.setOutput(sides.top, 15)

print("========================================")
print("GET ITEM")
print("========================================")
robot.select(1)
while not component.tractor_beam.suck() do
    os.sleep(0.1)
end
moveTo(0, 0, 0)
robot.drop(sides.left)