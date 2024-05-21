local Rds = component.redstone

if Rds.getInput(sides.left) == 15 then
    Rds.setOutput(sides.back, 15)
else
    Rds.setOutput(sides.back, 0)
end