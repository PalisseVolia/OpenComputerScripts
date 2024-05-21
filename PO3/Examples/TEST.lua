component = require("component")
sides = require("sides")

Rs = component.redstone

while true do
    Rs.setOutput(sides.back, 15)
    --os.sleep(1)
    Rs.setOutput(sides.back, 0)
    --os.sleep(1)
end