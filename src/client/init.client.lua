local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Common = ReplicatedStorage.Common

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer.PlayerGui

local WorldGui = playerGui:WaitForChild("WorldGui")
local SpacesParent = WorldGui.Spaces
local ScheduleDeep = WorldGui.ScheduleDeep

local cells = {}
local CellService = require(Common.CellService)
local ActionService = require(Common.ActionService)
local RoutineService = require(Common.RoutineService)

CellService:Init()
ActionService:Init()
RoutineService:Init()

local cell = CellService.new(SpacesParent)
print(cell)
RoutineService.DisplayScheduleAsync(cell, ScheduleDeep)

task.wait(10000)
for i=1, 10, 1 do
	cell:Next()
    task.wait(0.3)
end

print(cell)