-- AutoVehicleWaypoint.server.lua
-- Paste ke ServerScriptService

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local folderName = "SavedWaypoints"

local function getWaypointFolder()
    local folder = Workspace:FindFirstChild(folderName)
    if not folder then
        folder = Instance.new("Folder")
        folder.Name = folderName
        folder.Parent = Workspace
    end
    return folder
end

local function saveWaypoint(position, name)
    local folder = getWaypointFolder()
    local waypointName = name or ("Waypoint_" .. (#folder:GetChildren() + 1))

    local old = folder:FindFirstChild(waypointName)
    if old then old:Destroy() end

    local marker = Instance.new("Part")
    marker.Name = waypointName
    marker.Anchored = true
    marker.CanCollide = false
    marker.Material = Enum.Material.Neon
    marker.Color = Color3.fromRGB(50, 255, 150)
    marker.Size = Vector3.new(2, 2, 2)
    marker.Shape = Enum.PartType.Cylinder
    marker.Position = position + Vector3.new(0, 1, 0)
    marker.Parent = folder

    return marker
end

local function getSavedWaypoints()
    local folder = Workspace:FindFirstChild(folderName)
    if not folder then return {} end

    local list = {}
    for _, child in ipairs(folder:GetChildren()) do
        if child:IsA("BasePart") then
            table.insert(list, {
                Name = child.Name,
                Position = child.Position
            })
        end
    end

    table.sort(list, function(a, b)
        return a.Name < b.Name
    end)

    return list
end

local function getPlayerVehicle(player)
    local character = player.Character
    if not character then return nil end

    local seat = character:FindFirstChildOfClass("VehicleSeat")
    if seat and seat.Occupant then
        return seat.Parent
    end

    for _, child in ipairs(character:GetChildren()) do
        if child:IsA("BasePart") then
            local parent = child.Parent
            if parent and parent:FindFirstChildOfClass("VehicleSeat") then
                return parent
            end
        end
    end

    return nil
end

local function setupVehicleDrive(vehicle)
    local root = vehicle.PrimaryPart
    if not root then
        root = vehicle:FindFirstChild("RootPart")
    end
    if not root then
        warn("Vehicle tidak punya PrimaryPart / RootPart")
        return false
    end

    local gyro = root:FindFirstChild("DriveGyro")
    if not gyro then
        gyro = Instance.new("BodyGyro")
        gyro.Name = "DriveGyro"
        gyro.MaxTorque = Vector3.new(0, 400000, 0)
        gyro.P = 3000
        gyro.Parent = root
    end

    local velocity = root:FindFirstChild("DriveVelocity")
    if not velocity then
        velocity = Instance.new("BodyVelocity")
        velocity.Name = "DriveVelocity"
        velocity.MaxForce = Vector3.new(9000, 0, 9000)
        velocity.Velocity = Vector3.new(0, 0, 0)
        velocity.Parent = root
    end

    return true, root, gyro, velocity
end

local function driveVehicleTo(vehicle, targetPos)
    local ok, root, gyro, velocity = setupVehicleDrive(vehicle)
    if not ok then return false end

    local reached = 5
    local speed = 25
    local maxTime = 300
    local startTime = tick()

    while tick() - startTime < maxTime do
        local distance = (root.Position - targetPos).Magnitude
        if distance <= reached then
            if velocity then
                velocity.Velocity = Vector3.new(0, 0, 0)
            end
            break
        end

        local direction = (targetPos - root.Position)
        local horizontalDir = Vector3.new(direction.X, 0, direction.Z).Unit
        local lookAt = CFrame.lookAt(root.Position, root.Position + horizontalDir)
        gyro.CFrame = lookAt

        local accel = horizontalDir * speed
        if velocity then
            velocity.MaxForce = Vector3.new(9000, 0, 9000)
            velocity.Velocity = Vector3.new(accel.X, 0, accel.Z)
        end

        task.wait(0.05)
    end

    if velocity then
        velocity.Velocity = Vector3.new(0, 0, 0)
    end

    return true
end

local function movePlayerVehicleToWaypoint(player, waypointIndex)
    local vehicle = getPlayerVehicle(player)
    if not vehicle then
        warn("Player belum naik kendaraan")
        return false
    end

    local waypoints = getSavedWaypoints()
    if waypointIndex < 1 or waypointIndex > #waypoints then
        warn("Waypoint index out of range")
        return false
    end

    local target = waypoints[waypointIndex].Position
    return driveVehicleTo(vehicle, target)
end

local function movePlayerVehicleToLastWaypoint(player)
    local waypoints = getSavedWaypoints()
    if #waypoints == 0 then
        warn("Tidak ada waypoint tersimpan")
        return false
    end
    return movePlayerVehicleToWaypoint(player, #waypoints)
end

local function movePlayerVehicleToAllWaypoints(player)
    local vehicle = getPlayerVehicle(player)
    if not vehicle then
        warn("Player belum naik kendaraan")
        return false
    end

    local waypoints = getSavedWaypoints()
    if #waypoints == 0 then
        warn("Tidak ada waypoint tersimpan")
        return false
    end

    for i = 1, #waypoints do
        driveVehicleTo(vehicle, waypoints[i].Position)
        task.wait(0.5)
    end

    return true
end

local event = Workspace:FindFirstChild("VehicleWaypointEvent")
if not event then
    event = Instance.new("RemoteEvent")
    event.Name = "VehicleWaypointEvent"
    event.Parent = Workspace
end

event.OnServerEvent:Connect(function(player, action, value)
    if action == "save" then
        local character = player.Character
        if not character then return end

        local root = character:FindFirstChild("HumanoidRootPart")
        if root then
            saveWaypoint(root.Position)
            event:FireClient(player, "saved", #getSavedWaypoints())
        end

    elseif action == "goLast" then
        movePlayerVehicleToLastWaypoint(player)

    elseif action == "goAll" then
        movePlayerVehicleToAllWaypoints(player)

    elseif action == "clear" then
        local folder = Workspace:FindFirstChild(folderName)
        if folder then
            for _, child in ipairs(folder:GetChildren()) do
                child:Destroy()
            end
        end
    end
end)

print("Auto vehicle waypoint server loaded")
