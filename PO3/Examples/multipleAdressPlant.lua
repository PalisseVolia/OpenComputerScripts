local component = require("component")

-- Find all agricraft_peripheral components
local analyzers = {}
for address, componentType in component.list() do
  if componentType == "agricraft_peripheral" then
    table.insert(analyzers, address)
  end
end

-- Test each Seed Analyzer by calling getPlant("EAST")
for i, analyzerAddress in ipairs(analyzers) do
  local analyzer = component.proxy(analyzerAddress)
  local plantData, err = analyzer.getPlant("EAST")
  
  if plantData then
    print("Analyzer " .. i .. " (" .. analyzerAddress .. ") detected plant: " .. plantData)
  else
    print("Analyzer " .. i .. " (" .. analyzerAddress .. ") error: " .. err)
  end
end