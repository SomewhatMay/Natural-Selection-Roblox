--[[
Routine:
000 0000 0000 0000
15 bits

000
Eval Type ->
000 = Connect to A
001 = If true connect to A else connect to B
010 = If false connect to A else connect to B
011 = If true connect to A else disconnect
100 = If false connect to A else disconnect

0000
Connction A ->
- Binary representation of a connected position in schedule

0000
Connection B ->
- Binary representation of a connected position in schedule

0000
Action ->
- Binary representation of a function that is called when
  routine is active; always returns a boolean


]] --

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Storage = ReplicatedStorage.Storage
local RoutineVisualizationDemo = Storage.RoutineVisualization
local Common = ReplicatedStorage.Common

local RoutineService = {}
local TableToString
local ActionService

function RoutineService:Init()
	ActionService = require(Common.ActionService)
	TableToString = require(Common.TableToString)
end

function binaryToDecimal(bin)
	bin = string.reverse(bin)
	local sum = 0

	for i = 1, string.len(bin) do
		local num = string.sub(bin, i,i) == "1" and 1 or 0
		sum = sum + num * (2 ^ (i-1))
	end

	return sum
end

function RoutineService.EvalResponse(response, evalType, connectionA, connectionB) -- Returns a pointer
	if evalType == "continue" then
		return connectionA
	elseif evalType == "if" then
		if response == true then
			return connectionA
		else
			return connectionB
		end
	elseif evalType == "else" then
		if response == false then
			return connectionA
		else
			return connectionB
		end
	elseif evalType == "ifd" then
		if response == true then
			return connectionA
		else
			return "__d"
		end
	elseif evalType == "elsed" then
		if response == false then
			return connectionA
		else
			return "__d"
		end
	end
end

function RoutineService.ReadAsync(routine, scheduleLength) -- routine: 15 bit binary string
	routine = tostring(routine)
	assert(routine and #routine == 15, "Invaild routine object \"" .. routine .. "\"")

	-- Splitting the routine string
	local evalType = string.sub(routine, 1, 3)
	local connectionA = string.sub(routine, 4, 7)
	local connectionB = string.sub(routine, 8, 11)
	local action = string.sub(routine, 12, 15)

	evalType = tonumber(evalType, 2) % 4 -- Wrapping it
	evalType = (evalType == 0 and "continue")
		or (evalType == 1 and "if")
		or (evalType == 2 and "else")
		or (evalType == 3 and "ifd")
		or (evalType == 4 and "elsed")

	
	connectionA = (binaryToDecimal(connectionA) % scheduleLength) + 1
	connectionB = (binaryToDecimal(connectionB) % scheduleLength) + 1

	action = binaryToDecimal(action) % 9 -- Wrapping to number of possible actions

	return evalType, connectionA, connectionB, action
end

function RoutineService.PrintAsync(routine, scheduleLength)
	local evalType, connectionA, connectionB, action = RoutineService.ReadAsync(routine, scheduleLength)

	print(ActionService, ActionService.Dictionary[action + 1][1])
	print("Cell: {\n\tAction: " .. ActionService.Dictionary[action + 1][1] .. 
		"\n\tEvalType:  " .. evalType .. 
		"\n\tActionA: " .. connectionA .. "\tConnectionB: " .. connectionA)
	
	return evalType, connectionA, connectionB, action
end

function RoutineService.ConnectFrame(frame, pointA, pointB, offset)
	offset = offset or Vector2.new()
	local distance = pointA - pointB
	local midPoint = (pointA + pointB) / 2
	local length = distance.magnitude
	local rotation = math.atan2(distance.Y, distance.X)
	
	frame.Size = UDim2.new(0, length, 0, 5)
	frame.Position = UDim2.new(0, midPoint.X - offset.X, 0, midPoint.Y - offset.Y)
	frame.Rotation = math.deg(rotation)
end

function RoutineService.DisplayScheduleAsync(cell, parent)
	local routineObjects = {}
	local connectionObjects = {}
	local scheduleLength = #cell.Schedule
	
	for index, routine in pairs(cell.Schedule) do
		local evalType, connectionA, connectionB, action = RoutineService.ReadAsync(routine, scheduleLength)
		local definition = ActionService.Dictionary[action + 1]
		
		local newVis = RoutineVisualizationDemo:Clone()
		newVis.Name = "Routine_" .. routine
		newVis.Action.Text = definition[1]
		newVis.EvalType.Text = evalType
		newVis.Position = UDim2.new(math.random(), 0, math.random(), 0)
		newVis.Parent = parent
		
		if index == 1 then
			newVis.InputHub.Text = "S"
		end
		
		if evalType == "ifd" or evalType == "elsed" then
			connectionB = "D"
		end
		
		connectionObjects[newVis.ConnectionA] = {newVis.AHub, connectionA}
		connectionObjects[newVis.ConnectionB] = {newVis.BHub, connectionB}
		routineObjects[index] = newVis
	end
	
	for obj, info in pairs(connectionObjects) do
		local hubA = info[1]
		
		if info[2] ~= "D" then
			local hubB = routineObjects[info[2]].InputHub
			RoutineService.ConnectFrame(obj, hubA.AbsolutePosition + (hubA.AbsoluteSize / 2), hubB.AbsolutePosition + (hubB.AbsoluteSize / 2), obj.Parent.AbsolutePosition)
		else
			hubA.Text = "D"
			hubA.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
		end
	end
end

return RoutineService