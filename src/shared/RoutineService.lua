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

local RoutineService = {}

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
	assert(routine and #routine == 15, "Invaild routine object" .. routine)

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

	action = binaryToDecimal(action) % 13 -- Wrapping to number of possible actions

	return evalType, connectionA, connectionB, action
end

function RoutineService.PrintAsync(routine, scheduleLength)
	local evalType, connectionA, connectionB, action = RoutineService.ReadAsync(routine, scheduleLength)

	print("Cell: {\n\tAction: " .. action .. 
		"\n\tEvalType:  " .. evalType .. 
		"\n\tActionA: " .. connectionA .. "\tConnectionB: " .. connectionA)
	
	return evalType, connectionA, connectionB, action
end

return RoutineService