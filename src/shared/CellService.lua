local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Common = ReplicatedStorage.Common

local cellService = {}
local RoutineService
local ActionService
local cell = {}
cell.__index = cell

function cellService:Init()
	RoutineService = require(Common.RoutineService)
	ActionService = require(Common.ActionService)
end

function cell:Next()
	if self.Dead == true then return end
	
	local routineID = self.Schedule[self.Pointer]
	local evalType, connectionA, connectionB, actionNumber = RoutineService.ReadAsync(routineID, #self.Schedule)
	--print(evalType, connectionA, connectionB, actionNumber)
	local response = ActionService.CallAction(self, actionNumber)

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
		]]):format(routineID, ActionService.Dictionary[actionNumber + 1][1], tostring(response), evalType, connectionA, connectionB, tostring(newPointer), tostring(self.Dead)))
		
		
	self:Draw()
end

function cell:Draw()
	self.Object.Position = UDim2.new(0, self.Position.X * 20, 0, self.Position.Y * 20)
end

function cellService.new(parent, position)
	local _position = position or {X = math.random(0, 32), Y = math.random(0, 32)}
	
	local frame = Instance.new("Frame")
	frame.Name = "Cell"
	frame.Parent = parent
	frame.Size = UDim2.new(0, 20, 0, 20)
	frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
	frame.BorderSizePixel = 3

	local self = {
		Schedule = {};
		Pointer = 1;
		Position = _position;
		Dead = false;
		Object = frame;
	}
	
	for i=1, 16, 1 do
		local randomRoutine = ""
		
		for _=1, 15, 1 do
			randomRoutine = randomRoutine .. tostring(math.random(1, 2) - 1)
		end
		
		table.insert(self.Schedule, randomRoutine)
	end
	
	self = setmetatable(self, cell)
	self:Draw()
	
	return self
end

return cellService