local component = require "component"
local event = require "event"
local term = require "term"
local computer = require "computer"
Reactor = component.nc_fission_reactor

computer.beep()

print("Initialising...")

local power = Reactor.getEnergyChange() 
print("Power: " .. power)

repeat
 local power = Reactor.getEnergyChange() 
 term.clear()
  if (power < 0) then
print("Reactor ONLINE")
  else
print("Reactor OFFLINE")
  end
  CurrentHeat = Reactor.getHeatLevel()
  MaxHeat = 2400000
  print("")
  print("Heat")
  print(CurrentHeat .. "/" .. MaxHeat)
  Cells = Reactor.getNumberOfCells()
  print("")
  print("Cells Remaining")
  print(Cells)
 
  if (CurrentHeat > 0) then
computer.beep()
  end
  if (CurrentHeat > (MaxHeat/2)) then
Reactor.deactivate()    
  end
until event.pull(1) == "interrupted"