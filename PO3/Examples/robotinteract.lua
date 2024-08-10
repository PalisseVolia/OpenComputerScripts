local component = require("component")
local sa = component.agricraft_peripheral

if sa.hasPlant("NORTH") then
    sa.analyze("NORTH")
    print(sa.getSpecimenStats())
end