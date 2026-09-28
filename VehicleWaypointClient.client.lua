-- VehicleWaypointClient.client.lua
-- Paste ke StarterPlayer/StarterPlayerScripts

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local event = Workspace:WaitForChild("VehicleWaypointEvent")

local function savePosition()
    local character = player.Character
    if not character then return end

    local root = character:FindFirstChild("HumanoidRootPart")
    if root then
        event:FireServer("save", root.Position)
    end
end

local function goToLastWaypoint()
    event:FireServer("goLast")
end

local function goToAllWaypoints()
    event:FireServer("goAll")
end

local function clearAllWaypoints()
    event:FireServer("clear")
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if input.KeyCode == Enum.KeyCode.F then
        savePosition()
    elseif input.KeyCode == Enum.KeyCode.G then
        goToLastWaypoint()
    elseif input.KeyCode == Enum.KeyCode.H then
        goToAllWaypoints()
    elseif input.KeyCode == Enum.KeyCode.X then
        clearAllWaypoints()
    end
end)

event.OnClientEvent:Connect(function(action, value)
    if action == "saved" then
        print("Waypoint berhasil disimpan. Total:", value)
    end
end)

print("Vehicle waypoint client loaded")
print("F = save waypoint")
print("G = go to last waypoint")
print("H = go to all waypoints")
print("X = clear all waypoints")
