local PathfindingService = game:GetService("PathfindingService")
local Workspace = game:GetService("Workspace")

local FOLDER_NAME = "SavedWaypoints"

local function getWaypointFolder()
    local folder = Workspace:FindFirstChild(FOLDER_NAME)
    if not folder then
        folder = Instance.new("Folder")
        folder.Name = FOLDER_NAME
        folder.Parent = Workspace
    end
    return folder
end

local function clearSavedWaypoints()
    local folder = getWaypointFolder()
    for _, child in ipairs(folder:GetChildren()) do
        child:Destroy()
    end
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

    local highlight = Instance.new("SelectionBox")
    highlight.Adornee = part
    highlight.Color3 = Color3.fromRGB(255, 255, 255)
    highlight.LineThickness = 0.05
    highlight.Parent = part

    return part
end

local function saveWaypoint(position, customName)
    local folder = getWaypointFolder()
    local waypointName = customName or ("Waypoint_" .. (#folder:GetChildren() + 1))

    local existing = folder:FindFirstChild(waypointName)
    if existing then
        existing:Destroy()
    end

    local marker = createWaypointMarker(position, waypointName)
    return marker
end

local function getWaypointPositions()
    local folder = Workspace:FindFirstChild(FOLDER_NAME)
    local list = {}

    if not folder then
        return list
    end

    local children = folder:GetChildren()
    table.sort(children, function(a, b)
        return a.Name < b.Name
    end)

    for _, child in ipairs(children) do
        if child:IsA("BasePart") then
            table.insert(list, child.Position)
        end
    end

    return list
end

local function moveCharacterToPosition(character, goalPosition)
    if not character then
        warn("No character provided")
        return false
    end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")

    if not humanoid or not rootPart then
        warn("Character does not have Humanoid or HumanoidRootPart")
        return false
    end

    local path = PathfindingService:CreatePath({
        AgentRadius = 2,
        AgentHeight = 5,
        AgentCanJump = true,
    })

    local success, errorMessage = pcall(function()
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
        warn("Waypoint index out of range")
        return false
    end

    local targetPosition = savedPositions[targetIndex]
    return moveCharacterToPosition(character, targetPosition)
end

_G.SaveWaypoint = saveWaypoint
_G.GetSavedWaypoints = getWaypointPositions
_G.MoveToSavedWaypoint = moveToSavedWaypoint
_G.MoveCharacterToPosition = moveCharacterToPosition
_G.ClearSavedWaypoints = clearSavedWaypoints

print("Waypoint pathfinding script loaded.")
print("Available functions:")
print("- _G.SaveWaypoint(position, optionalName)")
print("- _G.MoveToSavedWaypoint(character, index)")
print("- _G.MoveCharacterToPosition(character, position)")
print("- _G.GetSavedWaypoints()")
print("- _G.ClearSavedWaypoints()")
