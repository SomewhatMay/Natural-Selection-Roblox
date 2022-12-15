local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
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

ContextActionService:BindAction("CloseRoutineVisualization", function(_, state)
    if state == Enum.UserInputState.Begin then
        RoutineService.HideScheduleAsync(ScheduleDeep)
    end
end, true, Enum.KeyCode.P)

ContextActionService:BindAction("AddCell", function(_, state)
    if state == Enum.UserInputState.Begin then
        local newCell = CellService.new(SpacesParent, ScheduleDeep)
        table.insert(cells, newCell)
    end
end, true, Enum.KeyCode.C)

local cycleEnabled = false

local function cycle()  
    for _, cell in pairs(cells) do
        cell:Next()
    end
end

local cycleDelay = 1/2
ContextActionService:BindAction("StartPauseCycle", function(_, state)
     if state == Enum.UserInputState.Begin then
        if not cycleEnabled then
            local last = tick()
            
            RunService:BindToRenderStep("Cycle", Enum.RenderPriority.Camera.Value + 1, function()
                if (tick() - last) <= cycleDelay then return end
                
                cycle()
                last = tick()
            end)
        else
            RunService:UnbindFromRenderStep("Cycle")
        end
        
        cycleEnabled = not cycleEnabled
     end
end, false, Enum.KeyCode.S)

ContextActionService:BindAction("NextCycle", function(_, state)
    if state == Enum.UserInputState.Begin then
        cycle()
    end
end, false, Enum.KeyCode.N)