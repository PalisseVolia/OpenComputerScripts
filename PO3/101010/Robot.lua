-- Receiver computer
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
-- functions
-- ========================================

local color

local function BreakInferiotPlant()
    print("========================================")
    print("Breaking inferior plants...")    
    component.robot.place(sides.front)
    component.robot.swing(sides.front)
    print("Plants broken")
end
local function MoveToPlant()
    print("========================================")
    print("Moving to the plant...")
    moveTo(color, 0, 0)
    print("Plant reached")
end
local function Harvestingplant()
    print("========================================")
    print("Harvesting the plant...")
    component.robot.swing(sides.bottom)
    print("Plant harvested")
end
local function DepositInScanner()
    print("========================================")
    print("Depositing in scanner...")
    moveTo(color, 0, -1)
    component.robot.select(3)
    component.robot.drop(sides.bottom)
    print("Seed deposited")
end
local function PickCropSticks()
    print("========================================")
    print("Picking crop sticks...")
    moveTo(color, 0, 4)
    component.robot.select(16)
    component.inventory_controller.suckFromSlot(sides.front, 2, 9)
    component.inventory_controller.equip()
    print("Crop sticks picked")
end
local function PlaceCropSticks()
    print("========================================")
    print("Placing crop sticks...")
    component.robot.use(sides.bottom)
    moveTo(color, 0, 3)
    component.robot.use(sides.bottom)
    component.robot.use(sides.bottom)
    moveTo(color, 0, 2)
    component.robot.use(sides.bottom)
    component.robot.use(sides.bottom)
    moveTo(color, 0, 1)
    component.robot.use(sides.bottom)
    component.robot.use(sides.bottom)
    moveTo(color, 0, 0)
    component.robot.use(sides.bottom)
    component.robot.use(sides.bottom)
    print("Crop sticks placed")
end
local function BackToBase()
    print("========================================")
    print("Going back to base...")
    component.robot.select(1)
    moveTo(0, 0, 0)
    print("Base reached")
end
local function CleanInventory()
    print("========================================")
    print("Cleaning Inventory...")
    for i=2,16 do
        component.robot.select(i)
        component.robot.drop(sides.top)
    end
    print("Inventory cleaned")
end
local function PlantSeed()
    print("========================================")
    print("Planting seed...")
    moveTo(color, 0, 4)
    component.inventory_controller.equip()
    component.robot.use(sides.bottom)
    print("Seed planted")
end
local function GetSeed()
    print("========================================")
    print("Getting seed...")
    moveTo(color, 0, -1)
    component.robot.select(15)
    component.inventory_controller.suckFromSlot(sides.bottom, 1, 1)
    print("Seed got")
end
local function StoreSeed()
    print("========================================")
    print("Storing seed...")
    moveTo(color, 1, -1)
    robot.turnRight()
    component.robot.drop(sides.front)
    print("Seed stored")
end
local function GetNewSeed()
    print("========================================")
    print("Getting new seed...")
    moveTo(color, 2, -1)
    component.robot.suck(sides.front)
    robot.turnLeft()
    print("Seed got")
end
local function Reset()
    BackToBase()
    CleanInventory()
    component.robot.select(1)
end

-- ========================================
-- Main code
-- ========================================

-- Make sure you have a wireless network card installed
local modem = component.modem

-- Open the same port as the sender
local port = 1234
modem.open(port)
local command = 0

print("Robot for Blue or Red (B/R) ?")
local input = io.read()
while input ~= "B" and input ~= "R" do
    print("Invalid input. Please enter B for Blue or R for Red.")
    input = io.read()
end

if input == "B" then
    print("Blue selected")
    color = 1
elseif input == "R" then
    print("Red selected")
    color = -1
end

print("Waiting for messages...")

-- Listen for incoming messages
while true do
    local _, _, from, port, _, message = event.pull("modem_message")
    
    if message == "Plant at line 1" and command ~= 11 and input == "B" then
        command = 1
    elseif message == "Line 1 not done" and command ~= 22 and input == "B" then
        command = 2
    elseif message == "Line 1 done" and command ~= 33 and input == "B" then
        command = 3
    end
    if message == "Plant at line 2" and command ~= 11 and input == "R" then
        command = 1
    elseif message == "Line 2 not done" and command ~= 22 and input == "R" then
        command = 2
    elseif message == "Line 2 done" and command ~= 33 and input == "R" then
        command = 3
    end

    if command == 1 then
        command = 11

        print("Plant detected")
        BreakInferiotPlant()
        MoveToPlant()
        Harvestingplant()
        DepositInScanner()
        PickCropSticks()
        PlaceCropSticks()
        Reset()
        print("Waiting for messages...")
    end

    if command == 2 then
        command = 22

        print("Plant not ready")
        GetSeed()
        PlantSeed()
        Reset()
        print("Waiting for messages...")
    end

    if command == 3 then
        command = 33
        
        print("Plant ready")
        GetSeed()
        StoreSeed()
        GetNewSeed()
        PlantSeed()
        Reset()
        print("Waiting for messages...")
    end
end