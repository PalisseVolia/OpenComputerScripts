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

-- ========================================
-- Functions
-- ========================================

local function CleanInventory()
    print("========================================")
    print("Cleaning Inventory...")
    for i=1,16 do
        component.robot.select(i)
        component.robot.drop(sides.bottom)
    end
    print("Inventory cleaned")
end
local function BackToBase()
    print("========================================")
    print("Going back to base...")
    component.robot.select(1)
    moveTo(0, 0, 0)
    print("Base reached")
end
local function GetRedstone(slot)
    print("========================================")
    print("Getting redstone...")
    moveTo(2, 0, 0)
    robot.turnAround()
    component.robot.select(slot)
    component.robot.suck(sides.front)
    robot.turnAround()
    print("Redstone got")
end
local function GetNickelBlock(slot)
    print("========================================")
    print("Getting nickel blocs...")
    moveTo(3, 0, 0)
    robot.turnAround()
    component.robot.select(slot)
    component.robot.suck(sides.front)
    robot.turnAround()
    print("Nickel blocs got")
end
local function GetEndsteelBlock(slot)
    print("========================================")
    print("Getting Endsteel blocs...")
    moveTo(2, 1, 0)
    robot.turnAround()
    component.robot.select(slot)
    component.robot.suck(sides.front)
    robot.turnAround()
    print("Endsteel blocs got")
end
local function GetEnderpearl(slot)
    print("========================================")
    print("Getting enderpearls ...")
    moveTo(3, 1, 0)
    robot.turnAround()
    component.robot.select(slot)
    component.robot.suck(sides.front)
    robot.turnAround()
    print("Enderpearls got")
end
local function GetMachineWall(slot)
    print("========================================")
    print("Getting machine walls...")
    moveTo(1, 0, 0)
    robot.turnAround()
    component.robot.select(slot)
    component.robot.suck(sides.front)
    robot.turnAround()
    print("Machine walls got")
end

-- ========================================
-- Main
-- ========================================

while true do
        
    local input
    local amount

    while input ~= 1 and input ~= 2 do
        print("   What should be built ?")
        print("1. Machine Wall")
        print("2. Giant compact machine")
        input = tonumber(io.read())
    end

    while amount == nil do
        print("How many times ?")
        amount = tonumber(io.read())
    end

    if input == 1 then
        GetRedstone(1)
        GetRedstone(2)
        GetNickelBlock(3)
        
        for i=1,amount do
            print("Building machine wall " .. i .. "...")
            component.robot.select(3)
            moveTo(5, 0, 3)
            component.robot.place(sides.front)
            component.robot.select(2)
            moveTo(5, 1, 3)
            component.robot.place(sides.front)
            component.robot.select(1)
            moveTo(5, 7, 3)
            component.robot.drop(sides.bottom, 1)
            if component.robot.count() > 2 then
                os.sleep(3)
            else
                BackToBase()
                os.sleep(10)
                GetRedstone(1)
                GetRedstone(2)
                GetNickelBlock(3)
            end
        end

        CleanInventory()
        BackToBase()
    end

    if input == 2 then
        for i=1,amount do
            print("Building giant compact machine " .. i .. "...")
            GetMachineWall(1)
            GetMachineWall(2)
            GetEndsteelBlock(3)
            GetEnderpearl(4)

            print("========================================")
            print("Building layer 1...")
            component.robot.select(1)
            for i=1, 5 do
                for j=1, 5 do
                    moveTo(3+i, 1, 2+j)
                    component.robot.place(sides.bottom)
                end
            end

            for k=2, 4 do
                print("Building layer " .. k .. "...")
                component.robot.select(2)
                for i=1, 5 do
                    moveTo(4, k, 2+i)
                    component.robot.place(sides.bottom)
                end
                for i=1, 3 do
                    moveTo(4+i, k, 3)
                    component.robot.place(sides.bottom)
                    moveTo(4+i, k, 7)
                    component.robot.place(sides.bottom)
                end
                for i=1, 5 do
                    moveTo(8, k, 2+i)
                    component.robot.place(sides.bottom)
                end
            end

            print("placing core...")
            component.robot.select(2)
            moveTo(6, 2, 5)
            component.robot.place(sides.bottom)
            component.robot.select(3)
            moveTo(6, 3, 5)
            component.robot.place(sides.bottom)
            moveTo(6, 1, 4)
            component.robot.swing(sides.front)
            
            print("Building layer 5...")
            component.robot.select(1)
            for i=1, 5 do
                for j=1, 5 do
                    moveTo(3+i, 5, 2+j)
                    component.robot.place(sides.bottom)
                end
            end
            
            component.robot.select(4)
            moveTo(5, 7, 3)
            component.robot.drop(sides.bottom, 1)
            CleanInventory()
            BackToBase()
            os.sleep(5)
        end
        BackToBase()
    end

    os.sleep(0.1)
end