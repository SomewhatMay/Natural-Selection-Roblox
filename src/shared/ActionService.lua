--[[
Actions:

Number of types: 9

0:
Wait (Sleep)

1-4:
View

5-9:
Move

]]--

local ActionService = {
	NumberOfActions = 9;
}
local Actions = {}
local ActionDictionary = {
	[1] = {"Wait"};
	[2] = {"View", {0, 1}}; -- Quadrant Up
	[3] = {"View", {1, 0}}; -- Quadrant Right
	[4] = {"View", {0, -1}}; -- Quadrant Down
	[5] = {"View", {-1, 0}}; -- Quadrant Left
	[6] = {"Move", {0, 1}}; -- Up
	[7] = {"Move", {1, 0}}; -- Right
	[8] = {"Move", {0, -1}}; -- Down
	[9] = {"Move", {-1, 0}}; -- Left
}

function ActionService:Init()
	return
end

function ActionService.CallAction(cell, actionNumber)
	local index = actionNumber + 1
	local redirect = ActionDictionary[index]
	--print(index, typeof(index), redirect, NumberedActions)
	local response = Actions[redirect[1]](cell, redirect[2])

	--print("Played action: " .. actionNumber .. " Response: " .. tostring(response))

	return response
end

function Actions.Move(cell, offset)
	--print(cell, offset)
	cell.Position.X += offset[1]
	cell.Position.Y += offset[2]

	return false
end

function Actions.View(cell, Offset)
	-- Do some checking

	local chance = math.random(1, 2)

	if chance == 1 then
		return true
	end

	return false
end

function Actions.Wait()
	return false
end

ActionService.Actions = Actions
ActionService.Dictionary = ActionDictionary

return ActionService