local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

local function saveCurrentCharacterPosition()
    local character = player.Character
    if not character then
        warn("Character belum muncul")
        return
    end

    local rootPart = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid")

    if not rootPart or not humanoid then
        warn("Character tidak valid")
        return
    end

    local position = rootPart.Position
    local savedPart = _G.SaveWaypoint(position)
    print("Waypoint tersimpan di:", position)
    print("Marker dibuat:", savedPart.Name)
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then
        return
    end

    if input.KeyCode == Enum.KeyCode.F then
        saveCurrentCharacterPosition()
    end
end)

print("Manual Save Waypoint aktif. Tekan F untuk menyimpan posisi saat ini.")
