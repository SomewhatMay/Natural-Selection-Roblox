
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Common = ReplicatedStorage.Common

local cells = {}
local CellService = require(Common.CellService)
local CellActions = require(Common.CellActions)
local RoutineService = require(Common.RoutineService)

local cell = CellService.new()
print(cell)

for i=1, 10, 1 do
	cell:Next()
end

print(cell)