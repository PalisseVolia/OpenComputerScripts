component = require("component")
m = component.modem
a = component.agricraft_peripheral
t = require("term")
s = require("sides")
event = require("event")
port = 80
parents = {0, 0}

m.setStrength(4)
if not m.isOpen(port) then m.open(port) end

--0 - CollectCentre, 1 - ReplaceLeft, 2 - ReplaceRight, 3 - Cleanup, 4 - FalseSeed
function bc(x)
  m.broadcast(port, x)
  local _, _, _, _, _, message = event.pull("modem_message")
end

function main()

  while a.getSpecimen() == "Air" and a.hasPlant("NORTH") == nil do 
    local _, _, _, _, _, message = event.pull(5, "modem_message")
  end

  if a.getSpecimen() ~= "Air" then
    if not a.isAnalyzed() then a.analyze() end
    while not a.isAnalyzed() do
      os.sleep(0.5)
    end

    local s1, s2, s3 = a.getSpecimenStats()
    local stats = s1 + s2 + s3

    if stats == 30 then
      print("30 Seed!")
      bc(3)
      parents[1] = 0
      parents[2] = 0
      stats = 0
    else
      print("Seed: " .. stats)
      if parents[1] <= parents[2] then
        if stats > parents[1] then
          print("Replace Left.")
          bc(1)
          parents[1] = stats
        else
          bc(4)
          print("False Seed.")
        end
      elseif stats > parents[2] then
        print("Replace Right.")
        bc(2)
        parents[2] = stats
      else
        print("False Seed.")
        bc(4)
      end
    end
  end

  if a.hasPlant("NORTH") == true then bc(0) end

end


while 1 do
  main()
  os.sleep(1)
end