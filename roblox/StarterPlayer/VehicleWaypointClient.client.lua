-- StarterPlayer/VehicleWaypointClient.client.lua
-- Client script untuk kontrol kendaraan waypoint via keyboard

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local event = Workspace:WaitForChild("VehicleWaypointEvent")

local function savePosition()
    local character = player.Character
    if not character then
        print("⚠️ Character belum spawn")
        return
    end

    local root = character:FindFirstChild("HumanoidRootPart")
    if root then
        event:FireServer("save", root.Position)
    end
end

local function goToLastWaypoint()
    local character = player.Character
    if not character then
        print("⚠️ Character belum spawn")
        return
    end

    event:FireServer("goLast")
end

local function goToAllWaypoints()
    local character = player.Character
    if not character then
        print("⚠️ Character belum spawn")
        return
    end

    event:FireServer("goAll")
end

local function clearAllWaypoints()
    event:FireServer("clear")
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if input.KeyCode == Enum.KeyCode.F then
        print("💾 Menyimpan waypoint...")
        savePosition()

    elseif input.KeyCode == Enum.KeyCode.G then
        print("🚗 Menuju waypoint terakhir...")
        goToLastWaypoint()

    elseif input.KeyCode == Enum.KeyCode.H then
        print("🚀 Menuju semua waypoint...")
        goToAllWaypoints()

    elseif input.KeyCode == Enum.KeyCode.X then
        print("🗑️ Menghapus semua waypoint...")
        clearAllWaypoints()
    end
end)

event.OnClientEvent:Connect(function(action, value)
    if action == "saved" then
        print("✓ Waypoint berhasil disimpan! Total:", value)
    end
end)

print("\n========== VEHICLE WAYPOINT CLIENT ==========")
print("✓ Client loaded")
print("\nKeyboard Controls:")
print("F = Save waypoint di posisi saat ini")
print("G = Gerakkan kendaraan ke waypoint terakhir")
print("H = Gerakkan kendaraan ke semua waypoint")
print("X = Hapus semua waypoint")
print("=========================================\n")
