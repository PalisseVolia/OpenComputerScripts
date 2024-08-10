component = require("component")
computer = require("computer")
m = component.modem
s = require("sides")
t = require("term")
r = require("robot")
inv = component.inventory_controller
event = require("event")
port = 80
slotS = 3

--startup--
m.setStrength(4)

if not m.isOpen(port) then m.open(port) end


--functions--

function centreCollect()
  r.select(slotS)
  r.back()
  r.swingDown()
  r.forward()
  r.dropDown()
end

function leftMove(x)
  if x then
    r.select(slotS)
    r.suckDown()
  end
  r.back()
  r.turnLeft()
  r.forward()
  r.select(5)
  r.swingDown()
  if x then
    r.select(1)
    r.placeDown(0)
    r.turnRight()
    r.back()
    r.select(slotS)
    r.dropDown(1)
    r.forward()
    r.turnLeft()
  end
  r.back()
  r.turnRight()
  if x then
    r.select(1)
    r.placeDown(0,1)
  end
  r.forward()
end

function rightMove(x)
  if x then
    r.select(slotS)
    r.suckDown()
  end
  r.back()
  r.turnRight()
  r.forward()
  r.select(5)
  r.swingDown()
  if x then
    r.select(1)
    r.placeDown(0)
    r.turnLeft()
    r.back()
    r.select(slotS)
    r.dropDown(1)
    r.forward()
    r.turnRight()
  end
  r.back()
  r.turnLeft()
  if x then
    r.select(1)
    r.placeDown(0,1)
  end
  r.forward()
end

function cleanup()
  r.select(slotS)
  r.suckDown()
  r.turnLeft()
  r.drop()
  r.turnRight()
  leftMove()
  rightMove()
  empty()
  r.turnRight()
  for i=1,27,1 do
    if inv.getStackInSlot(3,i) ~= nil then
      r.select(slotS)
      inv.suckFromSlot(3,i)
      r.dropDown()
      r.turnLeft()
      break
    end
  end
end

function empty()
  --r.turnRight()
  for i=3,16,1 do
    if inv.getStackInInternalSlot(i) ~= nil then
      r.select(i)
      r.drop()
    end
  end
  --r.turnLeft()
end

function compareItemInSlot(item,slot) -- Compares $item with the item in $slot
    itemInfo = component.inventory_controller.getStackInInternalSlot(slot)
  if itemInfo ~= nil then
    if item == itemInfo.name then
      return true
    end
  end
  return false
end

function sticks()
  if r.count(1) <= 10 and compareItemInSlot("agricraft:crop_sticks",2) then
    r.select(2)
    r.transferTo(1)
  elseif r.count(1) < 3 then
    print("Out of Crop Sticks")
    while r.count(1) < 3 do
      os.sleep(1)
    end
  end
end

function switch(x)
  local switch = {
    [0] = function() --Collect crossbreed
      print("Collect Centre.")
      centreCollect()
    end,
    [1] = function() --Replace Left parent
      print("Replace Left Parent.")
      leftMove(1)
    end,
    [2] = function() --Replace Right parent
      print("Replace Right Parent.")
      rightMove(1)
    end,
    [3] = function() --Remove both parents
      print("Cleanup.")
      cleanup()
    end,
    [4] = function() --Dump FalseSeed
      print("False Seed.")
      r.back()
      r.select(1)
      r.placeDown(0, 1)
      r.forward()
      r.select(slotS)
      r.suckDown()
    end
  }

  local f = switch[x]
  if (f) then
    f()
  end
end


--Main--

function main()
  while 1 do
    local _, _, _, _, _, message = event.pull("modem_message")
    print(message .. " : " .. computer.energy() / computer.maxEnergy())
    while computer.energy() / computer.maxEnergy() <= 0.20 do
      os.sleep(1)
    end
    switch(message)
    sticks()
    empty()
    m.broadcast(port, 1)
  end
end

empty()
sticks()
m.broadcast(port, 0)
main()