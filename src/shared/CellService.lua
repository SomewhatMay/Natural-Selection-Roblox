
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Common = ReplicatedStorage.Common

local cellService = {}
local RoutineService = require(Common.RoutineService)
local Actions = require(Common.CellActions)
local cell = {}
cell.__index = cell

function cell:Next()
	if self.Dead == true then return end
	
	local routineID = self.Schedule[self.Pointer]
	local evalType, connectionA, connectionB, actionNumber = RoutineService.PrintAsync(routineID, #self.Schedule)
	--print(evalType, connectionA, connectionB, actionNumber)
	local response = Actions.CallAction(self, actionNumber)

	local newPointer = RoutineService.EvalResponse(response, evalType, connectionA, connectionB)

	if newPointer == "__d" then
		self.Dead = true
	else
		self.Pointer = newPointer
	end
	
	print(([[
		- Routine Completed -
		ID: %s
		Action: %s
		Response: %s
		EvalType: %s
		ConnectionA: %s
		ConnectionB: %s
		NewPointer: %s
		Dead: %s
		]]):format(routineID, actionNumber, tostring(response), evalType, connectionA, connectionB, tostring(newPointer), tostring(self.Dead)))
end

function cell:Draw()
	
end

function cellService.new()
	local _position = {
		X = math.random(0, 32);
		Y = math.random(0, 32);
	}

	local self = {
		Schedule = {};
		Pointer = 1;
		Position = _position;
		Dead = false;
	}
	
	for i=1, 4, 1 do
		local randomRoutine = ""
		
		for _=1, 15, 1 do
			randomRoutine = randomRoutine .. tostring(math.random(1, 2) - 1)
		end
		
		table.insert(self.Schedule, randomRoutine)
	end
	
	self = setmetatable(self, cell)

	return self
end

return cellService