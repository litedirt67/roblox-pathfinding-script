-- DELTA EXECUTOR (ANDROID) - Roblox Waypoint Pathfinding
-- Paste ke Delta executor, tekan Execute
-- Touch screen tombol virtual untuk control

local PathfindingService = game:GetService("PathfindingService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local FOLDER_NAME = "SavedWaypoints"
local player = Players.LocalPlayer
local showUI = true

local function getWaypointFolder()
    local folder = Workspace:FindFirstChild(FOLDER_NAME)
    if not folder then
        folder = Instance.new("Folder")
        folder.Name = FOLDER_NAME
        folder.Parent = Workspace
    end
    return folder
end

local function createWaypointMarker(position, name)
    local folder = getWaypointFolder()
    local part = Instance.new("Part")
    part.Name = name or ("Waypoint_" .. (#folder:GetChildren() + 1))
    part.Anchored = true
    part.CanCollide = false
    part.Material = Enum.Material.Neon
    part.Color = Color3.fromRGB(66, 245, 125)
    part.Size = Vector3.new(2, 2, 2)
    part.Position = position + Vector3.new(0, 1, 0)
    part.Shape = Enum.PartType.Cylinder
    part.Parent = folder
    return part
end

local function saveWaypoint(position, customName)
    local folder = getWaypointFolder()
    local waypointName = customName or ("Waypoint_" .. (#folder:GetChildren() + 1))
    local marker = createWaypointMarker(position, waypointName)
    return marker
end

local function getWaypointPositions()
    local folder = Workspace:FindFirstChild(FOLDER_NAME)
    local list = {}
    if not folder then return list end
    local children = folder:GetChildren()
    table.sort(children, function(a, b) return a.Name < b.Name end)
    for _, child in ipairs(children) do
        if child:IsA("BasePart") then
            table.insert(list, child.Position)
        end
    end
    return list
end

local function moveCharacterToPosition(character, goalPosition)
    if not character then return false end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not rootPart then return false end

    local path = PathfindingService:CreatePath({
        AgentRadius = 2,
        AgentHeight = 5,
        AgentCanJump = true,
    })

    local success = pcall(function()
        path:ComputeAsync(rootPart.Position, goalPosition)
    end)

    if not success or path.Status ~= Enum.PathStatus.Success then
        humanoid:MoveTo(goalPosition)
        return true
    end

    local waypoints = path:GetWaypoints()
    for _, waypoint in ipairs(waypoints) do
        if waypoint.Action == Enum.PathWaypointAction.Jump then
            humanoid.Jump = true
        end
        humanoid:MoveTo(waypoint.Position)
        humanoid.MoveToFinished:Wait()
    end
    return true
end

local function moveToSavedWaypoint(character, waypointIndex)
    local savedPositions = getWaypointPositions()
    local targetIndex = tonumber(waypointIndex) or 1
    if targetIndex < 1 or targetIndex > #savedPositions then
        return false
    end
    local targetPosition = savedPositions[targetIndex]
    return moveCharacterToPosition(character, targetPosition)
end

local function clearAllWaypoints()
    local folder = Workspace:FindFirstChild(FOLDER_NAME)
    if folder then
        for _, child in ipairs(folder:GetChildren()) do
            child:Destroy()
        end
    end
end

local function createMobileUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "WaypointUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = player:WaitForChild("PlayerGui")

    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 280, 0, 400)
    mainFrame.Position = UDim2.new(0, 10, 0, 10)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    mainFrame.BorderColor3 = Color3.fromRGB(66, 245, 125)
    mainFrame.BorderSizePixel = 2
    mainFrame.Parent = screenGui

    -- Title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, 0, 0, 30)
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.BackgroundColor3 = Color3.fromRGB(66, 245, 125)
    titleLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
    titleLabel.Text = "Waypoint Manager"
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Parent = mainFrame

    -- Info Label
    local infoLabel = Instance.new("TextLabel")
    infoLabel.Name = "InfoLabel"
    infoLabel.Size = UDim2.new(1, -10, 0, 50)
    infoLabel.Position = UDim2.new(0, 5, 0, 35)
    infoLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    infoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    infoLabel.Text = "Total: 0"
    infoLabel.TextScaled = true
    infoLabel.Font = Enum.Font.Gotham
    infoLabel.Parent = mainFrame

    -- Save Button
    local saveButton = Instance.new("TextButton")
    saveButton.Name = "SaveButton"
    saveButton.Size = UDim2.new(1, -10, 0, 40)
    saveButton.Position = UDim2.new(0, 5, 0, 90)
    saveButton.BackgroundColor3 = Color3.fromRGB(66, 245, 125)
    saveButton.TextColor3 = Color3.fromRGB(0, 0, 0)
    saveButton.Text = "SAVE WAYPOINT"
    saveButton.TextScaled = true
    saveButton.Font = Enum.Font.GothamBold
    saveButton.BorderSizePixel = 0
    saveButton.Parent = mainFrame

    saveButton.MouseButton1Click:Connect(function()
        local character = player.Character
        if character then
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                local position = rootPart.Position
                saveWaypoint(position)
                print("✓ Waypoint saved at", position)
                infoLabel.Text = "Total: " .. #getWaypointPositions()
            end
        end
    end)

    -- Go Button
    local goButton = Instance.new("TextButton")
    goButton.Name = "GoButton"
    goButton.Size = UDim2.new(1, -10, 0, 40)
    goButton.Position = UDim2.new(0, 5, 0, 135)
    goButton.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
    goButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    goButton.Text = "GO TO LAST WAYPOINT"
    goButton.TextScaled = true
    goButton.Font = Enum.Font.GothamBold
    goButton.BorderSizePixel = 0
    goButton.Parent = mainFrame

    goButton.MouseButton1Click:Connect(function()
        local character = player.Character
        if character then
            local savedPositions = getWaypointPositions()
            if #savedPositions > 0 then
                print("📍 Moving to waypoint...")
                moveToSavedWaypoint(character, #savedPositions)
            else
                print("⚠️ No waypoints saved")
            end
        end
    end)

    -- Go All Button
    local goAllButton = Instance.new("TextButton")
    goAllButton.Name = "GoAllButton"
    goAllButton.Size = UDim2.new(1, -10, 0, 40)
    goAllButton.Position = UDim2.new(0, 5, 0, 180)
    goAllButton.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
    goAllButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    goAllButton.Text = "GO TO ALL WAYPOINTS"
    goAllButton.TextScaled = true
    goAllButton.Font = Enum.Font.GothamBold
    goAllButton.BorderSizePixel = 0
    goAllButton.Parent = mainFrame

    goAllButton.MouseButton1Click:Connect(function()
        local character = player.Character
        if character then
            local savedPositions = getWaypointPositions()
            if #savedPositions > 0 then
                print("🚀 Moving to all waypoints...")
                for i = 1, #savedPositions do
                    moveToSavedWaypoint(character, i)
                end
            end
        end
    end)

    -- Clear Button
    local clearButton = Instance.new("TextButton")
    clearButton.Name = "ClearButton"
    clearButton.Size = UDim2.new(1, -10, 0, 40)
    clearButton.Position = UDim2.new(0, 5, 0, 225)
    clearButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    clearButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    clearButton.Text = "CLEAR ALL WAYPOINTS"
    clearButton.TextScaled = true
    clearButton.Font = Enum.Font.GothamBold
    clearButton.BorderSizePixel = 0
    clearButton.Parent = mainFrame

    clearButton.MouseButton1Click:Connect(function()
        clearAllWaypoints()
        print("🗑️ All waypoints cleared")
        infoLabel.Text = "Total: 0"
    end)

    -- Hide Button
    local hideButton = Instance.new("TextButton")
    hideButton.Name = "HideButton"
    hideButton.Size = UDim2.new(1, -10, 0, 40)
    hideButton.Position = UDim2.new(0, 5, 0, 355)
    hideButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    hideButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    hideButton.Text = "HIDE UI"
    hideButton.TextScaled = true
    hideButton.Font = Enum.Font.Gotham
    hideButton.BorderSizePixel = 0
    hideButton.Parent = mainFrame

    hideButton.MouseButton1Click:Connect(function()
        mainFrame.Visible = false
    end)

    -- Show button (when UI hidden)
    local showButton = Instance.new("TextButton")
    showButton.Name = "ShowButton"
    showButton.Size = UDim2.new(0, 60, 0, 30)
    showButton.Position = UDim2.new(0, 10, 0, 10)
    showButton.BackgroundColor3 = Color3.fromRGB(66, 245, 125)
    showButton.TextColor3 = Color3.fromRGB(0, 0, 0)
    showButton.Text = "SHOW"
    showButton.TextScaled = true
    showButton.Font = Enum.Font.GothamBold
    showButton.BorderSizePixel = 0
    showButton.Visible = false
    showButton.Parent = screenGui

    showButton.MouseButton1Click:Connect(function()
        mainFrame.Visible = true
        showButton.Visible = false
    end)

    hideButton.MouseButton1Click:Connect(function()
        mainFrame.Visible = false
        showButton.Visible = true
    end)

    return screenGui
end

-- Create UI
wait(1)
local gui = createMobileUI()

print("\n========== DELTA ANDROID WAYPOINT SCRIPT ==========")
print("✓ UI Created")
print("✓ Ready to use")
print("\nTouchscreen buttons:")
print("- SAVE WAYPOINT: Save current position")
print("- GO TO LAST WAYPOINT: Move to last saved point")
print("- GO TO ALL WAYPOINTS: Move through all waypoints")
print("- CLEAR ALL WAYPOINTS: Delete all saved points")
print("- HIDE UI: Hide the interface")
print("==================================================\n")