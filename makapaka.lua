--[[ LEAKED BY
    .___             .__    .___                              
  __| _/______  ____ |__| __| _/_  _  _______ _______   ____  
 / __ |\_  __ \/  _ \|  |/ __ |\ \/ \/ /\__  \\_  __ \_/ __ \ 
/ /_/ | |  | \(  <_> )  / /_/ | \     /  / __ \|  | \/\  ___/ 
\____ | |__|   \____/|__\____ |  \/\_/  (____  /__|    \___  >
     \/                      \/              \/            \/ 

.gg/droidware on top anyway
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local mouse = player:GetMouse()
print("[AR2 SCRIPTS] ORANGE_UI_V2_20261013 loaded")

--==================================================
-- CLEANUP
--==================================================

local oldGui = playerGui:FindFirstChild("MegaAdminMenu")

if oldGui then
        oldGui:Destroy()
end

local oldBlur = Lighting:FindFirstChild("AdminMenuBlur")

if oldBlur then
        oldBlur:Destroy()
end

--==================================================
-- UI HELPERS
--==================================================

local function addCorner(obj, radius)
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, radius or 12)
        corner.Parent = obj
        return corner
end

local function addStroke(obj, color, thickness, transparency)
        local stroke = Instance.new("UIStroke")
        stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        stroke.Color = color or Color3.fromRGB(255, 255, 255)
        stroke.Thickness = thickness or 1
        stroke.Transparency = transparency or 0
        stroke.Parent = obj
        return stroke
end

local function addGradient(obj, color1, color2, color3, rotation)
        local gradient = Instance.new("UIGradient")

        gradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, color1),
                ColorSequenceKeypoint.new(0.5, color2),
                ColorSequenceKeypoint.new(1, color3 or color2),
        })

        gradient.Rotation = rotation or 0
        gradient.Parent = obj

        return gradient
end

local function tween(obj, time, props)
        local t = TweenService:Create(
                obj,
                TweenInfo.new(
                        time,
                        Enum.EasingStyle.Quint,
                        Enum.EasingDirection.Out
                ),
                props
        )

        t:Play()

        return t
end

local function tweenFast(obj, props)
        local t = TweenService:Create(
                obj,
                TweenInfo.new(
                        0.13,
                        Enum.EasingStyle.Quad,
                        Enum.EasingDirection.Out
                ),
                props
        )

        t:Play()

        return t
end

--==================================================
-- CHARACTER
--==================================================

local function getCharacter()
        return player.Character
end

local function getRoot()
        local character = getCharacter()

        if not character then
                return nil
        end

        return character:FindFirstChild("HumanoidRootPart")
end

local AR2_CFG
local AR2_stopImportedFeatures
local AR2_weaponName
do
-- Imported feature state: Cars, Map, Freeze Zombies, and Lighting.
-- The existing ESP/Aimbot, teleport and key window remain owned by this file.
local AR2_LocalPlayer, AR2_Workspace, AR2_Players = player, Workspace, Players
local AR2_RunService, AR2_UserInputService = RunService, UserInputService
local AR2_Lighting, AR2_HttpService = Lighting, game:GetService("HttpService")
local AR2_Vehicles = Workspace:FindFirstChild("Vehicles")
local AR2_gethui = gethui
AR2_CFG = {
    car = {
        fuel=false, boost=false, god=false, maxTraction=false, allCars=false,
        speed=120, torque=3, boatMode=false, removeDrag=false, fullSteer=false,
        noclipSpeed=90, noclipEjectDelay=0.15, fly=false, flySpeed=100,
    },
    radar = {
        on=false, names=true, localToo=false, armedColor=true, weapon=false, dist=false,
        vehicles={on=false,names=true,dist=true},
        corpses={on=false,names=true,dist=true},
    },
    minimap = {on=false,size=200,x=10,y=50},
    misc = {freeze=false,freezeAll=false,freezeAnchor=true,freezeRadius=300,
        playerJesus=false,removeShadows=false,carNoclip=false},
    visuals = {fullbright=false,nofog=false,setTime=false,brightness=3,time=14,skybox="Default"},
    ui = {sizePreset="Default", accentHue=28, transparency=0.42, cornerRadius=5,
        glow=true, compact=false,
        accentRGB={255,119,0},backgroundRGB={28,13,7},panelRGB={45,24,12}},
}

-- The original Player Jesus mode swaps the game's Swim Surface tag.
local AR2_jesusParts = setmetatable({}, {__mode="k"})
local AR2_jesusConnection
local function AR2_jesusTagPart(part)
    if part:IsA("BasePart") and part:HasTag("Swim Surface") then
        part:RemoveTag("Swim Surface")
        part:AddTag("Player Jesus")
        AR2_jesusParts[part] = true
    end
end
function AR2_setPlayerJesus(enabled)
    AR2_CFG.misc.playerJesus = enabled == true
    if AR2_jesusConnection then AR2_jesusConnection:Disconnect(); AR2_jesusConnection = nil end
    if not enabled then
        for part in pairs(AR2_jesusParts) do
            pcall(function()
                if part.Parent and part:HasTag("Player Jesus") then
                    part:RemoveTag("Player Jesus")
                    part:AddTag("Swim Surface")
                end
            end)
            AR2_jesusParts[part] = nil
        end
        return
    end
    local map = AR2_Workspace:FindFirstChild("Map")
    local water = (map and map:FindFirstChild("Water")) or AR2_Workspace:FindFirstChild("Water")
    if not water then return end
    for _, part in ipairs(water:GetDescendants()) do pcall(AR2_jesusTagPart, part) end
    AR2_jesusConnection = water.DescendantAdded:Connect(function(part)
        if AR2_CFG.misc.playerJesus then pcall(AR2_jesusTagPart, part) end
    end)
end

local function AR2_localPosition()
    local root = getRoot()
    return root and root.Position or (Workspace.CurrentCamera and Workspace.CurrentCamera.CFrame.Position) or Vector3.zero
end

local function AR2_carBase(model)
    return model and (model:FindFirstChild("Base") or model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart"))
end

local function AR2_carPick()
    local character = player.Character
    local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")
    local seat = humanoid and humanoid.SeatPart
    local vehicles = Workspace:FindFirstChild("Vehicles")
    if not vehicles then return nil end
    AR2_Vehicles = vehicles
    if seat then
        local node = seat
        while node and node.Parent do
            if node.Parent == vehicles then return node end
            node = node.Parent
        end
    end
    local best, distance = nil, math.huge
    for _, model in ipairs(vehicles:GetChildren()) do
        if model:IsA("Model") then
            local root = AR2_carBase(model)
            if root then
                local nextDistance = (root.Position - AR2_localPosition()).Magnitude
                if nextDistance < distance then best, distance = model, nextDistance end
            end
        end
    end
    return best
end

AR2_weaponName = function(model)
    local animator = model and model:FindFirstChild("Animator")
    local value = animator and animator:FindFirstChild("EquippedItem")
    if value and value:IsA("ValueBase") then
        local raw = value.Value
        if type(raw) == "table" then return raw.ItemName or raw.Name end
        if type(raw) == "string" and raw ~= "" and raw ~= "[]" then
            local ok, item = pcall(AR2_HttpService.JSONDecode, AR2_HttpService, raw)
            if ok and type(item) == "table" then return item.ItemName or item.Name end
            return raw
        end
    end
    if model then
        for _, child in ipairs(model:GetChildren()) do
            if child:IsA("Tool") then return child.Name end
        end
    end
    return nil
end

local AR2_api = {}
function AR2_api.players(includeLocal)
    local entries, origin = {}, AR2_localPosition()
    local folder = Workspace:FindFirstChild("Characters")
    local candidates = folder and folder:GetChildren() or {}
    if not folder then
        for _, other in ipairs(Players:GetPlayers()) do
            if other.Character then candidates[#candidates+1] = other.Character end
        end
    end
    for _, model in ipairs(candidates) do
        if model:IsA("Model") then
            local owner = Players:GetPlayerFromCharacter(model)
            local localModel = owner == player or model == player.Character or model.Name == player.Name
            local root = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("UpperTorso")
            if root and (includeLocal or not localModel) then
                local item = AR2_weaponName(model)
                entries[#entries+1] = {
                    model=model,root=root,position=root.Position,
                    isLocal=localModel,name=owner and owner.Name or model.Name,
                    item=item,armed=item~=nil,distance=(root.Position-origin).Magnitude,
                }
            end
        end
    end
    return entries
end

function AR2_api.zombies()
    local entries, origin = {}, AR2_localPosition()
    local folder = Workspace:FindFirstChild("Zombies")
    if not folder then return entries end
    for _, model in ipairs(folder:GetChildren()) do
        local root = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("UpperTorso")
        if root then
            entries[#entries+1] = {model=model,root=root,distance=(root.Position-origin).Magnitude}
        end
    end
    return entries
end

function AR2_api.vehicles()
    local entries, origin = {}, AR2_localPosition()
    local folder = Workspace:FindFirstChild("Vehicles")
    if not folder then return entries end
    for _, model in ipairs(folder:GetChildren()) do
        local root = AR2_carBase(model)
        if root then entries[#entries+1] = {
            model=model,root=root,name=model.Name,distance=(root.Position-origin).Magnitude,
        } end
    end
    return entries
end

function AR2_api.corpses()
    local entries, origin = {}, AR2_localPosition()
    local folder = Workspace:FindFirstChild("Corpses")
    if not folder then return entries end
    for _, model in ipairs(folder:GetChildren()) do
        local root = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Head")
            or model:FindFirstChildWhichIsA("BasePart",true)
        if root then entries[#entries+1] = {
            model=model,root=root,position=root.Position,name=model.Name,
            distance=(root.Position-origin).Magnitude,
        } end
    end
    return entries
end

local AR2_MAP_ORIGIN = CFrame.new(Vector3.new(-7349.55,0,-6187.35),Vector3.new(-7349.55,0,-6186.35))
local AR2_MAP_SX, AR2_MAP_SZ = -13499.068, -12386.184
local AR2_MAP_IMAGE = "rbxassetid://102357544057594"
local function AR2_worldToMap(position)
    local rel = AR2_MAP_ORIGIN:PointToObjectSpace(position)
    return rel.X / AR2_MAP_SX, rel.Z / AR2_MAP_SZ
end


-- RADAR
-- =============================================
AR2_radar = { running = false, layer = "off", players = 0, drawn = 0, sample = "" }
do
    local MAP_ORIGIN = CFrame.new(Vector3.new(-7349.55, 0, -6187.35), Vector3.new(-7349.55, 0, -6186.35))
    local MAP_SX, MAP_SZ = -13499.068, -12386.184
    local function worldToMap(position)
        local rel = MAP_ORIGIN:PointToObjectSpace(position)
        return rel.X / MAP_SX, rel.Z / MAP_SZ
    end
    local RADAR_COLOR = { normal = Color3.fromRGB(120,190,255), armed = Color3.fromRGB(255,150,50), localP = Color3.fromRGB(255,220,60), veh = Color3.fromRGB(90,255,140), corpse = Color3.fromRGB(200,200,205) }
    local radarConn, radarDots = nil, {}
    local radarLayer, radarMarker, radarNextScan = nil, nil, 0

    local function radarRendered(gui)
        if gui.AbsoluteSize.X <= 0 then return false end
        local node = gui
        while node do
            if node:IsA("ScreenGui") then return node.Enabled end
            if node:IsA("GuiObject") and not node.Visible then return false end
            node = node.Parent
        end
        return true
    end

    -- Attach ONLY to the game minimap's "LocalMarker" (the local player's own
    -- dot). Its Parent is the real map layer, so UDim2.fromScale positions our
    -- dots inside the minimap exactly like the game's own marker.
    -- NO fallback to arbitrary frames and NO other marker names: matching
    -- "Arrow"/"PlayerMarker" grabbed the HUD compass at the top of the screen,
    -- which is what put every dot at the top instead of on the map.
    local function radarMarkerLayer()
        if radarMarker and radarMarker.Parent and radarRendered(radarMarker) then
            return radarLayer, radarMarker, "ok"
        end
        local now = os.clock()
        if now < radarNextScan then return radarLayer, radarMarker, "map not open" end
        radarNextScan = now + 2.0
        radarLayer, radarMarker = nil, nil
        local gui = AR2_LocalPlayer:FindFirstChild("PlayerGui")
        if not gui then return nil, nil, "no PlayerGui" end

        local anyMarker = false
        for _, descendant in ipairs(gui:GetDescendants()) do
            if descendant.Name == "LocalMarker" and descendant:IsA("GuiObject") then
                anyMarker = true
                if radarRendered(descendant) then
                    radarLayer, radarMarker = descendant.Parent, descendant
                    return descendant.Parent, descendant, "ok"
                end
            end
        end
        return nil, nil, anyMarker and "map not open" or "no LocalMarker"
    end

    local function radarMakeDot(zbase)
        local dot = Instance.new("Frame")
        dot.Name = "ar2_dot"
        dot.AnchorPoint = Vector2.new(0.5,0.5)
        dot.Size = UDim2.fromOffset(12,12)
        dot.BorderSizePixel = 0
        dot.ZIndex = zbase + 5
        local round = Instance.new("UICorner") round.CornerRadius = UDim.new(1,0) round.Parent = dot
        local edge = Instance.new("UIStroke") edge.Color = Color3.fromRGB(0,0,0) edge.Thickness = 1.5 edge.Transparency = 0.25 edge.Parent = dot
        local name = Instance.new("TextLabel")
        name.Name = "Name"
        name.BackgroundTransparency = 1
        name.AnchorPoint = Vector2.new(0,0.5)
        name.Position = UDim2.fromOffset(10,0)
        name.Size = UDim2.fromOffset(200,28)
        name.Font = Enum.Font.GothamBold
        name.TextSize = 12
        name.TextXAlignment = Enum.TextXAlignment.Left
        name.TextStrokeTransparency = 0.4
        name.ZIndex = zbase + 6
        name.Parent = dot
        return dot
    end

    local function radarColorFor(entry)
        if entry.isLocal then return RADAR_COLOR.localP end
        if AR2_CFG.radar.armedColor and entry.armed then return RADAR_COLOR.armed end
        return RADAR_COLOR.normal
    end

    local function radarClearDots()
        for name, dot in pairs(radarDots) do
            dot:Destroy()
            radarDots[name] = nil
        end
    end

    local function radarStep()
        if not AR2_CFG.radar.on then
            if next(radarDots) then radarClearDots() end
            AR2_radar.layer, AR2_radar.players, AR2_radar.drawn = "disabled", 0, 0
            return
        end
        local parent, localMarker, why = radarMarkerLayer()
        AR2_radar.layer = why
        if not parent then
            if next(radarDots) then radarClearDots() end
            AR2_radar.players, AR2_radar.drawn = 0, 0
            return
        end
        local zbase = localMarker and localMarker.ZIndex or 10
        local seen, drawn = {}, 0

        -- one placer for every marker type -> identical positioning to the
        -- working player dots (same parent, same worldToMap, same dot).
        local function place(key, worldPos, colour, labelText)
            seen[key] = true
            local dot = radarDots[key]
            if not dot or dot.Parent ~= parent then
                if dot then dot:Destroy() end
                dot = radarMakeDot(zbase)
                dot.Parent = parent
                radarDots[key] = dot
            end
            local x, z = worldToMap(worldPos)
            dot.Position = UDim2.fromScale(x, z)
            dot.BackgroundColor3 = colour
            local label = dot:FindFirstChild("Name")
            if label then
                label.Text = labelText or ""
                label.Visible = labelText ~= nil and labelText ~= ""
                label.TextColor3 = colour
            end
            drawn = drawn + 1
        end

        -- players
        local live = AR2_api.players(true)
        AR2_radar.players = #live
        for _, e in ipairs(live) do
            if (AR2_CFG.radar.localToo or not e.isLocal) and e.root then
                local parts = {}
                if AR2_CFG.radar.names then parts[#parts+1] = e.name end
                if AR2_CFG.radar.weapon and e.item then parts[#parts+1] = "["..e.item.."]" end
                if AR2_CFG.radar.dist then parts[#parts+1] = string.format("%.0fs", e.distance) end
                place("p:"..e.name, e.root.Position, radarColorFor(e), #parts>0 and table.concat(parts,"  ") or nil)
            end
        end

        -- vehicles
        if AR2_CFG.radar.vehicles and AR2_CFG.radar.vehicles.on then
            for _, e in ipairs(AR2_api.vehicles()) do
                if e.root then
                    local parts = {}
                    if AR2_CFG.radar.vehicles.names then parts[#parts+1] = e.name end
                    if AR2_CFG.radar.vehicles.dist then parts[#parts+1] = string.format("%.0fs", e.distance) end
                    place("v:"..e.model:GetFullName(), e.root.Position, RADAR_COLOR.veh, #parts>0 and table.concat(parts,"  ") or nil)
                end
            end
        end

        -- corpses
        if AR2_CFG.radar.corpses and AR2_CFG.radar.corpses.on then
            for _, e in ipairs(AR2_api.corpses()) do
                local pos = e.position or (e.root and e.root.Position)
                if pos then
                    local parts = {}
                    if AR2_CFG.radar.corpses.names then parts[#parts+1] = e.name end
                    if AR2_CFG.radar.corpses.dist then parts[#parts+1] = string.format("%.0fs", e.distance) end
                    place("c:"..tostring(e.name), pos, RADAR_COLOR.corpse, #parts>0 and table.concat(parts,"  ") or nil)
                end
            end
        end

        AR2_radar.drawn = drawn
        for key, dot in pairs(radarDots) do
            if not seen[key] then dot:Destroy() radarDots[key] = nil end
        end
    end

    function AR2_radar.start()
        if radarConn then return end
        AR2_radar.running = true
        AR2_radar.layer = "starting"
        radarConn = AR2_RunService.Heartbeat:Connect(function()
            if os.clock() - (AR2_radar.lastStep or 0) < 0.2 then return end
            AR2_radar.lastStep = os.clock()
            local ok, err = pcall(radarStep)
            if not ok then AR2_radar.layer = "error: "..tostring(err) end
        end)
    end

    function AR2_radar.stop()
        AR2_radar.running = false
        if radarConn then radarConn:Disconnect() radarConn = nil end
        radarClearDots()
        AR2_radar.layer, AR2_radar.players, AR2_radar.drawn = "off", 0, 0
    end

    function AR2_radar.destroy()
        AR2_radar.stop()
        radarLayer, radarMarker = nil, nil
        radarNextScan = 0
    end
end

-- =============================================

-- MINIMAP
-- =============================================
AR2_minimapEnabled = false
AR2_minimapGui = nil
AR2_minimapImg = nil
AR2_minimapYouDot = nil
AR2_minimapDots = {}
AR2_minimapConn = nil

function AR2_buildMinimap()
    local host = playerGui
    AR2_minimapGui = Instance.new("ScreenGui")
    AR2_minimapGui.Name = "ar2_minimap"
    AR2_minimapGui.ResetOnSpawn = false
    AR2_minimapGui.IgnoreGuiInset = true
    AR2_minimapGui.DisplayOrder = 899
    AR2_minimapGui.Enabled = AR2_minimapEnabled
    AR2_minimapGui.Parent = host
    AR2_minimapImg = Instance.new("ImageButton")
    AR2_minimapImg.Size = UDim2.fromOffset(AR2_CFG.minimap.size, AR2_CFG.minimap.size)
    AR2_minimapImg.Position = UDim2.fromOffset(AR2_CFG.minimap.x, AR2_CFG.minimap.y)
    AR2_minimapImg.BackgroundColor3 = Color3.fromRGB(20,24,30)
    AR2_minimapImg.Image = AR2_MAP_IMAGE
    AR2_minimapImg.ScaleType = Enum.ScaleType.Stretch
    AR2_minimapImg.AutoButtonColor = false
    AR2_minimapImg.BorderSizePixel = 0
    AR2_minimapImg.Parent = AR2_minimapGui
    local corner = Instance.new("UICorner") corner.CornerRadius = UDim.new(0,6) corner.Parent = AR2_minimapImg
    AR2_minimapYouDot = Instance.new("Frame")
    AR2_minimapYouDot.AnchorPoint = Vector2.new(0.5,0.5)
    AR2_minimapYouDot.Size = UDim2.fromOffset(7,7)
    AR2_minimapYouDot.BackgroundColor3 = Color3.fromRGB(255,220,60)
    AR2_minimapYouDot.BorderSizePixel = 0
    AR2_minimapYouDot.ZIndex = 5
    AR2_minimapYouDot.Parent = AR2_minimapImg
end

function AR2_updateMinimap()
    if not AR2_minimapEnabled then
        if AR2_minimapGui then AR2_minimapGui.Enabled = false end
        return
    end
    if not AR2_minimapGui or not AR2_minimapGui.Parent then AR2_buildMinimap() end
    AR2_minimapGui.Enabled = true
    AR2_minimapImg.Size = UDim2.fromOffset(AR2_CFG.minimap.size, AR2_CFG.minimap.size)
    AR2_minimapImg.Position = UDim2.fromOffset(AR2_CFG.minimap.x, AR2_CFG.minimap.y)
    local root = AR2_LocalPlayer.Character and AR2_LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if root then
        local u, v = AR2_worldToMap(root.Position)
        AR2_minimapYouDot.Position = UDim2.fromScale(u, v)
        AR2_minimapYouDot.Visible = true
    else
        AR2_minimapYouDot.Visible = false
    end
    local i = 0
    for _, pl in ipairs(AR2_Players:GetPlayers()) do
        if pl == AR2_LocalPlayer then continue end
        local pRoot = pl.Character and pl.Character:FindFirstChild("HumanoidRootPart")
        if pRoot then
            i = i + 1
            local dot = AR2_minimapDots[i]
            if not dot then
                dot = Instance.new("Frame")
                dot.AnchorPoint = Vector2.new(0.5,0.5)
                dot.Size = UDim2.fromOffset(5,5)
                dot.BackgroundColor3 = Color3.fromRGB(255,90,90)
                dot.BorderSizePixel = 0
                dot.ZIndex = 4
                dot.Parent = AR2_minimapImg
                AR2_minimapDots[i] = dot
            end
            dot.Size = UDim2.fromOffset(5,5)
            dot.BackgroundColor3 = Color3.fromRGB(255,90,90)
            local u, v = AR2_worldToMap(pRoot.Position)
            dot.Position = UDim2.fromScale(u, v)
            dot.Visible = true
        end
    end
    if AR2_CFG.radar.vehicles.on then
        for _, vehicle in ipairs(AR2_api.vehicles()) do
            if vehicle.root then
                i = i + 1
                local dot = AR2_minimapDots[i]
                if not dot then
                    dot = Instance.new("Frame")
                    dot.AnchorPoint = Vector2.new(0.5,0.5)
                    dot.BorderSizePixel = 0
                    dot.ZIndex = 4
                    dot.Parent = AR2_minimapImg
                    AR2_minimapDots[i] = dot
                end
                dot.Size = UDim2.fromOffset(6,6)
                dot.BackgroundColor3 = Color3.fromRGB(255,190,55)
                local u, v = AR2_worldToMap(vehicle.root.Position)
                dot.Position = UDim2.fromScale(u, v)
                dot.Visible = true
            end
        end
    end
    for j = i+1, #AR2_minimapDots do AR2_minimapDots[j].Visible = false end
end

function AR2_minimapStart()
    if AR2_minimapConn then return end
    AR2_minimapConn = AR2_RunService.Heartbeat:Connect(function()
        if os.clock() - (AR2_minimapLastStep or 0) < 0.2 then return end
        AR2_minimapLastStep = os.clock()
        if not AR2_minimapEnabled then return end
        AR2_updateMinimap()
    end)
end

function AR2_minimapStop()
    if AR2_minimapConn then AR2_minimapConn:Disconnect() AR2_minimapConn = nil end
end

function AR2_minimapUpdate()
    if AR2_CFG.minimap.on and not AR2_minimapConn then AR2_minimapStart()
    elseif not AR2_CFG.minimap.on and AR2_minimapConn then AR2_minimapStop() end
end

-- =============================================

-- VISUALS (fullbright, fog, skybox, clouds, CC)
-- =============================================
AR2_visuals = { running = false, note = "off" }
AR2_FLAT_AMBIENT = Color3.fromRGB(150,150,150)

function AR2_atmosphere() return AR2_Lighting:FindFirstChildOfClass("Atmosphere") end

AR2_ORIG = {
    Brightness = AR2_Lighting.Brightness, Ambient = AR2_Lighting.Ambient,
    OutdoorAmbient = AR2_Lighting.OutdoorAmbient, GlobalShadows = AR2_Lighting.GlobalShadows,
    ExposureCompensation = AR2_Lighting.ExposureCompensation, FogEnd = AR2_Lighting.FogEnd,
    FogStart = AR2_Lighting.FogStart, ClockTime = AR2_Lighting.ClockTime,
    AtmosphereDensity = (AR2_atmosphere() and AR2_atmosphere().Density) or nil,
}

local AR2_origColorCorrection = nil
local AR2_addedColorCorrection = false
local AR2_origBloom = nil
local AR2_addedBloom = false

local function AR2_snapshotPostFX()
    local existingCC = AR2_Lighting:FindFirstChildOfClass("ColorCorrectionEffect")
    if existingCC then
        AR2_origColorCorrection = { inst = existingCC, Saturation = existingCC.Saturation, Contrast = existingCC.Contrast, Brightness = existingCC.Brightness, Enabled = existingCC.Enabled }
    end
    local existingBloom = AR2_Lighting:FindFirstChildOfClass("BloomEffect")
    if existingBloom then
        AR2_origBloom = { inst = existingBloom, Intensity = existingBloom.Intensity, Size = existingBloom.Size, Threshold = existingBloom.Threshold, Enabled = existingBloom.Enabled }
    end
end
AR2_snapshotPostFX()

function AR2_applyFullbright()
    AR2_Lighting.Brightness = AR2_CFG.visuals.brightness
    AR2_Lighting.Ambient = Color3.fromRGB(180, 180, 180)
    AR2_Lighting.OutdoorAmbient = Color3.fromRGB(200, 200, 200)
    AR2_Lighting.GlobalShadows = false
    AR2_Lighting.ExposureCompensation = 0.45
    local cc = AR2_origColorCorrection and AR2_origColorCorrection.inst or AR2_Lighting:FindFirstChildOfClass("ColorCorrectionEffect")
    if not cc or not cc.Parent then
        cc = Instance.new("ColorCorrectionEffect")
        cc.Name = "AR2_CC"
        cc.Parent = AR2_Lighting
        AR2_addedColorCorrection = true
    end
    cc.Saturation = 0.25 cc.Contrast = 0.10 cc.Brightness = 0.02 cc.Enabled = true
    local bloom = AR2_origBloom and AR2_origBloom.inst or AR2_Lighting:FindFirstChildOfClass("BloomEffect")
    if not bloom or not bloom.Parent then
        bloom = Instance.new("BloomEffect")
        bloom.Name = "AR2_Bloom"
        bloom.Parent = AR2_Lighting
        AR2_addedBloom = true
    end
    bloom.Intensity = 0.20 bloom.Size = 22 bloom.Threshold = 0.95 bloom.Enabled = true
end

function AR2_restoreFullbright()
    AR2_Lighting.Brightness          = AR2_ORIG.Brightness
    AR2_Lighting.Ambient             = AR2_ORIG.Ambient
    AR2_Lighting.OutdoorAmbient      = AR2_ORIG.OutdoorAmbient
    AR2_Lighting.GlobalShadows       = AR2_ORIG.GlobalShadows
    AR2_Lighting.ExposureCompensation = AR2_ORIG.ExposureCompensation
    if AR2_addedColorCorrection then
        local cc = AR2_Lighting:FindFirstChild("AR2_CC")
        if cc then cc:Destroy() end
        AR2_addedColorCorrection = false
    elseif AR2_origColorCorrection then
        local o = AR2_origColorCorrection
        o.inst.Saturation = o.Saturation
        o.inst.Contrast = o.Contrast
        o.inst.Brightness = o.Brightness
        o.inst.Enabled = o.Enabled
    end
    if AR2_addedBloom then
        local bloom = AR2_Lighting:FindFirstChild("AR2_Bloom")
        if bloom then bloom:Destroy() end
        AR2_addedBloom = false
    elseif AR2_origBloom then
        local o = AR2_origBloom
        o.inst.Intensity = o.Intensity
        o.inst.Size = o.Size
        o.inst.Threshold = o.Threshold
        o.inst.Enabled = o.Enabled
    end
end

function AR2_applyNoFog()
    AR2_Lighting.FogEnd = 1e6
    AR2_Lighting.FogStart = 0
    local air = AR2_atmosphere()
    if air then air.Density = 0.0001 end
end

function AR2_restoreFog()
    AR2_Lighting.FogEnd = AR2_ORIG.FogEnd
    AR2_Lighting.FogStart = AR2_ORIG.FogStart
    local air = AR2_atmosphere()
    if air and AR2_ORIG.AtmosphereDensity then air.Density = AR2_ORIG.AtmosphereDensity end
end

AR2_visualsConn = nil

function AR2_visualsStep()
    local c = AR2_CFG.visuals
    if c.fullbright then AR2_applyFullbright() end
    if c.nofog then AR2_applyNoFog() end
    if c.setTime then AR2_Lighting.ClockTime = c.time end
end

function AR2_visuals.apply()
    local c = AR2_CFG.visuals
    if not c.fullbright then AR2_restoreFullbright() end
    if not c.nofog then AR2_restoreFog() end
    if not c.setTime then AR2_Lighting.ClockTime = AR2_ORIG.ClockTime end
    if c.fullbright or c.nofog or c.setTime then
        if not AR2_visualsConn then
            AR2_visualsConn = AR2_RunService.RenderStepped:Connect(function()
                local ok, err = pcall(AR2_visualsStep)
                if not ok then AR2_visuals.note = "error: "..tostring(err) end
            end)
        end
        AR2_visuals.running = true
        local parts_ = {}
        if c.fullbright then parts_[#parts_+1] = "fullbright" end
        if c.nofog then parts_[#parts_+1] = "nofog" end
        if c.setTime then parts_[#parts_+1] = string.format("%dh", c.time) end
        AR2_visuals.note = table.concat(parts_, ", ")
    else
        if AR2_visualsConn then AR2_visualsConn:Disconnect() AR2_visualsConn = nil end
        AR2_visuals.running = false
        AR2_visuals.note = "off"
    end
end

function AR2_visuals.destroy()
    if AR2_visualsConn then AR2_visualsConn:Disconnect() AR2_visualsConn = nil end
    AR2_visuals.running = false
    AR2_restoreFullbright()
    AR2_restoreFog()
    AR2_Lighting.ClockTime = AR2_ORIG.ClockTime
    AR2_visuals.note = "off"
end

-- =============================================

-- FREEZE ZOMBIES
-- =============================================
AR2_freeze = { running = false, held = 0, near = 0, note = "off", lastUpdate = 0 }
AR2_freezeConn = nil
AR2_frozen = {}

function AR2_freezeAnchorParts(model, record)
    for _, descendant in ipairs(model:GetDescendants()) do
        if descendant:IsA("BasePart") then
            record.anchored[descendant] = descendant.Anchored
            descendant.Anchored = true
        end
    end
end

function AR2_freezeGrab(model, root)
    local record = { cf = root.CFrame, anchored = {} }
    if AR2_CFG.misc.freezeAnchor then pcall(AR2_freezeAnchorParts, model, record) end
    AR2_frozen[model] = record
    return record
end

function AR2_freezeUnanchor(record)
    for part, wasAnchored in pairs(record.anchored) do
        pcall(function() if part.Parent then part.Anchored = wasAnchored end end)
    end
    record.anchored = {}
end

function AR2_freezeRelease(model)
    local record = AR2_frozen[model]
    if not record then return end
    AR2_freezeUnanchor(record)
    AR2_frozen[model] = nil
end

function AR2_freezeReleaseAll()
    for model in pairs(AR2_frozen) do AR2_freezeRelease(model) end
end

function AR2_freezeStep()
    if not AR2_CFG.misc.freeze then
        if next(AR2_frozen) then AR2_freezeReleaseAll() end
        AR2_freeze.held, AR2_freeze.near, AR2_freeze.note = 0, 0, "off"
        return
    end
    local held, near = 0, 0
    local seen = {}
    for _, entry in ipairs(AR2_api.zombies()) do
        if AR2_CFG.misc.freezeAll or entry.distance <= AR2_CFG.misc.freezeRadius then
            near = near + 1
            local model, root = entry.model, entry.root
            if model.Parent and root.Parent then
                seen[model] = true
                local record = AR2_frozen[model] or AR2_freezeGrab(model, root)
                root.CFrame = record.cf
                root.AssemblyLinearVelocity = Vector3.zero
                held = held + 1
            end
        end
    end
    for model in pairs(AR2_frozen) do
        if not seen[model] then AR2_freezeRelease(model) end
    end
    AR2_freeze.held, AR2_freeze.near = held, near
    AR2_freeze.note = AR2_CFG.misc.freezeAll and "whole server" or (AR2_CFG.misc.freezeRadius .. " studs")
end

function AR2_freeze.start()
    if AR2_freezeConn then return end
    AR2_freeze.running = true
    AR2_freezeConn = AR2_RunService.Heartbeat:Connect(function()
        if os.clock() - (AR2_freeze.lastUpdate or 0) >= 0.1 then
            AR2_freeze.lastUpdate = os.clock()
            local ok, err = pcall(AR2_freezeStep)
            if not ok then AR2_freeze.note = "error: "..tostring(err) end
        end
    end)
end

function AR2_freeze.stop()
    AR2_freeze.running = false
    if AR2_freezeConn then AR2_freezeConn:Disconnect() AR2_freezeConn = nil end
    AR2_freezeReleaseAll()
    AR2_freeze.held, AR2_freeze.near, AR2_freeze.note = 0, 0, "off"
end

function AR2_freeze.destroy() AR2_freeze.stop() end

-- =============================================

-- VEHICLE HELPERS
-- =============================================
function AR2_simulateVehicleExit()
    local ok, VIM = pcall(game.GetService, game, "VirtualInputManager")
    if not ok or not VIM then return end
    pcall(function() VIM:SendKeyEvent(true,  Enum.KeyCode.Space, false, game) end)
    task.wait(0.05)
    pcall(function() VIM:SendKeyEvent(false, Enum.KeyCode.Space, false, game) end)
end

function AR2_ejectFromVehicle()
    local char = AR2_LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildWhichIsA("Humanoid")
    if not hum then return end
    if hum.Sit then
        AR2_simulateVehicleExit()
        task.wait(0.15)
    end
    if hum.Sit then
        hum.Sit = false
        pcall(function() hum:ChangeState(Enum.HumanoidStateType.GettingUp) end)
    end
    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("Weld") and (p.Name == "SeatWeld" or p.Name == "SeatWeld1") then
            p:Destroy()
        end
    end
end

function AR2_stopVehicleVelocity(model)
    if not model or not model.Parent then return end
    for _, p in ipairs(model:GetDescendants()) do
        if p:IsA("BasePart") then
            pcall(function()
                p.AssemblyLinearVelocity = Vector3.zero
                p.AssemblyAngularVelocity = Vector3.zero
            end)
        end
    end
end

function AR2_carHealth(model)
    if not model then return nil end
    local hp = model:GetAttribute("Health") or model:GetAttribute("health")
    if hp then return tonumber(hp) end
    for _, d in ipairs(model:GetDescendants()) do
        if d:IsA("ValueBase") and (d.Name == "Health" or d.Name == "health") then
            local h = tonumber(d.Value)
            if h then return h end
        end
    end
    return nil
end

-- =============================================

-- VEHICLE NOCLIP (anchor-based)
-- =============================================
AR2_carNoclipActive = false
AR2_carNoclipConn   = nil
AR2_carNoclipModel  = nil
AR2_carNoclipRoot   = nil
AR2_carNoclipParts  = nil
AR2_carNoclipOffsets = nil
AR2_carNoclipKeys   = {W=false,A=false,S=false,D=false,Space=false,LeftControl=false}

function AR2_carNoclipStart()
    if AR2_carNoclipConn then return true end
    local model = AR2_carPick()
    if not model then return false end
    local char = AR2_LocalPlayer.Character
    local hum  = char and char:FindFirstChildWhichIsA("Humanoid")
    if not hum or not hum.Sit then return false end

    local root = model.PrimaryPart or model:FindFirstChild("Base")
    if not root then
        for _, p in ipairs(model:GetDescendants()) do
            if p:IsA("BasePart") then root = p break end
        end
    end
    if not root then return false end

    local parts = {}
    for _, p in ipairs(model:GetDescendants()) do
        if p:IsA("BasePart") then parts[#parts + 1] = p end
    end
    if #parts == 0 then return false end

    local offsets = {}
    local savedAnchors = {}
    for _, p in ipairs(parts) do
        savedAnchors[p] = p.Anchored
        offsets[p] = root.CFrame:Inverse() * p.CFrame
        p.Anchored = true
        p.AssemblyLinearVelocity = Vector3.zero
        p.AssemblyAngularVelocity = Vector3.zero
    end

    AR2_carNoclipModel   = model
    AR2_carNoclipRoot    = root
    AR2_carNoclipParts   = parts
    AR2_carNoclipOffsets = offsets
    AR2_carNoclipSaved   = savedAnchors
    AR2_carNoclipActive  = true

    for k in pairs(AR2_carNoclipKeys) do AR2_carNoclipKeys[k] = false end

    AR2_carNoclipConn = AR2_RunService.Heartbeat:Connect(function(dt)
        local m = AR2_carNoclipModel
        local r = AR2_carNoclipRoot
        if not AR2_carNoclipActive or not m or not m.Parent or not r or not r.Parent then
            AR2_carNoclipSetEnabled(false)
            return
        end
        local c = AR2_LocalPlayer.Character
        local h = c and c:FindFirstChildWhichIsA("Humanoid")
        if not h or not h.Sit then
            AR2_carNoclipSetEnabled(false)
            return
        end
        local cam = workspace.CurrentCamera
        local move = Vector3.zero
        if AR2_carNoclipKeys.W then move += cam.CFrame.LookVector end
        if AR2_carNoclipKeys.S then move -= cam.CFrame.LookVector end
        if AR2_carNoclipKeys.D then move += cam.CFrame.RightVector end
        if AR2_carNoclipKeys.A then move -= cam.CFrame.RightVector end
        if AR2_carNoclipKeys.Space then move += Vector3.new(0,1,0) end
        if AR2_carNoclipKeys.LeftControl then move -= Vector3.new(0,1,0) end
        if move.Magnitude > 0 then
            local speed = AR2_CFG.car.noclipSpeed or 90
            local delta = move.Unit * speed * math.min(dt, 0.05)
            local newCF = r.CFrame + delta
            r.CFrame = newCF
            for part, offset in pairs(AR2_carNoclipOffsets) do
                if part and part.Parent then part.CFrame = newCF * offset end
            end
        end
    end)

    return true
end

AR2_carNoclipEjectGen = AR2_carNoclipEjectGen or 0

function AR2_carNoclipSetEnabled(on)
    if on then
        AR2_carNoclipEjectGen = AR2_carNoclipEjectGen + 1
        return AR2_carNoclipStart()
    else
        AR2_carNoclipActive = false
        if AR2_carNoclipConn then AR2_carNoclipConn:Disconnect() AR2_carNoclipConn = nil end

        if AR2_carNoclipParts and AR2_carNoclipSaved then
            for _, p in ipairs(AR2_carNoclipParts) do
                pcall(function()
                    if p and p.Parent then
                        p.Anchored = AR2_carNoclipSaved[p] or false
                        p.AssemblyLinearVelocity  = Vector3.zero
                        p.AssemblyAngularVelocity = Vector3.zero
                    end
                end)
            end
        end

        local model = AR2_carNoclipModel
        if not model and not AR2_carNoclipConn and not AR2_carNoclipParts then return true end
        AR2_carNoclipEjectGen = AR2_carNoclipEjectGen + 1
        local myGen = AR2_carNoclipEjectGen
        local delay = math.clamp(AR2_CFG.car.noclipEjectDelay or 0, 0, 5)

        task.delay(delay, function()
            if AR2_carNoclipEjectGen ~= myGen then return end
            if not AR2_LocalPlayer.Character then return end
            AR2_ejectFromVehicle()
            if model then AR2_stopVehicleVelocity(model) end
        end)

        AR2_carNoclipModel   = nil
        AR2_carNoclipRoot    = nil
        AR2_carNoclipParts   = nil
        AR2_carNoclipOffsets = nil
        AR2_carNoclipSaved   = nil
        for k in pairs(AR2_carNoclipKeys) do AR2_carNoclipKeys[k] = false end
        return true
    end
end

function AR2_carNoclipStop() AR2_carNoclipSetEnabled(false) end

AR2_carNoclipInputBegan = AR2_UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if not AR2_carNoclipActive then return end
    local k = input.KeyCode
    if k == Enum.KeyCode.W then AR2_carNoclipKeys.W = true
    elseif k == Enum.KeyCode.A then AR2_carNoclipKeys.A = true
    elseif k == Enum.KeyCode.S then AR2_carNoclipKeys.S = true
    elseif k == Enum.KeyCode.D then AR2_carNoclipKeys.D = true
    elseif k == Enum.KeyCode.Space then AR2_carNoclipKeys.Space = true
    elseif k == Enum.KeyCode.LeftControl then AR2_carNoclipKeys.LeftControl = true end
end)
AR2_carNoclipInputEnded = AR2_UserInputService.InputEnded:Connect(function(input, gpe)
    if gpe then return end
    local k = input.KeyCode
    if k == Enum.KeyCode.W then AR2_carNoclipKeys.W = false
    elseif k == Enum.KeyCode.A then AR2_carNoclipKeys.A = false
    elseif k == Enum.KeyCode.S then AR2_carNoclipKeys.S = false
    elseif k == Enum.KeyCode.D then AR2_carNoclipKeys.D = false
    elseif k == Enum.KeyCode.Space then AR2_carNoclipKeys.Space = false
    elseif k == Enum.KeyCode.LeftControl then AR2_carNoclipKeys.LeftControl = false end
end)

-- =============================================

-- CAR MODS
-- =============================================
AR2_carMods = { running = false, touched = 0, note = "off" }
AR2_touched = {}
AR2_carLoopGen = 0

function AR2_carConfig(model)
    local module = model:FindFirstChild("Config")
    if not (module and module:IsA("ModuleScript")) then return nil end
    local ok, tbl = pcall(require, module)
    return (ok and type(tbl) == "table") and tbl or nil
end

function AR2_forEachDamageMod(cfg, fn)
    if type(cfg.Health) ~= "table" then return end
    for _, group in pairs(cfg.Health) do
        if type(group) == "table" and type(group.DamageModifiers) == "table" then
            for key in pairs(group.DamageModifiers) do fn(group.DamageModifiers, key) end
        end
        if type(group) == "table" and not group.DamageModifiers then
            for _, sub in pairs(group) do
                if type(sub) == "table" and type(sub.DamageModifiers) == "table" then
                    for key in pairs(sub.DamageModifiers) do fn(sub.DamageModifiers, key) end
                end
            end
        end
    end
end

function AR2_snapshot(cfg)
    if AR2_touched[cfg] then return AR2_touched[cfg] end
    local saved = { torques = {}, grips = {}, dmg = {} }
    if type(cfg.Fuel) == "table" then saved.burnRate = cfg.Fuel.BurnRate end
    if type(cfg.Physics) == "table" then
        saved.driveSpeed = cfg.Physics.DriveSpeed
        saved.reverseSpeed = cfg.Physics.ReverseSpeed

        if type(cfg.Physics.Wheels) == "table" then
            for name, wheel in pairs(cfg.Physics.Wheels) do
                if type(wheel) == "table"
                   and type(wheel.Shock) == "table"
                   and wheel.Shock.DriveMotorTorque then
                    saved.torques[name] = wheel.Shock.DriveMotorTorque
                end
            end
        end

        if type(cfg.Physics.MaterialGrip) == "table" then
            for name, material in pairs(cfg.Physics.MaterialGrip) do
                if type(material) == "table" then
                    saved.grips[name] = {
                        Speed    = material.Speed,
                        Friction = material.Friction,
                    }
                end
            end
        end
    end
    if type(cfg.ExitDamage) == "table" then saved.exitMax = cfg.ExitDamage.MaxSpeed end
    AR2_forEachDamageMod(cfg, function(t, k) saved.dmg[#saved.dmg+1] = { t = t, k = k, v = t[k] } end)
    AR2_touched[cfg] = saved
    return saved
end

function AR2_applyTo(cfg, model)
    local c = AR2_CFG.car
    local saved = AR2_snapshot(cfg)

    if c.boost and type(cfg.Physics) == "table" then
        cfg.Physics.DriveSpeed   = c.speed
        cfg.Physics.ReverseSpeed = math.floor(c.speed * 0.4)

        if type(cfg.Physics.Wheels) == "table" then
            for name, wheel in pairs(cfg.Physics.Wheels) do
                if type(wheel) == "table"
                   and type(wheel.Shock) == "table"
                   and saved.torques[name] then
                    wheel.Shock.DriveMotorTorque = saved.torques[name] * c.torque
                end
            end
        end

        if type(cfg.ExitDamage) == "table" then
            cfg.ExitDamage.MaxSpeed = 99999
        end
    end

    if c.maxTraction and type(cfg.Physics) == "table"
       and type(cfg.Physics.MaterialGrip) == "table" then
        for _, mat in pairs(cfg.Physics.MaterialGrip) do
            if type(mat) == "table" then
                if mat.Speed    ~= nil then mat.Speed    = 1 end
                if mat.Friction ~= nil then mat.Friction = 1 end
            end
        end
    end

    if c.fuel and type(cfg.Fuel) == "table" then
        cfg.Fuel.BurnRate        = 0
        cfg.Fuel.ConsumptionRate = 0
    end

    if c.god and type(cfg.Health) == "table" then
        local function zeroDmg(t)
            if type(t) ~= "table" then return end
            if type(t.DamageModifiers) == "table" then
                for k in pairs(t.DamageModifiers) do
                    t.DamageModifiers[k] = 0
                end
            else
                for _, v in pairs(t) do zeroDmg(v) end
            end
        end
        zeroDmg(cfg.Health)
    end
end

function AR2_restoreOne(cfg)
    local saved = AR2_touched[cfg]
    if not saved then return end
    if type(cfg.Fuel) == "table" and saved.burnRate ~= nil then cfg.Fuel.BurnRate = saved.burnRate end
    if type(cfg.Physics) == "table" then
        if saved.driveSpeed ~= nil then cfg.Physics.DriveSpeed = saved.driveSpeed end
        if saved.reverseSpeed ~= nil then cfg.Physics.ReverseSpeed = saved.reverseSpeed end

        if type(cfg.Physics.Wheels) == "table" then
            for name, wheel in pairs(cfg.Physics.Wheels) do
                if type(wheel) == "table"
                   and type(wheel.Shock) == "table"
                   and saved.torques[name] then
                    wheel.Shock.DriveMotorTorque = saved.torques[name]
                end
            end
        end

        if type(cfg.Physics.MaterialGrip) == "table" then
            for name, material in pairs(cfg.Physics.MaterialGrip) do
                if type(material) == "table" and saved.grips[name] then
                    if saved.grips[name].Speed    ~= nil then material.Speed    = saved.grips[name].Speed    end
                    if saved.grips[name].Friction ~= nil then material.Friction = saved.grips[name].Friction end
                end
            end
        end
    end
    if type(cfg.ExitDamage) == "table" and saved.exitMax ~= nil then cfg.ExitDamage.MaxSpeed = saved.exitMax end
    for _, entry in ipairs(saved.dmg) do entry.t[entry.k] = entry.v end
    AR2_touched[cfg] = nil
end

function AR2_restoreAll()
    for cfg in pairs(AR2_touched) do AR2_restoreOne(cfg) end
    AR2_carMods.touched = 0
end

function AR2_occupiedCar()
    local char = AR2_LocalPlayer.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local vehicles = AR2_Workspace:FindFirstChild("Vehicles")
    if not vehicles then return nil end

    for _, model in ipairs(vehicles:GetChildren()) do
        if model:IsA("Model") then
            for _, part in ipairs(model:GetDescendants()) do
                if part:IsA("BasePart") then
                    for _, weld in ipairs(part:GetChildren()) do
                        if (weld:IsA("Weld") or weld:IsA("WeldConstraint"))
                        and (weld.Part0 == hrp or weld.Part1 == hrp) then
                            return model
                        end
                    end
                end
            end
        end
    end

    local best, bestDist = nil, 12
    for _, model in ipairs(vehicles:GetChildren()) do
        if model:IsA("Model") then
            local base = AR2_carBase(model)
            if base then
                local d = (base.Position - hrp.Position).Magnitude
                if d < bestDist then best = model bestDist = d end
            end
        end
    end
    return best
end

function AR2_sweep()
    local vehicles = AR2_Workspace:FindFirstChild("Vehicles")
    if not vehicles then AR2_carMods.note = "no Vehicles folder" return end
    local count = 0
    if AR2_CFG.car.allCars then
        for _, model in ipairs(vehicles:GetChildren()) do
            if model:IsA("Model") then
                local cfg = AR2_carConfig(model)
                if cfg then AR2_applyTo(cfg, model) count = count + 1 end
            end
        end
    else
        local model = AR2_occupiedCar()
        local cfg = model and AR2_carConfig(model)
        if cfg then AR2_applyTo(cfg, model) count = count + 1 end
    end
    AR2_carMods.touched = count
    local parts_ = {}
    if AR2_CFG.car.fuel then parts_[#parts_+1] = "fuel" end
    if AR2_CFG.car.boost then parts_[#parts_+1] = "boost" end
    if AR2_CFG.car.god then parts_[#parts_+1] = "god" end
    if AR2_CFG.car.maxTraction then parts_[#parts_+1] = "traction" end
    AR2_carMods.note = string.format("%s  --  %d car%s tuned%s", table.concat(parts_, ", "), count, count == 1 and "" or "s", AR2_CFG.car.allCars and "  (all)" or "  (yours)")
end

function AR2_carMods.apply()
    local wanted = AR2_CFG.car.fuel or AR2_CFG.car.boost or AR2_CFG.car.god or AR2_CFG.car.maxTraction
    AR2_restoreAll()
    AR2_carLoopGen = AR2_carLoopGen + 1
    if not wanted then
        AR2_carMods.running = false
        AR2_carMods.note = "off"
        return
    end
    AR2_carMods.running = true
    pcall(AR2_sweep)
    local mine = AR2_carLoopGen
    task.spawn(function()
        while mine == AR2_carLoopGen and AR2_carMods.running do
            task.wait(1)
            if mine ~= AR2_carLoopGen then break end
            pcall(AR2_sweep)
        end
    end)
end

function AR2_carMods.destroy()
    AR2_carLoopGen = AR2_carLoopGen + 1
    AR2_carMods.running = false
    AR2_restoreAll()
    AR2_carMods.note = "off"
end

-- =============================================
-- VEHICLE EXTRA MODS
-- =============================================
function AR2_setBoatMode(enabled)
    AR2_CFG.car.boatMode = enabled
    local waterFolder = AR2_Workspace:FindFirstChild("Map")
        and AR2_Workspace.Map:FindFirstChild("Water")
        or  AR2_Workspace:FindFirstChild("Water")
    if not waterFolder then return end
    for _, part in ipairs(waterFolder:GetDescendants()) do
        if part:IsA("BasePart") or part:IsA("MeshPart") then
            if enabled then
                if part:HasTag("Swim Surface") then
                    part:RemoveTag("Swim Surface")
                    part:AddTag("Boat Surface")
                end
            else
                if part:HasTag("Boat Surface") then
                    part:RemoveTag("Boat Surface")
                    part:AddTag("Swim Surface")
                end
            end
        end
    end
end

AR2_dragSaved   = {}
AR2_dragVehicle = nil

function AR2_setRemoveDrag(enabled)
    AR2_CFG.car.removeDrag = enabled
    local model = AR2_carPick()
    if not model then return end
    local cfg = AR2_carConfig(model)
    if not cfg then return end

    if enabled then
        AR2_dragSaved   = {}
        AR2_dragVehicle = model
        if type(cfg.Physics) == "table" then
            if type(cfg.Physics.MaterialGrip) == "table" then
                for matName, mat in pairs(cfg.Physics.MaterialGrip) do
                    if type(mat) == "table" then
                        if mat.Speed ~= nil then
                            AR2_dragSaved["gs_"..matName] = mat.Speed
                            mat.Speed = 1
                        end
                        if mat.Friction ~= nil then
                            AR2_dragSaved["gf_"..matName] = mat.Friction
                            mat.Friction = 1
                        end
                    end
                end
            end
            if type(cfg.Physics.Wheels) == "table" then
                for wname, wheel in pairs(cfg.Physics.Wheels) do
                    if type(wheel) == "table" then
                        if wheel.Elasticity ~= nil then
                            AR2_dragSaved["we_"..tostring(wname)] = wheel.Elasticity
                            wheel.Elasticity = 0
                        end
                        if wheel.Friction ~= nil then
                            AR2_dragSaved["wf_"..tostring(wname)] = wheel.Friction
                            wheel.Friction = 1
                        end
                    end
                end
            end
        end
    else
        if AR2_dragVehicle then
            local cfgOld = AR2_carConfig(AR2_dragVehicle)
            if cfgOld and cfgOld.Physics then
                if type(cfgOld.Physics.MaterialGrip) == "table" then
                    for matName, mat in pairs(cfgOld.Physics.MaterialGrip) do
                        if type(mat) == "table" then
                            if AR2_dragSaved["gs_"..matName] then mat.Speed    = AR2_dragSaved["gs_"..matName] end
                            if AR2_dragSaved["gf_"..matName] then mat.Friction = AR2_dragSaved["gf_"..matName] end
                        end
                    end
                end
                if type(cfgOld.Physics.Wheels) == "table" then
                    for wname, wheel in pairs(cfgOld.Physics.Wheels) do
                        if type(wheel) == "table" then
                            local we = AR2_dragSaved["we_"..tostring(wname)]
                            local wf = AR2_dragSaved["wf_"..tostring(wname)]
                            if we then wheel.Elasticity = we end
                            if wf then wheel.Friction   = wf end
                        end
                    end
                end
            end
        end
        AR2_dragSaved, AR2_dragVehicle = {}, nil
    end
end

AR2_steerSaved   = {}
AR2_steerApplied = false
AR2_steerConn    = nil

function AR2_setFullSteer(enabled)
    AR2_CFG.car.fullSteer = enabled
    if enabled then
        if AR2_steerConn then return end
        AR2_steerConn = AR2_RunService.Heartbeat:Connect(function()
            if not AR2_CFG.car.fullSteer then return end
            local model = AR2_carPick()
            if not model then return end
            local cfg = AR2_carConfig(model)
            if not cfg or not cfg.Physics then return end

            if not AR2_steerApplied then
                AR2_steerApplied = true
                for _, k in ipairs({"FullSteeringUntil","NoSteeringAfter","SteerResponce","TurnSpeed"}) do
                    if cfg.Physics[k] ~= nil then AR2_steerSaved[k] = cfg.Physics[k] end
                end
                if type(cfg.Physics.Wheels) == "table" then
                    for wname, wheel in pairs(cfg.Physics.Wheels) do
                        if type(wheel) == "table" and wheel.SteerAngle ~= nil then
                            AR2_steerSaved["sa_"..tostring(wname)] = wheel.SteerAngle
                        end
                    end
                end
            end

            if cfg.Physics.FullSteeringUntil ~= nil then cfg.Physics.FullSteeringUntil = 9999 end
            if cfg.Physics.NoSteeringAfter   ~= nil then cfg.Physics.NoSteeringAfter   = 99999 end
            if cfg.Physics.SteerResponce     ~= nil then cfg.Physics.SteerResponce     = math.max(8, cfg.Physics.SteerResponce) end
            if type(cfg.Physics.Wheels) == "table" then
                for wname, wheel in pairs(cfg.Physics.Wheels) do
                    if type(wheel) == "table" and wheel.SteerAngle ~= nil then
                        local orig = AR2_steerSaved["sa_"..tostring(wname)] or 0
                        if orig > 0 then wheel.SteerAngle = math.max(orig, 45)
                        elseif orig < 0 then wheel.SteerAngle = math.min(orig, -45) end
                    end
                end
            end
        end)
    else
        if AR2_steerConn then AR2_steerConn:Disconnect() AR2_steerConn = nil end
        if AR2_steerApplied then
            local model = AR2_carPick()
            local cfg = model and AR2_carConfig(model)
            if cfg and cfg.Physics then
                for k, v in pairs(AR2_steerSaved) do
                    if type(k) == "string" and k:sub(1,3) ~= "sa_" then
                        cfg.Physics[k] = v
                    end
                end
                if type(cfg.Physics.Wheels) == "table" then
                    for wname, wheel in pairs(cfg.Physics.Wheels) do
                        if type(wheel) == "table" then
                            local saved = AR2_steerSaved["sa_"..tostring(wname)]
                            if saved then wheel.SteerAngle = saved end
                        end
                    end
                end
            end
            AR2_steerSaved, AR2_steerApplied = {}, false
        end
    end
end

-- =============================================

local AR2_skyboxCache = {}
function AR2_applySkybox(skyboxName)
    AR2_CFG.visuals.skybox = skyboxName
    if not AR2_skyboxCache.original then
        AR2_skyboxCache.original = {
            Ambient = AR2_Lighting.Ambient, OutdoorAmbient = AR2_Lighting.OutdoorAmbient,
            FogColor = AR2_Lighting.FogColor, FogStart = AR2_Lighting.FogStart,
            FogEnd = AR2_Lighting.FogEnd, ClockTime = AR2_Lighting.ClockTime,
        }
    end
    -- Only ever remove OUR OWN sky. Destroying the game's weather skies (like
    -- "Overcast 2") locks their Parent at nil, and the game's Lighting stepper then
    -- errors EVERY FRAME trying to restore them -- that flood also stalls the other
    -- steppers in the same loop, which is what breaks reload after a respawn. Never
    -- destroy a sky we didn't create.
    if AR2_customSky and AR2_customSky.Parent then
        pcall(function() AR2_customSky:Destroy() end)
    end
    for _, child in ipairs(AR2_Lighting:GetChildren()) do
        if child:IsA("Sky") and child:GetAttribute("ar2_sky") then
            pcall(function() child:Destroy() end)
        end
    end
    AR2_customSky = nil
    if skyboxName == "Default" then
        AR2_Lighting.Ambient = AR2_skyboxCache.original.Ambient
        AR2_Lighting.OutdoorAmbient = AR2_skyboxCache.original.OutdoorAmbient
        AR2_Lighting.FogColor = AR2_skyboxCache.original.FogColor
        AR2_Lighting.FogStart = AR2_skyboxCache.original.FogStart
        AR2_Lighting.FogEnd = AR2_skyboxCache.original.FogEnd
        AR2_Lighting.ClockTime = AR2_skyboxCache.original.ClockTime
    else
        local skyboxes = {
            ["Space"] = { Bk = "rbxassetid://159454299", Dn = "rbxassetid://159454299", Ft = "rbxassetid://159454299", Lf = "rbxassetid://159454299", Rt = "rbxassetid://159454299", Up = "rbxassetid://159454299" },
            ["Galaxy"] = { Bk = "http://www.roblox.com/asset/?id=149397692", Dn = "http://www.roblox.com/asset/?id=149397686", Ft = "http://www.roblox.com/asset/?id=149397697", Lf = "http://www.roblox.com/asset/?id=149397684", Rt = "http://www.roblox.com/asset/?id=149397688", Up = "http://www.roblox.com/asset/?id=149397702" },
            ["Galaxy 2"] = { Bk = "http://www.roblox.com/asset/?id=155441936", Dn = "http://www.roblox.com/asset/?id=155441802", Ft = "http://www.roblox.com/asset/?id=155441818", Lf = "http://www.roblox.com/asset/?id=155441777", Rt = "http://www.roblox.com/asset/?id=155441874", Up = "http://www.roblox.com/asset/?id=155441905" },
            ["Galaxy 3"] = { Bk = "rbxassetid://135908594667929", Dn = "rbxassetid://139584143501514", Ft = "rbxassetid://92947876187368", Lf = "rbxassetid://72493016739936", Rt = "rbxassetid://81731245279712", Up = "rbxassetid://88174897344210" },
            ["Saturne"] = { Bk = "rbxassetid://1898724755", Dn = "rbxassetid://1898727189", Ft = "rbxassetid://1898722814", Lf = "rbxassetid://1898729298", Rt = "rbxassetid://1898741025", Up = "rbxassetid://1898736761" },
            ["Neptune"] = { Bk = "rbxassetid://218955819", Dn = "rbxassetid://218953419", Ft = "rbxassetid://218954524", Lf = "rbxassetid://218958493", Rt = "rbxassetid://218957134", Up = "rbxassetid://218950090" },
            ["Redshift"] = { Bk = "rbxassetid://401664839", Dn = "rbxassetid://401664862", Ft = "rbxassetid://401664960", Lf = "rbxassetid://401664881", Rt = "rbxassetid://401664901", Up = "rbxassetid://401664936" },
            ["Pink Daylights"] = { Bk = "rbxassetid://11555017034", Dn = "rbxassetid://11555013415", Ft = "rbxassetid://11555010145", Lf = "rbxassetid://11555006545", Rt = "rbxassetid://11555000712", Up = "rbxassetid://11554996247" },
            ["Purple Night"] = { Bk = "rbxassetid://17279854976", Dn = "rbxassetid://17279856318", Ft = "rbxassetid://17279858447", Lf = "rbxassetid://17279860360", Rt = "rbxassetid://17279862234", Up = "rbxassetid://17279864507" },
            ["Gray Night"] = { Bk = "rbxassetid://1618912481", Dn = "rbxassetid://1618913943", Ft = "rbxassetid://1618913244", Lf = "rbxassetid://1618912849", Rt = "rbxassetid://1618911568", Up = "rbxassetid://1618913654" },
            ["Anime Sky"] = { Bk = "rbxassetid://18351376859", Dn = "rbxassetid://18351374919", Ft = "rbxassetid://18351376800", Lf = "rbxassetid://18351376469", Rt = "rbxassetid://18351376457", Up = "rbxassetid://18351377189" }
        }
        local data = skyboxes[skyboxName]
        if data then
            AR2_Lighting.Ambient = Color3.new(0.5, 0.5, 0.5)
            AR2_Lighting.OutdoorAmbient = Color3.new(0.8, 0.8, 0.8)
            AR2_Lighting.FogColor = Color3.new(0.5, 0.5, 0.5)
            AR2_Lighting.FogStart = 0
            AR2_Lighting.FogEnd = 1000
            AR2_Lighting.ClockTime = 0
            local sky = Instance.new("Sky")
            sky.Name = skyboxName
            sky:SetAttribute("ar2_sky", true)   -- mark ours so we only ever destroy our own
            sky.SkyboxBk = data.Bk
            sky.SkyboxDn = data.Dn
            sky.SkyboxFt = data.Ft
            sky.SkyboxLf = data.Lf
            sky.SkyboxRt = data.Rt
            sky.SkyboxUp = data.Up
            sky.Parent = AR2_Lighting
            AR2_customSky = sky
        end
    end
end


function AR2_setRemoveShadows(enabled)
    AR2_CFG.misc.removeShadows = enabled
    AR2_Lighting.GlobalShadows = (enabled or AR2_CFG.visuals.fullbright) and false or AR2_ORIG.GlobalShadows
end


-- CAR FLY  (speed capped at 200 no matter what)
-- =============================================
AR2_CFG.car.fly      = AR2_CFG.car.fly or false
AR2_CFG.car.flySpeed = AR2_CFG.car.flySpeed or 100

AR2_carFlyActive        = false
AR2_carFlyConn          = nil
AR2_carFlyVel           = Vector3.zero
AR2_carFlyModel         = nil
AR2_carFlyRoot          = nil
AR2_carFlySavedParts    = nil
AR2_carFlyInitialHealth = nil
AR2_carFlyHealthWatch   = 0

local AR2_CAR_FLY_MIN_SPEED = 10
local AR2_CAR_FLY_MAX_SPEED = 200

local function AR2_carFlyGetModel()
    local char = AR2_LocalPlayer.Character
    local hum  = char and char:FindFirstChildWhichIsA("Humanoid")
    if hum and hum.SeatPart then
        local node = hum.SeatPart
        while node and node.Parent do
            if node.Parent == Workspace:FindFirstChild("Vehicles") then return node end
            node = node.Parent
        end
    end
    if AR2_carPick then
        local ok, m = pcall(AR2_carPick)
        if ok then return m end
    end
    return nil
end

function AR2_carFlyStop()
    AR2_carFlyActive        = false
    AR2_CFG.car.fly         = false
    AR2_carFlyInitialHealth = nil
    if AR2_carFlyConn then AR2_carFlyConn:Disconnect() AR2_carFlyConn = nil end
    AR2_carFlyVel = Vector3.zero

    if AR2_carFlySavedParts then
        for part, wasCollide in pairs(AR2_carFlySavedParts) do
            pcall(function()
                if part and part.Parent then
                    part.CanCollide = wasCollide
                    part.AssemblyLinearVelocity  = Vector3.zero
                    part.AssemblyAngularVelocity = Vector3.zero
                end
            end)
        end
    end
    AR2_carFlyModel      = nil
    AR2_carFlyRoot       = nil
    AR2_carFlySavedParts = nil
end

local function AR2_carFlyDamageEject()
    local model = AR2_carFlyModel
    AR2_carFlyStop()
    AR2_ejectFromVehicle()
    AR2_stopVehicleVelocity(model)
    pcall(function()
        local NL = getgenv and getgenv().OriginHUB_NL
        if NL then
            local Notif = NL:CreateNotification()
            Notif.new({Title="Origin HUB",Content="Car took damage — auto-ejected",Duration=3})
        end
    end)
end

function AR2_carFlyStart()
    if AR2_carFlyActive then return true end
    local model = AR2_carFlyGetModel()
    if not model then return false end
    local char = AR2_LocalPlayer.Character
    local hum  = char and char:FindFirstChildWhichIsA("Humanoid")
    if not hum or not hum.Sit then return false end

    local root = model.PrimaryPart or model:FindFirstChild("Base")
    if not root then
        for _, p in ipairs(model:GetDescendants()) do
            if p:IsA("BasePart") then root = p break end
        end
    end
    if not root then return false end

    AR2_carFlyInitialHealth = AR2_carHealth(model)
    AR2_carFlyHealthWatch   = 0

    local savedParts = {}
    for _, p in ipairs(model:GetDescendants()) do
        if p:IsA("BasePart") then
            savedParts[p] = p.CanCollide
            p.CanCollide  = false
        end
    end

    AR2_carFlyModel      = model
    AR2_carFlyRoot       = root
    AR2_carFlySavedParts = savedParts
    AR2_carFlyVel        = Vector3.zero
    AR2_carFlyActive     = true
    AR2_CFG.car.fly      = true

    AR2_carFlyConn = AR2_RunService.Heartbeat:Connect(function(dt)
        if not AR2_CFG.car.fly then AR2_carFlyStop() return end
        local m = AR2_carFlyModel
        if not m or not m.Parent then AR2_carFlyStop() return end
        local r = AR2_carFlyRoot
        if not r or not r.Parent then AR2_carFlyStop() return end

        local c = AR2_LocalPlayer.Character
        local h = c and c:FindFirstChildWhichIsA("Humanoid")
        if not h or not h.Sit then AR2_carFlyStop() return end

        AR2_carFlyHealthWatch = AR2_carFlyHealthWatch + dt
        if AR2_carFlyHealthWatch >= 0.1 then
            AR2_carFlyHealthWatch = 0
            local hp = AR2_carHealth(m)
            if hp then
                if not AR2_carFlyInitialHealth then
                    AR2_carFlyInitialHealth = hp
                elseif hp < AR2_carFlyInitialHealth then
                    AR2_carFlyDamageEject()
                    return
                end
            end
        end

        local cam    = workspace.CurrentCamera
        local target = Vector3.zero
        if AR2_UserInputService:IsKeyDown(Enum.KeyCode.W) then target = target + cam.CFrame.LookVector end
        if AR2_UserInputService:IsKeyDown(Enum.KeyCode.S) then target = target - cam.CFrame.LookVector end
        if AR2_UserInputService:IsKeyDown(Enum.KeyCode.D) then target = target + cam.CFrame.RightVector end
        if AR2_UserInputService:IsKeyDown(Enum.KeyCode.A) then target = target - cam.CFrame.RightVector end
        if AR2_UserInputService:IsKeyDown(Enum.KeyCode.Space) then target = target + Vector3.new(0, 1, 0) end
        local descend = AR2_UserInputService:IsKeyDown(Enum.KeyCode.LeftControl)
            or AR2_UserInputService:IsKeyDown(Enum.KeyCode.Q)
            or AR2_UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)
            or AR2_UserInputService:IsKeyDown(Enum.KeyCode.RightShift)
        if descend then target = target - Vector3.new(0, 1, 0) end

        -- Hard cap here regardless of what the config or slider hands us.
        AR2_CFG.car.flySpeed = math.clamp(AR2_CFG.car.flySpeed or 100, AR2_CAR_FLY_MIN_SPEED, AR2_CAR_FLY_MAX_SPEED)
        local speed = AR2_CFG.car.flySpeed
        local targetVel = target.Magnitude > 0.01 and target.Unit * speed or Vector3.zero

        AR2_carFlyVel = AR2_carFlyVel:Lerp(targetVel, math.min(1, dt * 6))

        local flatFwd
        if target.Magnitude > 0.01 then
            flatFwd = Vector3.new(targetVel.X, 0, targetVel.Z)
        else
            flatFwd = Vector3.new(cam.CFrame.LookVector.X, 0, cam.CFrame.LookVector.Z)
        end
        if flatFwd.Magnitude > 0.01 then
            local yawCF = CFrame.lookAt(Vector3.zero, flatFwd.Unit)
            pcall(function()
                r.CFrame = CFrame.new(r.Position) * (yawCF - yawCF.Position)
            end)
        end

        local gravComp = Vector3.new(0, AR2_Workspace.Gravity * dt, 0)
        r.AssemblyLinearVelocity  = AR2_carFlyVel + gravComp
        r.AssemblyAngularVelocity = Vector3.zero
    end)

    return true
end

function AR2_carFlySetEnabled(on)
    if on then
        local ok = AR2_carFlyStart()
        if not ok then AR2_CFG.car.fly = false end
        return ok
    else
        AR2_carFlyStop()
        return true
    end
end

-- =============================================

-- Release imported feature state when the original menu is replaced.
AR2_stopImportedFeatures = function()
    AR2_CFG.misc.freeze = false
    AR2_freeze.destroy()
    AR2_setPlayerJesus(false)
    AR2_CFG.radar.on = false
    AR2_radar.destroy()
    AR2_CFG.minimap.on = false
    AR2_minimapEnabled = false
    AR2_minimapStop()
    if AR2_minimapGui then AR2_minimapGui:Destroy() end
    AR2_carFlyStop()
    AR2_carNoclipStop()
    if AR2_carNoclipInputBegan then AR2_carNoclipInputBegan:Disconnect() end
    if AR2_carNoclipInputEnded then AR2_carNoclipInputEnded:Disconnect() end
    AR2_carMods.destroy()
    AR2_setRemoveDrag(false)
    AR2_setFullSteer(false)
    AR2_CFG.visuals.fullbright = false
    AR2_CFG.visuals.nofog = false
    AR2_CFG.visuals.setTime = false
    AR2_visuals.destroy()
    if AR2_CFG.visuals.skybox ~= "Default" then AR2_applySkybox("Default") end
    AR2_setRemoveShadows(false)
end
end -- imported backend scope

--==================================================
-- MAIN GUI
--==================================================

local screenGui = Instance.new("ScreenGui")

screenGui.Name = "MegaAdminMenu"
screenGui.Destroying:Connect(function()
    local ok, err = pcall(AR2_stopImportedFeatures)
    if not ok then warn("[AR2 merged] cleanup: " .. tostring(err)) end
end)
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.DisplayOrder = 900
screenGui.Parent = playerGui

-- One small credit, shown only while the main panel is closed.
local creatorCredit = Instance.new("TextLabel")
creatorCredit.Name = "CreatorCredit"
creatorCredit.Parent = screenGui
creatorCredit.AnchorPoint = Vector2.new(1, 0)
creatorCredit.Size = UDim2.fromOffset(178, 22)
creatorCredit.Position = UDim2.new(1, -14, 0, 12)
creatorCredit.BackgroundTransparency = 1
creatorCredit.BorderSizePixel = 0
creatorCredit.Text = "Created by: KAPI_2255"
creatorCredit.TextColor3 = Color3.fromRGB(175, 185, 208)
creatorCredit.Font = Enum.Font.Gotham
creatorCredit.TextSize = 10
creatorCredit.TextXAlignment = Enum.TextXAlignment.Right
creatorCredit.ZIndex = 100

local blur = Instance.new("BlurEffect")

blur.Name = "AdminMenuBlur"
blur.Size = 0
blur.Parent = Lighting

--==================================================
-- COMPACT TABBED UI
--==================================================
local uiColors = {
    surface=Color3.fromRGB(28,13,7),card=Color3.fromRGB(45,24,12),edge=Color3.fromRGB(122,68,29),
    muted=Color3.fromRGB(207,179,151),text=Color3.fromRGB(255,247,236),accent=Color3.fromRGB(255,119,0),
    selected=Color3.fromRGB(127,57,9),active=Color3.fromRGB(91,45,14),
    badge=Color3.fromRGB(65,32,13),track=Color3.fromRGB(85,45,19),
}
local uiGlass = {
    frame=0.42, shadow=0.94, section=0.52,
    card=0.24, selected=0.24,
}
local function widget(class,properties,parent)
    local obj=Instance.new(class)
    for k,v in pairs(properties) do obj[k]=v end
    obj.Parent=parent
    return obj
end
local function uiText(parent,text,x,y,w,h,size,color,font)
    return widget("TextLabel",{Text=text,Position=UDim2.fromOffset(x,y),Size=UDim2.fromOffset(w,h),BackgroundTransparency=1,TextColor3=color or uiColors.text,Font=font or Enum.Font.Gotham,TextSize=size,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=6},parent)
end
local centerRingEnabled = false
local centerRing = widget("Frame",{
    Name="CenterAimRing", Size=UDim2.fromOffset(12,12),
    AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),
    BackgroundTransparency=1,BorderSizePixel=0,Visible=false,ZIndex=101,
},screenGui)
addCorner(centerRing,6)
addStroke(centerRing,Color3.fromRGB(255,198,92),2,0)
local shadow=widget("Frame",{Size=UDim2.fromOffset(696,526),AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),BackgroundColor3=Color3.new(0,0,0),BackgroundTransparency=uiGlass.shadow,BorderSizePixel=0,Visible=false,ZIndex=2},screenGui)
addCorner(shadow,3)
local shadowScale=widget("UIScale",{Scale=1},shadow)
local frame=widget("Frame",{Name="ControlPanel",Size=UDim2.fromOffset(680,510),AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),BackgroundColor3=uiColors.surface,BackgroundTransparency=uiGlass.frame,BorderSizePixel=0,ClipsDescendants=true,Visible=false,ZIndex=3},screenGui)
addCorner(frame,7)
local frameStroke=addStroke(frame,uiColors.accent,2,0.05)
addGradient(frame,Color3.fromRGB(48,22,8),uiColors.surface,Color3.fromRGB(20,9,5),90)
local frameScale=widget("UIScale",{Scale=1},frame)
local panelFitScale=1
local uiScaleMultiplier=1
local function updatePanelFit()
    local camera=workspace.CurrentCamera
    if camera then panelFitScale=math.min(1.05,camera.ViewportSize.X/725,camera.ViewportSize.Y/610)*uiScaleMultiplier end
end
updatePanelFit()
frameScale.Scale=panelFitScale
shadowScale.Scale=panelFitScale
-- A full-width masthead and a separate sidebar follow the selected 01 concept.
local topBar=widget("Frame",{Name="Masthead",Position=UDim2.fromOffset(0,0),Size=UDim2.new(1,0,0,68),BackgroundColor3=Color3.fromRGB(48,22,8),BackgroundTransparency=0.34,BorderSizePixel=0,ZIndex=4},frame)
uiText(topBar,"AR2",24,13,67,42,31,uiColors.accent,Enum.Font.GothamBlack)
uiText(topBar,"SCRIPTS",103,17,200,36,26,uiColors.text,Enum.Font.GothamBlack)
uiText(topBar,"ORANGE UI V2",390,25,125,20,10,uiColors.accent,Enum.Font.GothamBold)
widget("Frame",{Position=UDim2.fromOffset(294,37),Size=UDim2.fromOffset(72,2),BackgroundColor3=uiColors.edge,BorderSizePixel=0,ZIndex=5},topBar)
widget("Frame",{Position=UDim2.fromOffset(500,0),Size=UDim2.fromOffset(56,3),BackgroundColor3=uiColors.accent,BorderSizePixel=0,ZIndex=5},topBar)
widget("Frame",{Position=UDim2.fromOffset(12,67),Size=UDim2.new(1,-24,0,1),BackgroundColor3=uiColors.edge,BorderSizePixel=0,ZIndex=5},topBar)
local closeButton=widget("TextButton",{Position=UDim2.new(1,-48,0,17),Size=UDim2.fromOffset(30,30),BackgroundColor3=uiColors.card,BackgroundTransparency=uiGlass.card,BorderSizePixel=0,Text="×",TextColor3=uiColors.text,Font=Enum.Font.GothamBold,TextSize=19,AutoButtonColor=false,ZIndex=6},topBar)
addCorner(closeButton,3)
addStroke(closeButton,uiColors.edge,1,0.1)
local side=widget("Frame",{Name="Sidebar",Position=UDim2.fromOffset(0,69),Size=UDim2.new(0,174,1,-70),BackgroundColor3=Color3.fromRGB(37,17,8),BackgroundTransparency=0.42,BorderSizePixel=0,ZIndex=4},frame)
widget("Frame",{Position=UDim2.new(1,-1,0,0),Size=UDim2.new(0,1,1,0),BackgroundColor3=uiColors.edge,BackgroundTransparency=0.25,BorderSizePixel=0,ZIndex=5},side)
local sidebarMenuHint=uiText(side,"menu   Open / close",16,353,151,15,10,uiColors.muted)
local sidebarTeleportHint=uiText(side,"MMB   Teleport",16,375,151,15,10,uiColors.muted)
sidebarMenuHint.Visible=false
sidebarTeleportHint.Visible=false
local title=uiText(frame,"ESP",195,80,270,32,25,uiColors.text,Enum.Font.GothamBold)
local subtitle=uiText(frame,"Player names & distance",196,111,270,17,10,uiColors.muted)
widget("Frame",{Position=UDim2.fromOffset(540,119),Size=UDim2.fromOffset(58,2),BackgroundColor3=uiColors.accent,BorderSizePixel=0,ZIndex=5},frame)
local statusPill=widget("TextLabel",{Position=UDim2.new(1,-110,0,84),Size=UDim2.fromOffset(88,23),BackgroundColor3=uiColors.badge,BackgroundTransparency=uiGlass.card,BorderSizePixel=0,Text="0 ACTIVE",TextColor3=uiColors.accent,Font=Enum.Font.GothamBold,TextSize=9,ZIndex=5},frame)
addCorner(statusPill,3)
local statusStroke=addStroke(statusPill,uiColors.accent,1,0.5)
local buttonHolder=widget("ScrollingFrame",{Name="Tabs",Position=UDim2.fromOffset(13,15),Size=UDim2.new(0,146,1,-25),BackgroundTransparency=1,BorderSizePixel=0,CanvasSize=UDim2.fromOffset(0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollingDirection=Enum.ScrollingDirection.Y,ScrollBarThickness=0,ZIndex=5},side)
buttonHolder.Visible=true
widget("UIListLayout",{Padding=UDim.new(0,5),SortOrder=Enum.SortOrder.LayoutOrder},buttonHolder)
local buttonData={}
local selectedButton=nil
local function makeTabIcon(button,kind)
    local holder=widget("Frame",{Name="TabIcon",Position=UDim2.fromOffset(12,10),
        Size=UDim2.fromOffset(22,22),BackgroundTransparency=1,ZIndex=7},button)
    widget("UIScale",{Scale=1.16},holder)
    local fills,strokes={},{}
    local function line(x,y,w,h,angle)
        local part=widget("Frame",{Position=UDim2.fromOffset(x,y),Size=UDim2.fromOffset(w,h),
            Rotation=angle or 0,BackgroundColor3=uiColors.muted,BorderSizePixel=0,ZIndex=8},holder)
        table.insert(fills,part)
        return part
    end
    local function outline(x,y,w,h,radius)
        local part=widget("Frame",{Position=UDim2.fromOffset(x,y),Size=UDim2.fromOffset(w,h),
            BackgroundTransparency=1,BorderSizePixel=0,ZIndex=8},holder)
        if radius then addCorner(part,radius) end
        table.insert(strokes,addStroke(part,uiColors.muted,2,0))
        return part
    end
    if kind=="home" then
        line(3,6,11,2,-40);line(9,6,11,2,40)
        outline(5,10,13,10,2);line(10,14,3,6)
    elseif kind=="eye" then
        outline(2,5,19,12,8);outline(9,8,6,6,6)
    elseif kind=="target" then
        outline(4,4,15,15,15);line(11,0,2,7);line(11,17,2,5)
        line(0,11,7,2);line(17,11,5,2)
    elseif kind=="jump" then
        line(10,5,3,16);line(5,6,9,2,-42);line(10,6,9,2,42)
        line(3,20,17,2)
    elseif kind=="teleport" then
        outline(4,1,15,15,15);line(10,6,4,4)
        line(8,16,8,2,-45);line(12,16,8,2,45)
    elseif kind=="flag" then
        line(4,1,2,21);outline(7,3,13,9,2);line(4,20,12,2)
    elseif kind=="car" then
        outline(2,9,19,10,3);line(5,5,13,2);line(3,8,3,3,-35)
        line(18,8,3,3,35);outline(5,17,4,4,4);outline(15,17,4,4,4)
    elseif kind=="map" then
        line(2,4,2,16);line(3,3,6,2,-20);line(9,4,6,2,20)
        line(15,3,6,2,-20);line(9,5,2,16);line(15,5,2,16)
        line(3,19,6,2,-20);line(9,18,6,2,20);line(15,19,6,2,-20)
    elseif kind=="snow" then
        line(10,2,2,20);line(2,10,20,2);line(4,4,16,2,45);line(4,18,16,2,-45)
    elseif kind=="sun" then
        outline(8,8,7,7,7);line(11,0,2,5);line(11,19,2,5)
        line(0,11,5,2);line(19,11,5,2)
    elseif kind=="settings" then
        line(2,5,19,2);line(2,11,19,2);line(2,17,19,2)
        outline(7,2,6,6,6);outline(15,8,6,6,6);outline(5,14,6,6,6)
    end
    return function(color)
        for _,part in ipairs(fills) do part.BackgroundColor3=color end
        for _,stroke in ipairs(strokes) do stroke.Color=color end
    end
end
local function makeButton(text,icon,description,actionText)
    local button=widget("TextButton",{Name=text.."Tab",Size=UDim2.new(1,0,0,42),BackgroundColor3=uiColors.card,BackgroundTransparency=1,BorderSizePixel=0,Text="",AutoButtonColor=false,ZIndex=6},buttonHolder)
    button:SetAttribute("Enabled",false)
    addCorner(button,6)
    local tabStroke=addStroke(button,uiColors.edge,1,0.3)
    local selectedMark=widget("Frame",{Position=UDim2.fromOffset(0,4),Size=UDim2.fromOffset(4,34),BackgroundColor3=uiColors.accent,BorderSizePixel=0,Visible=false,ZIndex=7},button)
    local paintIcon=makeTabIcon(button,icon)
    local nameLabel=uiText(button,text,48,10,94,24,14,uiColors.muted,Enum.Font.GothamBold)
    local dot=widget("Frame",{Position=UDim2.new(1,-10,0.5,-2),Size=UDim2.fromOffset(4,4),BackgroundColor3=uiColors.accent,BorderSizePixel=0,Visible=false,ZIndex=7},button)
    addCorner(dot,9)
    local function refresh(hover)
        local selected=selectedButton==button
        button.BackgroundTransparency=selected and uiGlass.selected or hover and uiGlass.card or 1
        button.BackgroundColor3=selected and uiColors.selected or uiColors.card
        nameLabel.TextColor3=selected and uiColors.text or uiColors.muted
        paintIcon(selected and uiColors.accent or uiColors.muted)
        dot.Visible=button:GetAttribute("Enabled")==true and not actionText
        selectedMark.Visible=selected
        tabStroke.Color=selected and uiColors.accent or uiColors.edge
        tabStroke.Transparency=selected and 0.1 or 0.35
    end
    button.MouseEnter:Connect(function() refresh(true) end)
    button.MouseLeave:Connect(function() refresh(false) end)
    buttonData[button]={refresh=refresh,title=text,description=description}
    refresh(false)
    return button
end
local espButton=makeButton("ESP","eye","Player names & distance")
local aimbotButton=makeButton("Aimbot","target","Targeting & distance")
local movementButton=makeButton("Air Jump","jump","Extra jumps in the air")
local teleportButton=makeButton("Teleport","teleport","Mouse wheel & player teleport")
local checkpointsButton=makeButton("Checkpoints","flag","DEAD markers at enemy death locations")
local importedUI={}
importedUI.freezeButton=makeButton("Other","snow","Freeze zombies and walk on water")
importedUI.carsButton=makeButton("Cars","car","Vehicle noclip and speed")
importedUI.mapButton=makeButton("Map","map","Radar and minimap")
importedUI.lightingButton=makeButton("Lighting","sun","Light, fog and sky")
importedUI.settingsButton=makeButton("Settings","settings","Config and menu appearance")
local function setButton(button,enabled)
    button:SetAttribute("Enabled",enabled)
    if buttonData[button] then buttonData[button].refresh(false) end
end

local teleportAccess = { Unlocked = false, ShowPlayers = false }
local teleportEnabled = false
local checkpointsEnabled = false
local menuOpen = false
local refreshEspFeature
local menuAnimating = false
local menuTransition = 0
local function resizeMenu(expanded, animate)
    local height=expanded and (AR2_CFG.ui.compact and 510 or 560) or 510
    local panelSize=UDim2.fromOffset(680,height)
    local shadowSize=UDim2.fromOffset(696,height+16)
    sidebarMenuHint.Visible=expanded
    sidebarTeleportHint.Visible=expanded
    if animate and menuOpen and frame.Visible then
        tween(frame,0.28,{Size=panelSize})
        tween(shadow,0.28,{Size=shadowSize})
    else
        frame.Size=panelSize
        shadow.Size=shadowSize
    end
end

-- Keep the cursor free while the menu is open, including in first person.
-- Run after camera updates so they cannot immediately lock it again.
local setMenuCursor
do
    local savedMouseState = nil
    local cursorBinding = "MegaAdminMenu_FreeCursor"
    local guiDestroyed = false

    local function freeMenuCursor()
        -- The game's ADS camera may lock the cursor on RMB. Repeatedly
        -- overriding it in the same render frame can force a costly tug of
        -- war with that camera. Restore the free cursor after RMB is released.
        if type(UserInputService.IsMouseButtonPressed) == "function"
            and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            return
        end
        if UserInputService.MouseBehavior ~= Enum.MouseBehavior.Default then
            UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        end
        if not UserInputService.MouseIconEnabled then
            UserInputService.MouseIconEnabled = true
        end
        if mouse.Icon ~= "" then mouse.Icon = "" end
    end

    setMenuCursor = function(enabled)
        if enabled then
            if guiDestroyed or savedMouseState then return end
            savedMouseState = {
                behavior = UserInputService.MouseBehavior,
                iconEnabled = UserInputService.MouseIconEnabled,
                icon = mouse.Icon,
                modal = closeButton.Modal,
            }
            closeButton.Modal = true
            freeMenuCursor()
            RunService:BindToRenderStep(
                cursorBinding,
                Enum.RenderPriority.Last.Value + 1,
                freeMenuCursor
            )
        elseif savedMouseState then
            RunService:UnbindFromRenderStep(cursorBinding)
            closeButton.Modal = savedMouseState.modal
            UserInputService.MouseBehavior = savedMouseState.behavior
            UserInputService.MouseIconEnabled = savedMouseState.iconEnabled
            mouse.Icon = savedMouseState.icon
            savedMouseState = nil
        end
    end

    screenGui.Destroying:Connect(function()
        setMenuCursor(false)
        guiDestroyed = true
    end)
end

local function openMenu()

        if menuOpen then
                return
        end

        menuTransition = menuTransition + 1
        local transition = menuTransition
        menuAnimating = true
        menuOpen = true
        creatorCredit.Visible = false
        centerRing.Visible = false

        frame.Visible = true
        shadow.Visible = true
        setMenuCursor(true)
    if selectedButton == espButton and refreshEspFeature then
        refreshEspFeature(false)
    end

        updatePanelFit()
        frameScale.Scale = 0.84 * panelFitScale
        shadowScale.Scale = 0.84 * panelFitScale

        frame.BackgroundTransparency = 0.56
        shadow.BackgroundTransparency = 0.98

        tween(blur, 0.25, {
                Size = 2
        })

        tween(frameScale, 0.28, {
                Scale = panelFitScale
        })

        tween(shadowScale, 0.28, {
                Scale = panelFitScale
        })

        tween(frame, 0.22, {
                BackgroundTransparency = uiGlass.frame
        })

        local finalTween = tween(
                shadow,
                0.28,
                {
                        BackgroundTransparency = uiGlass.shadow
                }
        )

        finalTween.Completed:Connect(function()
                if transition == menuTransition then menuAnimating = false end
        end)
end

local function closeMenu()

        if not menuOpen then
                return
        end

        menuTransition = menuTransition + 1
        local transition = menuTransition
        menuAnimating = true
        menuOpen = false
        setMenuCursor(false)

        tween(blur, 0.18, {
                Size = 0
        })

        tween(frameScale, 0.20, {
                Scale = 0.84 * panelFitScale
        })

        tween(shadowScale, 0.20, {
                Scale = 0.84 * panelFitScale
        })

        tween(frame, 0.18, {
                BackgroundTransparency = 0.56
        })

        local finalTween = tween(
                shadow,
                0.20,
                {
                        BackgroundTransparency = 0.98
                }
        )

        finalTween.Completed:Connect(function()
                if transition ~= menuTransition then return end

                frame.Visible = false
                creatorCredit.Visible = true
                shadow.Visible = false
                centerRing.Visible = centerRingEnabled
                menuAnimating = false

        end)
end

--==================================================
-- MENU TOGGLE / CLOSE BUTTON
--==================================================

local function toggleMenu()

        if menuOpen then
                closeMenu()
        else
                openMenu()
        end
end

closeButton.MouseEnter:Connect(function()

        tweenFast(closeButton, {
                BackgroundColor3 = uiColors.selected
        })

end)

closeButton.MouseLeave:Connect(function()

        tweenFast(closeButton, {
                BackgroundColor3 = uiColors.card
        })

end)

closeButton.MouseButton1Click:Connect(closeMenu)


-- Always available, even if a later game feature cannot initialize.
local floatingMenuButton = widget("TextButton", {
    Name="FloatingMenuButton", AnchorPoint=Vector2.new(0,0),
    Position=UDim2.fromOffset(12,320), Size=UDim2.fromOffset(76,34),
    BackgroundColor3=uiColors.selected, BackgroundTransparency=uiGlass.selected, BorderSizePixel=0,
    Text="menu", TextColor3=uiColors.text, Font=Enum.Font.GothamBold,
    TextSize=14, AutoButtonColor=true, ZIndex=100,
}, screenGui)
addCorner(floatingMenuButton,6)
addStroke(floatingMenuButton,uiColors.accent,1,0.12)
floatingMenuButton.Activated:Connect(toggleMenu)

local function makeSettingsPanel(
        name,
        titleText,
        yPos
)

        local panel = Instance.new("Frame")

        panel.Name = name
        panel.Parent = frame
        panel.Size = UDim2.new(1, -208, 0, 126)
        panel.Position = UDim2.new(0, 190, 0, 139)
        panel.BackgroundColor3 = uiColors.surface
        panel.BackgroundTransparency = uiGlass.section
        panel.BorderSizePixel = 0
        panel.Visible = false
        panel.ZIndex = 60

        addCorner(panel, 3)

        addStroke(
                panel,
                uiColors.edge,
                1,
                0.15
        )

        addGradient(
                panel,
                Color3.fromRGB(46, 23, 10),
                Color3.fromRGB(28, 13, 7),
                Color3.fromRGB(37, 18, 8),
                0
        )

        local panelTitle = Instance.new("TextLabel")

        panelTitle.Parent = panel
        panelTitle.Size = UDim2.new(1, -48, 0, 24)
        panelTitle.Position = UDim2.new(0, 16, 0, 10)
        panelTitle.BackgroundTransparency = 1
        panelTitle.Text = titleText
        panelTitle.TextColor3 = uiColors.text
        panelTitle.Font = Enum.Font.GothamBlack
        panelTitle.TextSize = 12
        panelTitle.TextXAlignment = Enum.TextXAlignment.Left
        panelTitle.ZIndex = 61

        local list = Instance.new("ScrollingFrame")

        list.Parent = panel
        list.Size = UDim2.new(1, -24, 1, -132)
        list.Position = UDim2.new(0, 12, 0, 120)
        list.BackgroundTransparency = 1
        list.BorderSizePixel = 0
        list.ScrollBarThickness = 4
        list.ScrollBarImageColor3 = uiColors.accent
        list.CanvasSize = UDim2.new(0, 0, 0, 0)
        list.AutomaticCanvasSize = Enum.AutomaticSize.Y
        list.ZIndex = 61

        local layout = Instance.new("UIListLayout")

        layout.Parent = list
        layout.Padding = UDim.new(0, 8)
        layout.SortOrder = Enum.SortOrder.LayoutOrder

        return panel, list
end

-- Open after the key check. ESP becomes the initial tab below, as soon as its
-- panel exists; the floating menu button can always reopen this window.
openMenu()


--==================================================
-- DRAG
--==================================================

local dragging = false
local dragStart = nil
local startPos = nil
local shadowStartPos = nil

topBar.InputBegan:Connect(function(input)

        if input.UserInputType == Enum.UserInputType.MouseButton1 then

                dragging = true
                dragStart = input.Position
                startPos = frame.Position
                shadowStartPos = shadow.Position

        end
end)

topBar.InputEnded:Connect(function(input)

        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
        end

end)

UserInputService.InputChanged:Connect(function(input)

        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then

                local delta = input.Position - dragStart

                frame.Position = UDim2.new(
                        startPos.X.Scale,
                        startPos.X.Offset + delta.X,
                        startPos.Y.Scale,
                        startPos.Y.Offset + delta.Y
                )

                shadow.Position = UDim2.new(
                        shadowStartPos.X.Scale,
                        shadowStartPos.X.Offset + delta.X,
                        shadowStartPos.Y.Scale,
                        shadowStartPos.Y.Offset + delta.Y
                )

        end
end)

--==================================================
-- ESP / AIMBOT VARIABLES
--==================================================

local getTeamColor

local espEnabled = false
local headshotControls = nil

local airJumpEnabled = false
local MAX_AIR_JUMPS = 10
local airJumpCount = 0
local airJumpCharacter = nil

-- Forward declarations: the teleport UI is created before the
-- actual teleport function bodies later in the script.
local teleportToPlayer
local resetLastTeleport

-- Position saved immediately before the last player teleport.
local lastTeleportPivot = nil

local espObjects = {}

--==================================================
-- ESP
--==================================================

local ESP_HOVER_COLOR = Color3.fromRGB(255, 255, 255)
local hoveredEspPlayer = nil

local ESP_TEAM_CHECK = true
local ESP_USE_TEAM_COLOR = false

local ESP_COLOR = Color3.fromRGB(255, 255, 255)

local ESP_DISTANCE_SCALE = 1
local ESP_SHOW_HP = false
local ESP_SHOW_WEAPON = false

local ESP_MAX_DISTANCE = 10000
local DEAD_MARKER_DISTANCE = 500

local ESP_TEXT_SIZE = 13
local ESP_NICK_SCALE = 1
local ESP_OUTLINE_BRIGHTNESS = 70 -- 0 hides the outline, 100 is fully visible.

--==================================================
-- DEFAULT SETTINGS
--==================================================

local DEFAULT_SETTINGS = {

        EspColor = {255, 255, 255},
        EspHoverColor = {255, 255, 255},

        EspDistanceScale = 1,
        EspNickScale = 1,
        EspShowHp = false,
        EspShowWeapon = false,
        EspOutlineBrightness = 70,
        EspMaxDistance = 10000,
        DeadMarkerDistance = 500,

        AirJumpEnabled = false,
        MaxAirJumps = 10,

}

--==================================================
-- ESP FONTS
--==================================================

local espFonts = {

        {
                Name = "GothamBold",
                Font = Enum.Font.GothamBold
        },

        {
                Name = "GothamBlack",
                Font = Enum.Font.GothamBlack
        },

        {
                Name = "Arcade",
                Font = Enum.Font.Arcade
        },

        {
                Name = "SourceSansBold",
                Font = Enum.Font.SourceSansBold
        },

        {
                Name = "RobotoMono",
                Font = Enum.Font.RobotoMono
        },
}

local espFontIndex = 1

local function getEspBaseColor(plr)
        return Color3.fromRGB(255, 255, 255)
end

local function getEspFont()

        local data = espFonts[
                math.clamp(
                        math.floor(espFontIndex + 0.5),
                        1,
                        #espFonts
                )
        ] or espFonts[1]

        return data.Font
end

local function getEspFontName()

        local data = espFonts[
                math.clamp(
                        math.floor(espFontIndex + 0.5),
                        1,
                        #espFonts
                )
        ] or espFonts[1]

        return data.Name
end

--==================================================
-- SETTINGS HELPERS
--==================================================

local function colorToTable(color)

        return {
                math.floor(color.R * 255 + 0.5),
                math.floor(color.G * 255 + 0.5),
                math.floor(color.B * 255 + 0.5),
        }
end

local function tableToColor(value, fallback)

        if typeof(value) ~= "table" then
                return fallback
        end

        return Color3.fromRGB(

                math.clamp(
                        tonumber(value[1])
                                or math.floor(fallback.R * 255 + 0.5),
                        0,
                        255
                ),

                math.clamp(
                        tonumber(value[2])
                                or math.floor(fallback.G * 255 + 0.5),
                        0,
                        255
                ),

                math.clamp(
                        tonumber(value[3])
                                or math.floor(fallback.B * 255 + 0.5),
                        0,
                        255
                )
        )
end

local function copyDefaultSettings()

        local copy = {}

        for key, value in pairs(DEFAULT_SETTINGS) do

                if typeof(value) == "table" then
                        copy[key] = table.clone(value)
                else
                        copy[key] = value
                end

        end

        return copy
end

local function applySettings(settings)

        settings =
                typeof(settings) == "table"
                and settings
                or copyDefaultSettings()

        ESP_COLOR = Color3.fromRGB(255, 255, 255)

        ESP_HOVER_COLOR = Color3.fromRGB(255, 255, 255)

        ESP_DISTANCE_SCALE = math.clamp(
                tonumber(settings.EspDistanceScale)
                        or DEFAULT_SETTINGS.EspDistanceScale,
                0,
                2.5
        )

    ESP_NICK_SCALE = math.clamp(
        tonumber(settings.EspNickScale) or DEFAULT_SETTINGS.EspNickScale,
        0,
        2.5
    )

        ESP_SHOW_HP = settings.EspShowHp == true
        ESP_SHOW_WEAPON = settings.EspShowWeapon == true
        ESP_OUTLINE_BRIGHTNESS = math.clamp(
                tonumber(settings.EspOutlineBrightness) or DEFAULT_SETTINGS.EspOutlineBrightness,
                0, 100
        )

        ESP_MAX_DISTANCE = math.clamp(
                math.floor(
                        tonumber(settings.EspMaxDistance)
                                or DEFAULT_SETTINGS.EspMaxDistance
                ),
                25,
                10000
        )
        DEAD_MARKER_DISTANCE = math.clamp(
                math.floor(tonumber(settings.DeadMarkerDistance)
                        or DEFAULT_SETTINGS.DeadMarkerDistance), 25, 10000
        )

        airJumpEnabled = settings.AirJumpEnabled == true

        MAX_AIR_JUMPS = math.clamp(
                math.floor(
                        tonumber(settings.MaxAirJumps)
                                or DEFAULT_SETTINGS.MaxAirJumps
                        + 0.5
                ),
                1,
                20
        )

end

local function exportSettings()

        return {

                EspColor = {255, 255, 255},
                EspHoverColor = {255, 255, 255},

                EspDistanceScale = ESP_DISTANCE_SCALE,
                EspNickScale = ESP_NICK_SCALE,
                EspShowHp = ESP_SHOW_HP,
                EspShowWeapon = ESP_SHOW_WEAPON,
                EspOutlineBrightness = ESP_OUTLINE_BRIGHTNESS,
                EspMaxDistance = ESP_MAX_DISTANCE,
                DeadMarkerDistance = DEAD_MARKER_DISTANCE,

                AirJumpEnabled = airJumpEnabled,
                MaxAirJumps = MAX_AIR_JUMPS,
        }
end

--==================================================
-- SESSION SAVE
--==================================================

local sessionSavedSettings = nil

local function loadSavedSettings()

        if typeof(sessionSavedSettings) == "table" then

                applySettings(sessionSavedSettings)

                return true
        end

        applySettings(copyDefaultSettings())

        return true
end

local function saveCurrentSettings()

        sessionSavedSettings = exportSettings()

        return true, "Saved for this session."
end

loadSavedSettings()

--==================================================
-- TEAM
--==================================================

function getTeamColor(plr)

        if plr.TeamColor then
                return plr.TeamColor.Color
        end

        return Color3.fromRGB(255, 255, 255)
end

local function isSameTeam(plr)

        return player.Team ~= nil
                and plr.Team ~= nil
                and player.Team == plr.Team
end

--==================================================
-- ESP
--==================================================

local function destroyESP(plr)

        local data = espObjects[plr]

        if not data then
                return
        end

        for _, obj in pairs(data) do

                if typeof(obj) == "Instance" and obj.Parent then
                        obj:Destroy()
                end

        end

        espObjects[plr] = nil
end

local function escapeEspText(value)
    local text = tostring(value)
    text = text:gsub("&", "&amp;")
    text = text:gsub("<", "&lt;")
    text = text:gsub(">", "&gt;")
    return text
end

local function updateEspOutline(data, character)
    if ESP_OUTLINE_BRIGHTNESS <= 0 then
        if data.Outline then data.Outline:Destroy(); data.Outline = nil end
        return
    end

    local outline = data.Outline
    if not outline or not outline.Parent then
        outline = Instance.new("Highlight")
        outline.Name = "AR2_PlayerOutline"
        outline.FillTransparency = 1
        outline.OutlineColor = Color3.new(1, 1, 1)
        outline.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        outline.Adornee = character
        outline.Parent = character
        data.Outline = outline
    end
    outline.OutlineTransparency = 1 - ESP_OUTLINE_BRIGHTNESS / 100
end

local function createESP(plr)

        if plr == player or espObjects[plr] then
                return
        end

        if ESP_TEAM_CHECK and isSameTeam(plr) then
                return
        end

        local character = plr.Character

        if not character then
                return
        end

        local humanoid = character:FindFirstChildOfClass("Humanoid")
        local head = character:FindFirstChild("Head")

        if not humanoid or not head then
                return
        end

        local baseColor = getEspBaseColor(plr)

        local billboard = Instance.new("BillboardGui")

        billboard.Name = "AdminESP_Billboard"
        billboard.Adornee = head
        billboard.Size = UDim2.new(0, 230, 0, 60)
        billboard.StudsOffset = Vector3.new(0, 2.8, 0)
        billboard.AlwaysOnTop = true
        billboard.MaxDistance = ESP_MAX_DISTANCE
        billboard.Parent = screenGui

        local label = Instance.new("TextLabel")

        label.Parent = billboard
        label.Size = UDim2.new(1, 0, 0, 38)
        label.BackgroundTransparency = 1
        label.TextColor3 = baseColor
        label.Font = getEspFont()
        label.TextSize = ESP_TEXT_SIZE

        label.TextTransparency = 0
        label.TextStrokeTransparency = 0

        label.TextWrapped = true
        label.RichText = true
        label.Text = escapeEspText(plr.Name)

        local hpBack = Instance.new("Frame")

        hpBack.Parent = billboard
        hpBack.Size = UDim2.new(0, 150, 0, 6)
        hpBack.Position = UDim2.new(0.5, -75, 0, 42)
        hpBack.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        hpBack.BorderSizePixel = 0
        hpBack.Visible = false

        addCorner(hpBack, 999)

        local hpFill = Instance.new("Frame")

        hpFill.Parent = hpBack
        hpFill.Size = UDim2.new(1, 0, 1, 0)
        hpFill.BackgroundColor3 = Color3.fromRGB(0, 255, 90)
        hpFill.BorderSizePixel = 0

        addCorner(hpFill, 999)

        espObjects[plr] = {
                Billboard = billboard,
                Label = label,
                HpBack = hpBack,
                HpFill = hpFill,
        }
        updateEspOutline(espObjects[plr], character)
end

screenGui.Destroying:Connect(function()
    local markedPlayers = {}
    for plr in pairs(espObjects) do table.insert(markedPlayers, plr) end
    for _, plr in ipairs(markedPlayers) do destroyESP(plr) end
end)

local function updateHoveredEspPlayer()

        hoveredEspPlayer = nil

        local target = mouse.Target

        if not target then
                return
        end

        local model = target:FindFirstAncestorOfClass("Model")

        local targetPlayer =
                model
                and Players:GetPlayerFromCharacter(model)

        if targetPlayer and targetPlayer ~= player then
                hoveredEspPlayer = targetPlayer
        end
end

local function getEspDistance(head)
        local camera = workspace.CurrentCamera
        if not camera or not head or not head:IsA("BasePart") then return nil end
        return (head.Position - camera.CFrame.Position).Magnitude
end

local espLastPlayerError = -math.huge
local function updateESP()

        if not workspace.CurrentCamera then
                return
        end

        local currentPlayers = Players:GetPlayers()
        local nearestPlayer, nearestDistance = nil, math.huge
        for _, candidate in ipairs(currentPlayers) do
                if candidate ~= player and not (ESP_TEAM_CHECK and isSameTeam(candidate)) then
                        local character = candidate.Character
                        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
                        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
                        local head = character and character:FindFirstChild("Head")
                        if humanoid and rootPart and head and humanoid.Health > 0 then
                                local distance = getEspDistance(head)
                                if distance and distance <= ESP_MAX_DISTANCE and distance < nearestDistance then
                                        nearestPlayer, nearestDistance = candidate, distance
                                end
                        end
                end
        end

        for _, plr in ipairs(currentPlayers) do
        local ok, err = pcall(function()

                if plr ~= player then

                        if ESP_TEAM_CHECK and isSameTeam(plr) then

                                destroyESP(plr)
                                return
                        end

                        local character = plr.Character

                        local humanoid =
                                character
                                and character:FindFirstChildOfClass("Humanoid")

                        local rootPart =
                                character
                                and character:FindFirstChild("HumanoidRootPart")

                        local head =
                                character
                                and character:FindFirstChild("Head")

                        if character
                                and humanoid
                                and rootPart
                                and head
                                and humanoid.Health > 0 then

                                local distance = getEspDistance(head)

                                if not distance or distance > ESP_MAX_DISTANCE then
                                        destroyESP(plr)
                                        return
                                end

                                if not espObjects[plr] then
                                        createESP(plr)
                                end

                                local data = espObjects[plr]

                                if data then
                                        updateEspOutline(data, character)

                                        local health = math.floor(humanoid.Health)
                                        local maxHealth = math.floor(humanoid.MaxHealth)

                                        local hpPercent =
                                                maxHealth > 0
                                                and math.clamp(
                                                        health / maxHealth,
                                                        0,
                                                        1
                                                )
                                                or 0

                                        local displayColor =
                                                Color3.fromRGB(255, 255, 255)

                                        data.Billboard.Adornee = head
                                        data.Billboard.MaxDistance =
                                                ESP_MAX_DISTANCE

                                        data.Label.TextColor3 =
                                                displayColor

                                        data.Label.Font =
                                                getEspFont()

                                        data.Label.TextTransparency = 0
                                        data.Label.TextStrokeTransparency = 0

                    local nicknameSize = ESP_NICK_SCALE > 0
                        and math.max(1, math.floor(ESP_TEXT_SIZE * ESP_NICK_SCALE + 0.5)) or 0
                    local distanceSize = ESP_DISTANCE_SCALE > 0
                        and math.max(1, math.floor(ESP_TEXT_SIZE * ESP_DISTANCE_SCALE + 0.5)) or 0
                    local lines = {}
                    local contentHeight = 0
                    if nicknameSize > 0 then
                        if plr == nearestPlayer then
                            table.insert(lines, string.format(
                                '<font color="#FF4545" size="%d">%s</font>',
                                nicknameSize, escapeEspText(plr.Name)))
                        else
                            table.insert(lines, string.format('<font size="%d">%s</font>',
                                nicknameSize, escapeEspText(plr.Name)))
                        end
                        contentHeight = contentHeight + nicknameSize + 4
                    end
                    if distanceSize > 0 then
                        table.insert(lines, string.format('<font size="%d">%.1fm</font>',
                            distanceSize, distance))
                        contentHeight = contentHeight + distanceSize + 4
                    end
                    if ESP_SHOW_WEAPON then
                        local weaponOk, equipped = pcall(AR2_weaponName, character)
                        if weaponOk and type(equipped) == "string" and equipped ~= "" then
                            table.insert(lines, '<font size="' .. tostring(ESP_TEXT_SIZE) .. '">['
                                .. escapeEspText(equipped) .. ']</font>')
                            contentHeight = contentHeight + ESP_TEXT_SIZE + 4
                        end
                    end
                    if ESP_SHOW_HP then
                        table.insert(lines, string.format('%d/%d HP', health, maxHealth))
                        contentHeight = contentHeight + ESP_TEXT_SIZE + 4
                    end
                    local labelHeight = math.max(24, contentHeight)
                    local labelWidth = math.floor(230 * math.max(1, ESP_NICK_SCALE, ESP_DISTANCE_SCALE))
                    data.Billboard.Enabled = #lines > 0
                    data.Billboard.Size = UDim2.new(0, labelWidth, 0,
                        labelHeight + (ESP_SHOW_HP and 14 or 0))
                    data.Label.Size = UDim2.new(1, 0, 0, labelHeight)
                    data.Label.TextSize = ESP_TEXT_SIZE
                    data.Label.Text = table.concat(lines, "\n")
                    data.HpBack.Position = UDim2.new(0.5, -75, 0, labelHeight + 4)
                    data.HpBack.Visible = ESP_SHOW_HP

                                        data.HpFill.Size =
                                                UDim2.new(
                                                        hpPercent,
                                                        0,
                                                        1,
                                                        0
                                                )

                                        if hpPercent > 0.5 then

                                                data.HpFill.BackgroundColor3 =
                                                        Color3.fromRGB(
                                                                0,
                                                                255,
                                                                90
                                                        )

                                        elseif hpPercent > 0.25 then

                                                data.HpFill.BackgroundColor3 =
                                                        Color3.fromRGB(
                                                                255,
                                                                200,
                                                                0
                                                        )

                                        else

                                                data.HpFill.BackgroundColor3 =
                                                        Color3.fromRGB(
                                                                255,
                                                                60,
                                                                60
                                                        )
                                        end
                                end

                        else

                                destroyESP(plr)

                        end
                end
        end)
        if not ok then
            pcall(destroyESP, plr)
            if os.clock() - espLastPlayerError >= 5 then
                espLastPlayerError = os.clock()
                warn("[AR2 SCRIPTS] ESP player update: " .. tostring(err))
            end
        end
        end
end

--==================================================
-- STATUS
--==================================================

local updateStatus

function updateStatus()

        local active = 0

        if espEnabled then
                active += 1
        end

        if headshotControls and headshotControls.isEnabled() then
                active += 1
        end

        if airJumpEnabled then
                active += 1
        end
        if teleportEnabled then
                active += 1
        end
        if checkpointsEnabled then
                active += 1
        end
    if AR2_CFG.misc.freeze or AR2_CFG.misc.playerJesus then active += 1 end
    if AR2_carNoclipActive then active += 1 end
    if AR2_CFG.radar.on or AR2_CFG.minimap.on then active += 1 end
    local light=AR2_CFG.visuals
    if light.fullbright or light.nofog or light.setTime or light.skybox~="Default"
        or AR2_CFG.misc.removeShadows then active += 1 end

        statusPill.Text =
                active .. " ACTIVE"

        if active > 0 then

                statusPill.TextColor3 =
                        Color3.fromRGB(
                                245,
                                255,
                                248
                        )

                statusPill.BackgroundColor3 =
                        Color3.fromRGB(
                                25,
                                155,
                                72
                        )

                statusStroke.Color =
                        Color3.fromRGB(
                                70,
                                255,
                                125
                        )

                statusStroke.Transparency =
                        0.02

        else

                statusPill.TextColor3 =
                        Color3.fromRGB(
                                205,
                                215,
                                235
                        )

                statusPill.BackgroundColor3 =
                        Color3.fromRGB(
                                7,
                                10,
                                24
                        )

                statusStroke.Color =
                        Color3.fromRGB(
                                95,
                                255,
                                230
                        )

                statusStroke.Transparency =
                        0.42
        end
    statusPill.BackgroundColor3 = active > 0 and uiColors.active or uiColors.badge
    statusPill.TextColor3 = uiColors.accent
    statusStroke.Color = uiColors.accent
    statusStroke.Transparency = active > 0 and 0.6 or 0.85

end

--==================================================
-- SETTINGS PANELS
--==================================================

local function closeAllSettingsMenus()
end

local espSettingsMenu,
        espSettingsList =
        makeSettingsPanel(
                "ESPSettingsMenu",
                "ESP SETTINGS",
                142
        )

selectedButton = espButton
espSettingsMenu.Visible = true
title.Text = buttonData[espButton].title
subtitle.Text = buttonData[espButton].description
buttonData[espButton].refresh(false)

local aimbotSettingsMenu,
        aimbotSettingsList =
        makeSettingsPanel(
                "AimbotSettingsMenu",
                "Aimbot",
                142
        )

local movementSettingsMenu,
        movementSettingsList =
        makeSettingsPanel(
                "MovementSettingsMenu",
                "AIR JUMP SETTINGS",
                142
        )

local teleportSettingsMenu,
        teleportSettingsList =
        makeSettingsPanel(
                "TeleportSettingsMenu",
                "TELEPORT TO PLAYERS",
                142
        )

local checkpointsSettingsMenu, checkpointsSettingsList = makeSettingsPanel(
    "CheckpointsSettingsMenu", "DEATH LOCATIONS", 142
)
importedUI.freezeSettingsMenu, importedUI.freezeSettingsList = makeSettingsPanel("OtherPanel","OTHER",142)
importedUI.carsSettingsMenu, importedUI.carsSettingsList = makeSettingsPanel("CarsPanel","CARS",142)
importedUI.mapSettingsMenu, importedUI.mapSettingsList = makeSettingsPanel("MapPanel","MAP / RADAR",142)
importedUI.lightingSettingsMenu, importedUI.lightingSettingsList = makeSettingsPanel("LightingPanel","LIGHTING",142)
importedUI.settingsMenu, importedUI.settingsList = makeSettingsPanel("SettingsPanel","SETTINGS",142)
for _, panel in ipairs({importedUI.lightingSettingsMenu,importedUI.settingsMenu}) do
    panel.Size=UDim2.new(1,-208,0,316)
end
for _, entry in ipairs({
    {importedUI.freezeSettingsMenu,importedUI.freezeSettingsList},
    {importedUI.carsSettingsMenu,importedUI.carsSettingsList},
}) do
    local panel,list=entry[1],entry[2]
    panel.Size=UDim2.new(1,-208,0,190)
    list.Position=UDim2.fromOffset(12,42)
    list.Size=UDim2.new(1,-24,1,-54)
end
importedUI.mapSettingsMenu.Size=UDim2.new(1,-208,0,310)
importedUI.mapSettingsList.Position=UDim2.fromOffset(12,42)
importedUI.mapSettingsList.Size=UDim2.new(1,-24,1,-54)

function closeAllSettingsMenus()

    checkpointsSettingsMenu.Visible = false
    importedUI.freezeSettingsMenu.Visible = false
    importedUI.carsSettingsMenu.Visible = false
    importedUI.mapSettingsMenu.Visible = false
    importedUI.lightingSettingsMenu.Visible = false
    importedUI.settingsMenu.Visible = false
        espSettingsMenu.Visible = false
        aimbotSettingsMenu.Visible = false
        movementSettingsMenu.Visible = false
        teleportSettingsMenu.Visible = false
        buttonHolder.Visible = true

end

--==================================================
-- TOGGLE
--==================================================

-- A shared orange track and white thumb, matching the reference image.
-- Only the appearance changes; each option still uses its existing getter/setter.
local function addOrangeSwitch(parent, rightOffset, topOffset, width, height, zIndex)
    local track = widget("Frame", {
        Name="ToggleTrack", Position=UDim2.new(1,-rightOffset,0,topOffset),
        Size=UDim2.fromOffset(width,height), BackgroundColor3=uiColors.track,
        BorderSizePixel=0, ZIndex=zIndex,
    },parent)
    addCorner(track,height/2)
    local outline=addStroke(track,uiColors.edge,1,0.25)
    local thumbSize=height-6
    local thumb=widget("Frame", {
        Name="ToggleThumb", Position=UDim2.fromOffset(3,3),
        Size=UDim2.fromOffset(thumbSize,thumbSize),
        BackgroundColor3=Color3.fromRGB(255,255,255),BorderSizePixel=0,ZIndex=zIndex+1,
    },track)
    addCorner(thumb,thumbSize/2)
    local function refresh(enabled, animate)
        track.BackgroundColor3=enabled and uiColors.accent or uiColors.track
        outline.Color=enabled and uiColors.accent or uiColors.edge
        local pos=UDim2.fromOffset(enabled and (width-thumbSize-3) or 3,3)
        if animate then tween(thumb,0.18,{Position=pos}) else thumb.Position=pos end
    end
    return refresh
end

local function makeToggle(parent, text, getter, setter)
    local button = widget("TextButton", {Size=UDim2.new(1,-4,0,38), BackgroundColor3=uiColors.card,
        BackgroundTransparency=uiGlass.card,BorderSizePixel=0,Text="",AutoButtonColor=false,ZIndex=62}, parent)
    addCorner(button,6)
    local border=addStroke(button,uiColors.edge,1,0.4)
    local label=uiText(button,text,12,8,320,22,12,uiColors.text,Enum.Font.GothamBold)
    label.Size=UDim2.new(1,-77,0,22); label.ZIndex=63
    local updateSwitch=addOrangeSwitch(button,59,9,47,22,64)
    local function refresh()
        local enabled=getter()
        updateSwitch(enabled,false)
        button.BackgroundColor3=enabled and uiColors.selected or uiColors.card
        border.Color=enabled and uiColors.accent or uiColors.edge
    end
    button.MouseButton1Click:Connect(function() setter(not getter()); refresh() end)
    button.MouseEnter:Connect(function() border.Transparency=0.05 end)
    button.MouseLeave:Connect(function() border.Transparency=0.4; refresh() end)
    refresh()
    return button,refresh
end

-- One prominent master switch per feature. Options stay hidden while off.
local function makeFeatureSwitch(panel, content, name, getter, setter)
    panel.ClipsDescendants = true
    local button = widget("TextButton", {Name=name.."MasterToggle",
        Position=UDim2.new(0,12,0,41),Size=UDim2.new(1,-24,0,70),
        BackgroundColor3=uiColors.card,BackgroundTransparency=uiGlass.card,BorderSizePixel=0,Text="",
        AutoButtonColor=false,ZIndex=62},panel)
    addCorner(button,8)
    local border=addStroke(button,uiColors.edge,2,0.05)
    local heading=uiText(button,"Enable "..name,18,12,280,24,17,uiColors.text,Enum.Font.GothamBold)
    heading.Size=UDim2.new(1,-96,0,24);heading.ZIndex=63
    local caption=uiText(button,"Click to turn on and show settings",18,42,280,16,10,uiColors.muted)
    caption.Size=UDim2.new(1,-96,0,16);caption.ZIndex=63
    local updateSwitch=addOrangeSwitch(button,84,19,68,32,64)
    local function refresh(animate)
        local enabled=getter()
        heading.Text=enabled and ("Disable "..name) or ("Enable "..name)
        caption.Text=enabled and "Click to turn off" or "Click to turn on and show settings"
        updateSwitch(enabled,animate)
        button.BackgroundColor3=enabled and uiColors.selected or uiColors.card
        border.Color=enabled and uiColors.accent or uiColors.edge
        if content then content.Visible=enabled end
        local size = UDim2.new(1, -208, 0, enabled and 316 or 126)
        if animate and menuOpen and panel.Visible then
            tween(panel, 0.28, {Size=size})
        else
            panel.Size=size
        end
        if panel.Visible then resizeMenu(enabled, animate) end
    end
    button.MouseButton1Click:Connect(function()
        local ok, err = pcall(setter, not getter())
        refresh(true)
        if not ok then warn("[AR2 SCRIPTS] " .. name .. " toggle: " .. tostring(err)) end
    end)
    refresh()
    return button,refresh
end

--==================================================
-- SLIDER
--==================================================

local function makeSlider(
        parent,
        titleText,
        minValue,
        maxValue,
        defaultValue,
        decimals,
        onChanged,
        valueFormatter
)

        local row = Instance.new("Frame")

        row.Parent = parent
        row.Size = UDim2.new(1, -4, 0, 48)
        row.BackgroundColor3 = uiColors.card
        row.BackgroundTransparency = uiGlass.card
        row.BorderSizePixel = 0
        row.ZIndex = 62

        addCorner(row, 3)

        addStroke(
                row,
                uiColors.edge,
                1,
                0.35
        )

        local label = Instance.new("TextLabel")

        label.Parent = row
        label.Size = UDim2.new(1, -20, 0, 18)
        label.Position = UDim2.new(0, 10, 0, 5)
        label.BackgroundTransparency = 1
        label.TextColor3 = uiColors.text
        label.Font = Enum.Font.GothamBlack
        label.TextSize = 10
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.ZIndex = 63

        local track = Instance.new("Frame")

        track.Parent = row
        track.Size = UDim2.new(1, -28, 0, 8)
        track.Position = UDim2.new(0, 14, 0, 31)
        track.BackgroundColor3 = uiColors.track
        track.BorderSizePixel = 0
        track.ZIndex = 63

        addCorner(track, 999)

        local fill = Instance.new("Frame")

        fill.Parent = track
        fill.Size = UDim2.new(0, 0, 1, 0)
        fill.BackgroundColor3 = uiColors.accent
        fill.BorderSizePixel = 0
        fill.ZIndex = 64

        addCorner(fill, 999)

        local knob = Instance.new("Frame")

        knob.Parent = track
        knob.AnchorPoint = Vector2.new(0.5, 0.5)
        knob.Size = UDim2.fromOffset(18, 18)
        knob.Position = UDim2.new(0, 0, 0.5, 0)
        knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        knob.BorderSizePixel = 0
        knob.ZIndex = 65

        addCorner(knob, 999)

        addStroke(
                knob,
                uiColors.accent,
                1,
                0.1
        )

        -- One transparent button above the track, fill and knob receives clicks
        -- across the entire slider instead of losing them to decorative frames.
        local hitArea = Instance.new("TextButton")
        hitArea.Parent = row
        hitArea.Position = UDim2.new(0, 8, 0, 22)
        hitArea.Size = UDim2.new(1, -16, 0, 26)
        hitArea.BackgroundTransparency = 1
        hitArea.Text = ""
        hitArea.AutoButtonColor = false
        hitArea.Active = true
        hitArea.ZIndex = 66

        local drag = false
        local currentValue = defaultValue

        local function roundValue(v)

                local pow =
                        10 ^ (decimals or 0)

                return math.floor(
                        v * pow + 0.5
                ) / pow
        end

        local function displayValue(v)

                if valueFormatter then
                        return valueFormatter(v)
                end

                if decimals and decimals > 0 then

                        return string.format(
                                "%."
                                        .. decimals
                                        .. "f",
                                v
                        )
                end

                return tostring(
                        math.floor(v + 0.5)
                )
        end

        local function setValue(v, fire)

                currentValue =
                        roundValue(
                                math.clamp(
                                        v,
                                        minValue,
                                        maxValue
                                )
                        )

                local alpha =
                        (
                                currentValue
                                - minValue
                        )
                        /
                        math.max(
                                0.001,
                                maxValue - minValue
                        )

                fill.Size =
                        UDim2.new(
                                alpha,
                                0,
                                1,
                                0
                        )

                knob.Position =
                        UDim2.new(
                                alpha,
                                0,
                                0.5,
                                0
                        )

                label.Text =
                        titleText
                        .. ": "
                        .. displayValue(
                                currentValue
                        )

                if fire and onChanged then
                        onChanged(currentValue)
                end
        end

        local function updateFromX(x)

                local relative =
                        math.clamp(
                                (
                                        x
                                        - track.AbsolutePosition.X
                                )
                                /
                                math.max(
                                        1,
                                        track.AbsoluteSize.X
                                ),
                                0,
                                1
                        )

                setValue(
                        minValue
                                + (
                                        maxValue
                                        - minValue
                                ) * relative,
                        true
                )
        end

        hitArea.InputBegan:Connect(function(input)

                if input.UserInputType
                        == Enum.UserInputType.MouseButton1
                        or input.UserInputType == Enum.UserInputType.Touch then

                        drag = true

                        updateFromX(
                                input.Position.X
                        )
                end
        end)

        local sliderInputEnded = UserInputService.InputEnded:Connect(function(input)

                if input.UserInputType
                        == Enum.UserInputType.MouseButton1
                        or input.UserInputType == Enum.UserInputType.Touch then

                        drag = false
                end
        end)

        local sliderInputChanged = UserInputService.InputChanged:Connect(function(input)

                if drag and (input.UserInputType == Enum.UserInputType.MouseMovement
                        or input.UserInputType == Enum.UserInputType.Touch) then

                        updateFromX(
                                input.Position.X
                        )
                end
        end)

        hitArea.Destroying:Connect(function()
        sliderInputEnded:Disconnect()
        sliderInputChanged:Disconnect()
    end)
        setValue(
                defaultValue,
                false
        )

        return setValue, row
end

--==================================================
-- ACTION BUTTON
--==================================================

local function makeActionButton(
        parent,
        text,
        callback
)

        local button = Instance.new("TextButton")

        button.Parent = parent
        button.Size = UDim2.new(1, -4, 0, 34)
        button.BackgroundColor3 = uiColors.card
        button.BackgroundTransparency = uiGlass.card
        button.TextColor3 = uiColors.text
        button.Font = Enum.Font.GothamBlack
        button.TextSize = 11
        button.Text = text
        button.LayoutOrder = (text == "SAVE SESSION" or text == "RESET SETTINGS") and 90 or 0
        button.AutoButtonColor = false
        button.ZIndex = 62

        addCorner(button, 3)

        addStroke(
                button,
                uiColors.accent,
                1,
                0.25
        )

        button.MouseEnter:Connect(function()

                tweenFast(button, {
                        BackgroundColor3 = uiColors.selected
                })

        end)

        button.MouseLeave:Connect(function()

                tweenFast(button, {
                        BackgroundColor3 = uiColors.card
                })

        end)

        button.MouseButton1Click:Connect(function()

                if callback then
                        callback(button)
                end

        end)

        return button
end

--==================================================
-- SETTINGS UI VARIABLES
--==================================================

local pendingAutoSave = false

local function queueSettingsSave()

        if pendingAutoSave then
                return
        end

        pendingAutoSave = true

        task.delay(1, function()

                pendingAutoSave = false
                saveCurrentSettings()

        end)
end

local showHpToggleRefresh
local showWeaponToggleRefresh
local refreshAirJumpFeature
local setEspNickScaleUI

local setEspDistanceScaleUI
local setEspDistanceUI
local setEspOutlineBrightnessUI
local setAirJumpsUI

local function refreshSettingsUI()
    if setEspNickScaleUI then setEspNickScaleUI(ESP_NICK_SCALE, false) end

        if showHpToggleRefresh then
                showHpToggleRefresh()
        end
    if showWeaponToggleRefresh then showWeaponToggleRefresh() end
        if setEspOutlineBrightnessUI then
                setEspOutlineBrightnessUI(ESP_OUTLINE_BRIGHTNESS, false)
        end

        if refreshAirJumpFeature then refreshAirJumpFeature() end
        if refreshEspFeature then refreshEspFeature() end

        setButton(
                movementButton,
                airJumpEnabled
        )

        if setAirJumpsUI then
                setAirJumpsUI(
                        MAX_AIR_JUMPS,
                        false
                )
        end

        if setEspDistanceScaleUI then

                setEspDistanceScaleUI(
                        ESP_DISTANCE_SCALE,
                        false
                )
        end

        if setEspDistanceUI then

                setEspDistanceUI(
                        ESP_MAX_DISTANCE,
                        false
                )
        end



end

local function resetAllSettings()

        applySettings(
                copyDefaultSettings()
        )

        refreshSettingsUI()

        if espEnabled then
                updateESP()
        end

        updateStatus()
        saveCurrentSettings()
end

local function setButtonTempText(
        button,
        text,
        seconds
)

        local oldText = button.Text

        button.Text = text

        task.delay(
                seconds or 1.2,
                function()

                        if button
                                and button.Parent then

                                button.Text = oldText
                        end
                end
        )
end

--==================================================
-- ESP SETTINGS
--==================================================

makeActionButton(
        espSettingsList,
        "SAVE SESSION",
        function(button)

                local ok, message =
                        saveCurrentSettings()

                setButtonTempText(
                        button,
                        ok
                                and "SESSION SAVED"
                                or message,
                        1.25
                )
        end
)

makeActionButton(
        espSettingsList,
        "RESET SETTINGS",
        function(button)

                resetAllSettings()

                setButtonTempText(
                        button,
                        "SETTINGS RESET",
                        1.25
                )
        end
)

local showHpToggleButton
showHpToggleButton, showHpToggleRefresh =
        makeToggle(
                espSettingsList,
                "Show HP",
                function()
                        return ESP_SHOW_HP
                end,
                function(value)

                        ESP_SHOW_HP = value

                        if espEnabled then
                                updateESP()
                        end

                        queueSettingsSave()
                end
        )

showHpToggleButton.LayoutOrder = -90

local weaponToggleButton
weaponToggleButton, showWeaponToggleRefresh = makeToggle(
    espSettingsList, "Weapon ESP", function() return ESP_SHOW_WEAPON end,
    function(value)
        ESP_SHOW_WEAPON = value
        if espEnabled then updateESP() end
        queueSettingsSave()
    end
)
weaponToggleButton.LayoutOrder = -88

local outlineBrightnessRow
setEspOutlineBrightnessUI, outlineBrightnessRow = makeSlider(
    espSettingsList,
    "Player outline brightness",
    0, 100,
    ESP_OUTLINE_BRIGHTNESS,
    0,
    function(value)
        ESP_OUTLINE_BRIGHTNESS = value
        if espEnabled then updateESP() end
        queueSettingsSave()
    end,
    function(value)
        return tostring(math.floor(value + 0.5)) .. "%"
    end
)
outlineBrightnessRow.LayoutOrder = -80

--==================================================
-- DISTANCE NUMBER SIZE
--==================================================

setEspDistanceScaleUI =
        makeSlider(
                espSettingsList,

                "Distance number size",

                0,
                2.5,

                ESP_DISTANCE_SCALE,

                2,

                function(v)

                        ESP_DISTANCE_SCALE = v

                        if espEnabled then
                                updateESP()
                        end

                        queueSettingsSave()
                end,

                function(v)

                        return math.floor(
                                v * 100 + 0.5
                        ) .. "%"
                end
        )

--==================================================
-- NICKNAME SIZE
--==================================================

setEspNickScaleUI = makeSlider(
    espSettingsList,
    "Nickname size",
    0,
    2.5,
    ESP_NICK_SCALE,
    2,
    function(value)
        ESP_NICK_SCALE = value
        if espEnabled then updateESP() end
        queueSettingsSave()
    end,
    function(value)
        return tostring(math.floor(value * 100 + 0.5)) .. "%"
    end
)

--==================================================
-- ESP DISTANCE
--==================================================

setEspDistanceUI =
        makeSlider(
                espSettingsList,

                "ESP visibility distance",

                25,
                10000,

                ESP_MAX_DISTANCE,

                0,

                function(v)

                        ESP_MAX_DISTANCE =
                                math.floor(v + 0.5)

                        if espEnabled then
                                updateESP()
                        end

                        queueSettingsSave()
                end,

                function(v)

                        return tostring(
                                math.floor(v + 0.5)
                        ) .. " studs"
                end
        )

--==================================================
-- AIR JUMP SETTINGS
--==================================================

makeActionButton(
        movementSettingsList,
        "SAVE SESSION",
        function(button)

                local ok, message =
                        saveCurrentSettings()

                setButtonTempText(
                        button,
                        ok
                                and "SESSION SAVED"
                                or message,
                        1.25
                )
        end
)

makeActionButton(
        movementSettingsList,
        "RESET SETTINGS",
        function(button)

                resetAllSettings()

                setButtonTempText(
                        button,
                        "SETTINGS RESET",
                        1.25
                )
        end
)

local airJumpMasterToggle
airJumpMasterToggle, refreshAirJumpFeature = makeFeatureSwitch(
    movementSettingsMenu, movementSettingsList, "AIR JUMP",
    function() return airJumpEnabled end,
    function(value)
        airJumpEnabled=value
        airJumpCount=0
        setButton(movementButton,value)
        updateStatus()
        queueSettingsSave()
    end
)

setAirJumpsUI =
        makeSlider(
                movementSettingsList,
                "Number of extra air jumps",
                1,
                20,
                MAX_AIR_JUMPS,
                0,
                function(v)

                        MAX_AIR_JUMPS =
                                math.floor(v + 0.5)

                        airJumpCount = 0
                        queueSettingsSave()
                end,
                function(v)
                        return tostring(
                                math.floor(v + 0.5)
                        ) .. "x"
                end
        )

--==================================================
-- CHECKPOINTS: DEAD MARKERS AT ENEMY DEATH LOCATIONS
--==================================================

local function initializeCheckpoints()
    local MARKER_LIFETIME = 120
    local MAX_MARKERS = 30
    local markers = {}
    local rows = {}
    local watchers = {}
    local connections = {}
    local markerFolderName = "AR2_EnemyDeathMarkers_" .. tostring(player.UserId)
    local previousFolder = Workspace:FindFirstChild(markerFolderName)
    if previousFolder then previousFolder:Destroy() end
    local markerFolder = Instance.new("Folder")
    markerFolder.Name = markerFolderName
    markerFolder.Parent = Workspace

    local status = Instance.new("TextLabel")
    status.Name = "CheckpointStatus"
    status.Parent = checkpointsSettingsList
    status.LayoutOrder = 1
    status.Size = UDim2.new(1, -4, 0, 48)
    status.BackgroundTransparency = 1
    status.TextColor3 = uiColors.text
    status.Font = Enum.Font.Gotham
    status.TextSize = 12
    status.TextWrapped = true
    status.ZIndex = 62

    local function distanceFromPlayer(position)
        local root = getRoot()
        local camera = Workspace.CurrentCamera
        local origin = root and root.Position or (camera and camera.CFrame.Position)
        return origin and math.floor((origin - position).Magnitude + 0.5) or nil
    end

    local function refreshCheckpoints(message)
        for _, row in ipairs(rows) do row:Destroy() end
        table.clear(rows)
        status.Text = message or string.format(
            "%d DEAD markers. Visible within %d studs; markers expire after 2 minutes.",
            #markers, DEAD_MARKER_DISTANCE
        )
        for index, marker in ipairs(markers) do
            local row = Instance.new("Frame")
            row.Name = "DeathLocation" .. tostring(index)
            row.Parent = checkpointsSettingsList
            row.LayoutOrder = 10 + index
            row.Size = UDim2.new(1, -4, 0, 48)
            row.BackgroundColor3 = uiColors.card
            row.BackgroundTransparency = uiGlass.card
            row.BorderSizePixel = 0
            row.ZIndex = 62
            addCorner(row, 5)
            addStroke(row, uiColors.edge, 1, 0.25)

            local label = Instance.new("TextLabel")
            label.Name = "DeathLocationLabel"
            label.Parent = row
            label.Position = UDim2.fromOffset(12, 7)
            label.Size = UDim2.new(1, -24, 1, -14)
            label.BackgroundTransparency = 1
            label.TextColor3 = Color3.fromRGB(255, 110, 122)
            label.Font = Enum.Font.GothamBold
            label.TextSize = 12
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.ZIndex = 63
            marker.rowLabel = label
            table.insert(rows, row)
        end
    end

    local function refreshMarkers()
        local now = os.clock()
        local changed = false
        for index = #markers, 1, -1 do
            local marker = markers[index]
            if now - marker.createdAt >= MARKER_LIFETIME then
                marker.anchor:Destroy()
                table.remove(markers, index)
                changed = true
            else
                local distance = distanceFromPlayer(marker.position)
                marker.billboard.Enabled = checkpointsEnabled
                    and distance ~= nil and distance <= DEAD_MARKER_DISTANCE
                if marker.rowLabel then
                    marker.rowLabel.Text = "DEAD: " .. marker.displayName .. "  |  " ..
                        (distance and (tostring(distance) .. " studs") or "unknown distance")
                end
            end
        end
        if changed then refreshCheckpoints() end
    end

    local function clearMarkers()
        for _, marker in ipairs(markers) do marker.anchor:Destroy() end
        table.clear(markers)
        refreshCheckpoints("DEAD markers cleared. New enemy deaths will appear here.")
    end

    local clearButton = makeActionButton(checkpointsSettingsList, "CLEAR DEAD MARKERS", clearMarkers)
    clearButton.Name = "ClearDeathMarkers"
    clearButton.LayoutOrder = 2

    local setDistanceUI = makeSlider(
        checkpointsSettingsList, "DEAD marker distance", 25, 10000,
        DEAD_MARKER_DISTANCE, 0,
        function(value)
            DEAD_MARKER_DISTANCE = math.floor(value + 0.5)
            refreshCheckpoints()
            refreshMarkers()
            queueSettingsSave()
        end,
        function(value) return tostring(math.floor(value + 0.5)) .. " studs" end
    )

    local function markDeath(plr, position)
        if not checkpointsEnabled or not position or isSameTeam(plr) then return end
        local anchor = Instance.new("Part")
        anchor.Name = "EnemyDeathLocation"
        anchor.Size = Vector3.new(0.2, 0.2, 0.2)
        anchor.CFrame = CFrame.new(position)
        anchor.Anchored = true
        anchor.CanCollide = false
        anchor.CanTouch = false
        anchor.CanQuery = false
        anchor.Transparency = 1
        anchor.Parent = markerFolder

        local billboard = Instance.new("BillboardGui")
        billboard.Name = "DeadMarker"
        billboard.Adornee = anchor
        billboard.Size = UDim2.fromOffset(104, 38)
        billboard.StudsOffsetWorldSpace = Vector3.new(0, 2.5, 0)
        billboard.MaxDistance = 10000
        billboard.AlwaysOnTop = true
        billboard.Parent = anchor

        local label = Instance.new("TextLabel")
        label.Name = "DeadLabel"
        label.Size = UDim2.fromScale(1, 1)
        label.BackgroundColor3 = Color3.fromRGB(40, 8, 16)
        label.BackgroundTransparency = 0.1
        label.BorderSizePixel = 0
        label.Text = "DEAD\n" .. (plr.DisplayName or plr.Name)
        label.Font = Enum.Font.GothamBold
        label.TextSize = 11
        label.TextColor3 = Color3.fromRGB(255, 80, 98)
        label.TextWrapped = true
        label.Parent = billboard
        addCorner(label, 5)
        addStroke(label, Color3.fromRGB(255, 57, 78), 1.5, 0.05)

        table.insert(markers, 1, {
            anchor = anchor, billboard = billboard, position = position,
            displayName = plr.DisplayName or plr.Name, createdAt = os.clock(),
        })
        while #markers > MAX_MARKERS do
            local oldest = table.remove(markers)
            oldest.anchor:Destroy()
        end
        refreshCheckpoints()
        refreshMarkers()
    end

    local function characterPosition(character)
        if not character then return nil end
        local part = character:FindFirstChild("HumanoidRootPart")
            or character:FindFirstChild("Head")
        return part and part.Position or nil
    end

    local function disconnectCharacter(record)
        if record.died then record.died:Disconnect(); record.died = nil end
        if record.healthChanged then record.healthChanged:Disconnect(); record.healthChanged = nil end
        if record.childAdded then record.childAdded:Disconnect(); record.childAdded = nil end
        if record.ancestry then record.ancestry:Disconnect(); record.ancestry = nil end
        if record.destroying then record.destroying:Disconnect(); record.destroying = nil end
    end

    local function watchCharacter(plr, character, record)
        if record.character and record.character ~= character and not record.deathHandled
            and record.lastPosition and os.clock() - (record.lastSeenAt or 0) < 5 then
            -- Some games replace a character without firing Humanoid.Died.
            record.deathHandled = true
            markDeath(plr, record.lastPosition)
        end
        disconnectCharacter(record)
        record.character = character
        record.deathHandled = false
        record.lastPosition = characterPosition(character)
        record.lastSeenAt = record.lastPosition and os.clock() or nil
        record.wasInWorld = character:IsDescendantOf(Workspace)

        local function onDeath()
            if record.character ~= character or record.deathHandled then return end
            record.deathHandled = true
            markDeath(plr, characterPosition(character) or record.lastPosition)
        end

        record.ancestry = character.AncestryChanged:Connect(function()
            if character:IsDescendantOf(Workspace) then
                record.wasInWorld = true
            elseif record.wasInWorld and record.lastPosition
                and os.clock() - (record.lastSeenAt or 0) < 5 then
                onDeath()
            end
        end)
        record.destroying = character.Destroying:Connect(onDeath)

        local function watchHumanoid(humanoid)
            if record.died then record.died:Disconnect() end
            if record.healthChanged then record.healthChanged:Disconnect() end
            record.died = humanoid.Died:Connect(onDeath)
            record.healthChanged = humanoid.HealthChanged:Connect(function(health)
                if health <= 0 then onDeath() end
            end)
            if humanoid.Health <= 0 then onDeath() end
        end

        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            watchHumanoid(humanoid)
        else
            record.childAdded = character.ChildAdded:Connect(function(child)
                if child:IsA("Humanoid") then
                    watchHumanoid(child)
                    record.childAdded:Disconnect()
                    record.childAdded = nil
                end
            end)
        end
    end

    local function unwatchPlayer(plr)
        local record = watchers[plr]
        if not record then return end
        disconnectCharacter(record)
        if record.characterAdded then record.characterAdded:Disconnect() end
        if record.characterRemoving then record.characterRemoving:Disconnect() end
        watchers[plr] = nil
    end

    local function watchPlayer(plr)
        if plr == player or watchers[plr] then return end
        local record = {}
        watchers[plr] = record
        record.characterAdded = plr.CharacterAdded:Connect(function(character)
            watchCharacter(plr, character, record)
        end)
        record.characterRemoving = plr.CharacterRemoving:Connect(function(character)
            if record.character == character and not record.deathHandled
                and record.lastPosition and os.clock() - (record.lastSeenAt or 0) < 5 then
                -- Death fallback for custom character removal in AR2.
                record.deathHandled = true
                markDeath(plr, characterPosition(character) or record.lastPosition)
            end
        end)
        if plr.Character then watchCharacter(plr, plr.Character, record) end
    end

    table.insert(connections, Players.PlayerAdded:Connect(watchPlayer))
    table.insert(connections, Players.PlayerRemoving:Connect(unwatchPlayer))
    for _, plr in ipairs(Players:GetPlayers()) do watchPlayer(plr) end

    local elapsed = 0
    local function checkpointFrame(dt)
        elapsed = elapsed + (dt or 1 / 60)
        if elapsed < 0.15 then return end
        elapsed = 0
        for plr, record in pairs(watchers) do
            local character = plr.Character
            if character and record.character == character and not record.deathHandled then
                local position = characterPosition(character)
                if position then record.lastPosition = position; record.lastSeenAt = os.clock() end
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid and humanoid.Health <= 0 then
                    record.deathHandled = true
                    markDeath(plr, position or record.lastPosition)
                end
            end
        end
        refreshMarkers()
    end
    local checkpointConnection
    checkpointConnection = RunService.Heartbeat:Connect(function(dt)
        local ok, err = pcall(checkpointFrame, dt)
        if not ok then
            checkpointConnection:Disconnect()
            warn("[AR2 SCRIPTS] Checkpoints loop stopped: " .. tostring(err))
        end
    end)
    table.insert(connections, checkpointConnection)

    screenGui.Destroying:Connect(function()
        for _, connection in ipairs(connections) do connection:Disconnect() end
        for plr in pairs(watchers) do unwatchPlayer(plr) end
        clearMarkers()
        markerFolder:Destroy()
    end)

    refreshCheckpoints()
    return refreshCheckpoints, function(enabled)
        refreshCheckpoints()
        refreshMarkers()
    end, setDistanceUI
end

local refreshCheckpoints, setDeathMarkersEnabled, setDeadMarkerDistanceUI = initializeCheckpoints()
local checkpointsMasterToggle, refreshCheckpointsFeature = makeFeatureSwitch(
    checkpointsSettingsMenu, checkpointsSettingsList, "DEAD MARKERS",
    function() return checkpointsEnabled end,
    function(value)
        checkpointsEnabled = value
        setButton(checkpointsButton, value)
        setDeathMarkersEnabled(value)
        updateStatus()
    end
)
--==================================================
-- TELEPORT TO PLAYERS - SEPARATE TAB
--==================================================

local teleportResetButton =
        makeActionButton(
                teleportSettingsList,
                "UNDO LAST TELEPORT",
                function(button)
                        if not teleportAccess.Unlocked then return end

                        local ok, message =
                                resetLastTeleport()

                        setButtonTempText(
                                button,
                                ok
                                        and "LAST TELEPORT UNDONE"
                                        or message,
                                1.25
                        )
                end
        )

teleportResetButton.LayoutOrder = 1
teleportResetButton.BackgroundColor3 = uiColors.card
teleportResetButton.TextColor3 = uiColors.text

local teleportRefreshButton

local teleportPlayersHeader = Instance.new("TextLabel")

teleportPlayersHeader.Parent = teleportSettingsList
teleportPlayersHeader.LayoutOrder = 3
teleportPlayersHeader.Size = UDim2.new(1, -4, 0, 32)
teleportPlayersHeader.BackgroundColor3 = uiColors.card
teleportPlayersHeader.BackgroundTransparency = uiGlass.card
teleportPlayersHeader.BorderSizePixel = 0
teleportPlayersHeader.TextColor3 = uiColors.text
teleportPlayersHeader.Font = Enum.Font.GothamBlack
teleportPlayersHeader.TextSize = 11
teleportPlayersHeader.TextXAlignment = Enum.TextXAlignment.Left
teleportPlayersHeader.Text = "  SELECT A PLAYER"
teleportPlayersHeader.ZIndex = 62

addCorner(teleportPlayersHeader, 10)

addStroke(
        teleportPlayersHeader,
        uiColors.edge,
        1,
        0.58
)

local teleportPlayerRows = {}

local function clearTeleportPlayerRows()

        for _, row in ipairs(teleportPlayerRows) do

                if row and row.Parent then
                        row:Destroy()
                end
        end

        table.clear(teleportPlayerRows)
end

local function makeTeleportInfoRow(text)

        local label = Instance.new("TextLabel")

        label.Parent = teleportSettingsList
        label.LayoutOrder = 10
        label.Size = UDim2.new(1, -4, 0, 34)
        label.BackgroundColor3 = uiColors.card
        label.BackgroundTransparency = uiGlass.card
        label.BorderSizePixel = 0
        label.TextColor3 = uiColors.muted
        label.Font = Enum.Font.GothamBold
        label.TextSize = 11
        label.Text = text
        label.ZIndex = 62

        addCorner(label, 11)

        addStroke(
                label,
                uiColors.edge,
                1,
                0.5
        )

        table.insert(teleportPlayerRows, label)
end

local function refreshTeleportPlayerList()

        clearTeleportPlayerRows()
        if not teleportAccess.Unlocked then return end

        local targets = {}

        for _, plr in ipairs(Players:GetPlayers()) do

                if plr ~= player then
                        table.insert(targets, plr)
                end
        end

        table.sort(targets, function(a, b)
                return string.lower(a.Name) < string.lower(b.Name)
        end)

        if #targets == 0 then
                makeTeleportInfoRow("No other players on this server")
                return
        end

        for index, plr in ipairs(targets) do

                local targetPlayer = plr

                local displayName =
                        targetPlayer.DisplayName
                        or targetPlayer.Name

                local username =
                        targetPlayer.Name

                local displayText

                if displayName ~= username then

                        displayText =
                                '<font color="rgb(255,255,255)" size="14"><b>'
                                .. displayName
                                .. '</b></font>\n'
                                .. '<font color="rgb(235,235,235)" size="10">@'
                                .. username
                                .. '</font>'
                else

                        displayText =
                                '<font color="rgb(255,255,255)" size="14"><b>'
                                .. username
                                .. '</b></font>'
                end

                local button =
                        makeActionButton(
                                teleportSettingsList,
                                displayText,
                                function(clickedButton)
                                        if not teleportAccess.Unlocked then return end

                                        local ok, message =
                                                teleportToPlayer(targetPlayer)

                                        setButtonTempText(
                                                clickedButton,
                                                ok
                                                        and ("TELEPORTED TO " .. targetPlayer.Name)
                                                        or message,
                                                1.1
                                        )
                                end
                        )

                button.LayoutOrder = 10 + index
                button.Size = UDim2.new(1, -4, 0, 52)
                button.BackgroundColor3 = uiColors.card
                button.BackgroundTransparency = uiGlass.card
                button.TextColor3 = Color3.fromRGB(255, 255, 255)
                button.TextSize = 13
                button.Font = Enum.Font.GothamBold
                button.RichText = true
                button.TextWrapped = true
                button.TextXAlignment = Enum.TextXAlignment.Left
                button.TextYAlignment = Enum.TextYAlignment.Center
                button.Text = "   " .. displayText

                table.insert(
                        teleportPlayerRows,
                        button
                )
        end
end

teleportRefreshButton =
        makeActionButton(
                teleportSettingsList,
                "REFRESH PLAYER LIST",
                function(button)
                        if not teleportAccess.Unlocked then return end

                        refreshTeleportPlayerList()

                        setButtonTempText(
                                button,
                                "PLAYER LIST REFRESHED",
                                1
                        )
                end
        )

teleportRefreshButton.LayoutOrder = 2
teleportRefreshButton.BackgroundColor3 = uiColors.card
teleportRefreshButton.TextColor3 = uiColors.text


-- Only teleporting to another player requires the local password. Clicking
-- the scroll wheel is controlled by its own switch above this prompt.
do
    local prompt = Instance.new("Frame")
    prompt.Name = "TeleportPasswordPrompt"
    prompt.Parent = teleportSettingsMenu
    prompt.Position = UDim2.new(0, 12, 0, 120)
    prompt.Size = UDim2.new(1, -24, 1, -132)
    prompt.BackgroundTransparency = 1
    prompt.ZIndex = 62

    local heading = Instance.new("TextLabel")
    heading.Parent = prompt
    heading.Position = UDim2.new(0, 4, 0, 5)
    heading.Size = UDim2.new(1, -8, 0, 28)
    heading.BackgroundTransparency = 1
    heading.Text = "TELEPORT TO PLAYERS"
    heading.TextColor3 = uiColors.text
    heading.Font = Enum.Font.GothamBold
    heading.TextSize = 16
    heading.ZIndex = 63

    local message = Instance.new("TextLabel")
    message.Name = "TeleportPasswordMessage"
    message.Parent = prompt
    message.Position = UDim2.new(0, 8, 0, 36)
    message.Size = UDim2.new(1, -16, 0, 38)
    message.BackgroundTransparency = 1
    message.TextColor3 = uiColors.muted
    message.Font = Enum.Font.Gotham
    message.TextSize = 13
    message.TextWrapped = true
    message.ZIndex = 63

    local password = Instance.new("TextBox")
    password.Name = "TeleportPasswordInput"
    password.Parent = prompt
    password.Position = UDim2.new(0, 8, 0, 82)
    password.Size = UDim2.new(1, -16, 0, 38)
    password.BackgroundColor3 = uiColors.card
    password.BackgroundTransparency = uiGlass.card
    password.BorderSizePixel = 0
    password.Text = ""
    password.PlaceholderText = "Enter password"
    password.PlaceholderColor3 = uiColors.muted
    password.TextColor3 = uiColors.text
    password.Font = Enum.Font.Gotham
    password.TextSize = 15
    password.ClearTextOnFocus = false
    password.MultiLine = false
    password.ZIndex = 63
    addCorner(password, 10)
    addStroke(password, uiColors.accent, 1, 0.35)

    local function unlock()
        if teleportAccess.Unlocked or not menuOpen or not frame.Visible
            or not screenGui.Enabled or not teleportSettingsMenu.Visible then
            return
        end
        if password.Text ~= "makapaka" then
            message.Text = "Incorrect password. Try again."
            message.TextColor3 = Color3.fromRGB(255, 120, 140)
            password.Text = ""
            password:CaptureFocus()
            return
        end
        teleportAccess.Unlocked = true
        password:ReleaseFocus()
        password.Text = ""
        teleportAccess.Sync()
        refreshTeleportPlayerList()
    end

    local unlockButton = makeActionButton(prompt, "UNLOCK", unlock)
    unlockButton.Name = "UnlockPlayerTeleport"
    unlockButton.Position = UDim2.new(0, 8, 0, 132)
    unlockButton.Size = UDim2.new(1, -16, 0, 38)
    unlockButton.ZIndex = 63
    password.FocusLost:Connect(function(enterPressed)
        if enterPressed then unlock() end
    end)

    teleportAccess.Lock = function()
        teleportAccess.Unlocked = false
        teleportAccess.ShowPlayers = false
        teleportAccess.Sync()
        password.Text = ""
        password:ReleaseFocus()
        message.Text = "Enter the password to open the player teleport panel."
        message.TextColor3 = uiColors.muted
        clearTeleportPlayerRows()
    end
    teleportAccess.Sync = function()
        prompt.Visible = teleportAccess.ShowPlayers and not teleportAccess.Unlocked
        teleportSettingsList.Visible = teleportAccess.ShowPlayers and teleportAccess.Unlocked
    end

    teleportAccess.Lock()
end

-- The Teleport tab is always openable. Its scroll-click control is independent
-- of the password-protected player list.
local teleportClickToggle = widget("TextButton", {
    Name = "ClickToTeleportToggle",
    Position = UDim2.new(0, 12, 0, 41), Size = UDim2.new(1, -24, 0, 70),
    BackgroundColor3 = uiColors.card, BackgroundTransparency = uiGlass.card,
    BorderSizePixel = 0, Text = "",
    AutoButtonColor = false, ZIndex = 62,
}, teleportSettingsMenu)
addCorner(teleportClickToggle, 8)
local clickBorder = addStroke(teleportClickToggle, uiColors.edge, 2, 0.05)
local clickHeading = uiText(teleportClickToggle, "Click to teleport", 18, 12, 280, 24,
    17, uiColors.text, Enum.Font.GothamBold)
clickHeading.Size = UDim2.new(1, -96, 0, 24)
clickHeading.ZIndex = 63
local clickCaption = uiText(teleportClickToggle, "Press the scroll wheel (MMB) in game",
    18, 42, 280, 16, 10, uiColors.muted)
clickCaption.Size = UDim2.new(1, -96, 0, 16)
clickCaption.ZIndex = 63
local refreshClickSwitch = addOrangeSwitch(teleportClickToggle,84,19,68,32,64)
local openPlayerTeleport = widget("TextButton", {
    Name="OpenPlayerTeleport",Position=UDim2.new(0,12,0,121),
    Size=UDim2.new(1,-24,0,34),BackgroundColor3=uiColors.card,
    BackgroundTransparency=uiGlass.card,
    BorderSizePixel=0,Text="Teleport to players  ›",TextColor3=uiColors.text,
    Font=Enum.Font.GothamBold,TextSize=12,AutoButtonColor=false,ZIndex=62,
},teleportSettingsMenu)
addCorner(openPlayerTeleport,5)
addStroke(openPlayerTeleport,uiColors.edge,1,0.25)
local closePlayerTeleport = widget("TextButton", {
    Name="ClosePlayerTeleport",Position=UDim2.new(1,-84,0,6),
    Size=UDim2.fromOffset(72,28),BackgroundColor3=uiColors.card,
    BackgroundTransparency=uiGlass.card,
    BorderSizePixel=0,Text="Collapse",TextColor3=uiColors.muted,
    Font=Enum.Font.GothamBold,TextSize=11,AutoButtonColor=false,ZIndex=63,
},teleportSettingsMenu)
addCorner(closePlayerTeleport,5)
local function refreshTeleportPanel(animate)
    local expanded=teleportEnabled or teleportAccess.ShowPlayers
    local size=UDim2.new(1,-208,0,expanded and 316 or 170)
    openPlayerTeleport.Visible=not teleportAccess.ShowPlayers
    closePlayerTeleport.Visible=teleportAccess.ShowPlayers
    teleportAccess.Sync()
    if animate and menuOpen and teleportSettingsMenu.Visible then
        tween(teleportSettingsMenu,0.28,{Size=size})
    else
        teleportSettingsMenu.Size=size
    end
    if teleportSettingsMenu.Visible then resizeMenu(expanded,animate) end
end
local function refreshClickTeleport()
    refreshClickSwitch(teleportEnabled,true)
    teleportClickToggle.BackgroundColor3 = teleportEnabled and uiColors.selected
        or uiColors.card
    clickBorder.Color = teleportEnabled and uiColors.accent or uiColors.edge
end
teleportClickToggle.MouseButton1Click:Connect(function()
    teleportEnabled = not teleportEnabled
    setButton(teleportButton, teleportEnabled)
    refreshClickTeleport()
    updateStatus()
    refreshTeleportPanel(true)
end)
refreshClickTeleport()
openPlayerTeleport.MouseButton1Click:Connect(function()
    teleportAccess.ShowPlayers=true
    refreshTeleportPanel(true)
end)
closePlayerTeleport.MouseButton1Click:Connect(function()
    teleportAccess.ShowPlayers=false
    refreshTeleportPanel(true)
end)
refreshTeleportPanel(false)

refreshTeleportPlayerList()
refreshSettingsUI()

local AR2_setEspFromConfig
do
local function buildImportedControls()
-- ==================================================
-- IMPORTED CONTROLS IN THE ATTACHED MENU
-- ==================================================
local function mergedLabel(parent, text)
    local label = uiText(parent,text,10,0,380,24,10,uiColors.muted)
    label.Size=UDim2.new(1,-12,0,24)
    label.TextWrapped=true
    label.ZIndex=63
    return label
end

local updateImportedBadges
local function mergedToggle(parent,label,table_,key,callback)
    local _, refresh = makeToggle(parent,label,function() return table_[key] end,function(value)
        table_[key]=value
        if callback then callback(value) end
        if updateImportedBadges then updateImportedBadges() end
    end)
    return refresh
end

local function mergedSlider(parent,label,table_,key,min,max,step,callback)
    local set,row = makeSlider(parent,label,min,max,table_[key],step or 0,function(value)
        table_[key]=value
        if callback then callback(value) end
    end)
    return set,row
end

local refreshMergedControls = {}
local function featureRefresh(refresh)
    if refresh then table.insert(refreshMergedControls,refresh) end
    return refresh
end

-- Other groups the two independent features in one short panel.
featureRefresh(mergedToggle(importedUI.freezeSettingsList,"Freeze Zombies",AR2_CFG.misc,"freeze",
    function(value)
        if value then AR2_freeze.start() else AR2_freeze.stop() end
    end))
featureRefresh(mergedToggle(importedUI.freezeSettingsList,"Jesus",AR2_CFG.misc,"playerJesus",
    function(value) AR2_setPlayerJesus(value) end))

-- Cars contains only vehicle noclip and its speed.
local noclipState=AR2_CFG.misc
local refreshCarNoclip=mergedToggle(importedUI.carsSettingsList,"Vehicle Noclip",noclipState,"carNoclip",
    function(value)
        if value and not AR2_carNoclipSetEnabled(true) then
            noclipState.carNoclip=false
            warn("[AR2 merged] Vehicle Noclip requires a seat")
        elseif not value then AR2_carNoclipSetEnabled(false) end
    end)
featureRefresh(refreshCarNoclip)
local setNoclipSpeed = mergedSlider(importedUI.carsSettingsList,"Noclip speed",AR2_CFG.car,
    "noclipSpeed",10,1000,0)
featureRefresh(function()
    noclipState.carNoclip=AR2_carNoclipActive
    refreshCarNoclip()
    setNoclipSpeed(AR2_CFG.car.noclipSpeed,false)
end)

-- The game map radar and the separate minimap can be enabled independently.
mergedLabel(importedUI.mapSettingsList,"MAP RADAR")
featureRefresh(mergedToggle(importedUI.mapSettingsList,"Show Map",AR2_CFG.radar,"on",function(value)
    if value then AR2_radar.start() else AR2_radar.stop() end
    setButton(importedUI.mapButton,value or AR2_CFG.minimap.on)
end))
featureRefresh(mergedToggle(importedUI.mapSettingsList,"Show Vehicles",AR2_CFG.radar.vehicles,"on",
    function() if AR2_CFG.minimap.on then AR2_updateMinimap() end end))
mergedLabel(importedUI.mapSettingsList,"MINIMAP")
featureRefresh(mergedToggle(importedUI.mapSettingsList,"Show Minimap",AR2_CFG.minimap,"on",function(value)
    AR2_minimapEnabled=value
    AR2_minimapUpdate()
    AR2_updateMinimap()
    setButton(importedUI.mapButton,value or AR2_CFG.radar.on)
end))
local setMinimapSize=mergedSlider(importedUI.mapSettingsList,"Minimap size",AR2_CFG.minimap,
    "size",100,600,0,function() AR2_updateMinimap() end)
featureRefresh(function() setMinimapSize(AR2_CFG.minimap.size,false) end)

-- Lighting includes all settings from the Lighting subsection of World.
mergedLabel(importedUI.lightingSettingsList,"LIGHTING / SKY")
for _, entry in ipairs({
    {"Fullbright","fullbright"},{"No Fog","nofog"},{"Set Time","setTime"},
}) do
    featureRefresh(mergedToggle(importedUI.lightingSettingsList,entry[1],AR2_CFG.visuals,entry[2],
        function() AR2_visuals.apply() end))
end
local setBrightness=mergedSlider(importedUI.lightingSettingsList,"Brightness",AR2_CFG.visuals,
    "brightness",0,10,0,function() AR2_visuals.apply() end)
local setTime=mergedSlider(importedUI.lightingSettingsList,"Time",AR2_CFG.visuals,
    "time",0,24,0,function() AR2_visuals.apply() end)
featureRefresh(function()
    setBrightness(AR2_CFG.visuals.brightness,false)
    setTime(AR2_CFG.visuals.time,false)
end)
local skyboxes={"Default","Space","Galaxy","Galaxy 2","Galaxy 3","Saturne",
    "Neptune","Redshift","Pink Daylights","Purple Night","Gray Night","Anime Sky"}
local skyboxButton
skyboxButton=makeActionButton(importedUI.lightingSettingsList,"Skybox: Default  ›",function(button)
    local current=table.find(skyboxes,AR2_CFG.visuals.skybox) or 1
    local nextSky=skyboxes[current % #skyboxes+1]
    AR2_applySkybox(nextSky)
    button.Text="Skybox: "..nextSky.."  ›"
    if updateImportedBadges then updateImportedBadges() end
end)
featureRefresh(function()
    skyboxButton.Text="Skybox: "..tostring(AR2_CFG.visuals.skybox).."  ›"
end)
featureRefresh(mergedToggle(importedUI.lightingSettingsList,"Remove Shadows",AR2_CFG.misc,
    "removeShadows",function(value) AR2_setRemoveShadows(value) end))

-- Settings: named configurations, menu size/colours and theme presets.
local function mergedDeepCopy(sourceTable)
    local copied={}
    for key,value in pairs(sourceTable) do
        copied[key]=(type(value)=="table") and mergedDeepCopy(value) or value
    end
    return copied
end
local importedDefaults=mergedDeepCopy(AR2_CFG)
local configRoot="AR2_MERGED_CONFIG_"
local configName="default"
local function safeConfigName(value)
    return tostring(value or ""):gsub("[^%w_-]", ""):sub(1,40)
end
local function configPath(value)
    local name=safeConfigName(value)
    return name~="" and (configRoot..name..".json") or nil
end
local function mergeConfig(target,values)
    if type(values)~="table" then return end
    for key,current in pairs(target) do
        local incoming=values[key]
        if type(current)=="table" then mergeConfig(current,incoming)
        elseif type(current)==type(incoming) then target[key]=incoming end
    end
end
local function snapshotMerged()
    return {
        version=1,
        attached=exportSettings(), imported=mergedDeepCopy(AR2_CFG),
        toggles={esp=espEnabled,airJump=airJumpEnabled,teleport=teleportEnabled,
            checkpoints=checkpointsEnabled,
            aimbot=headshotControls and headshotControls.isEnabled() or false},
    }
end
local applyMergedConfig

mergedLabel(importedUI.settingsList,"CONFIG MANAGER")
local configField=widget("TextBox",{
    Name="ConfigName",Size=UDim2.new(1,-4,0,32),BackgroundColor3=uiColors.card,
    BackgroundTransparency=uiGlass.card,BorderSizePixel=0,
    Text="default",PlaceholderText="Configuration name",
    ClearTextOnFocus=false,TextColor3=uiColors.text,
    Font=Enum.Font.Gotham,TextSize=12,ZIndex=62,
},importedUI.settingsList)
addCorner(configField,4)
addStroke(configField,uiColors.edge,1,0.2)
local configStatus=mergedLabel(importedUI.settingsList,"Configs require readfile/writefile in the executor")
local function configMessage(message)
    configStatus.Text=tostring(message)
end
local function listConfigNames()
    if type(listfiles)~="function" then return {} end
    local ok,files=pcall(listfiles)
    if not ok then ok,files=pcall(listfiles,"") end
    if not ok or type(files)~="table" then return {} end
    local names={}
    for _,path in ipairs(files) do
        local name=tostring(path):match("AR2_MERGED_CONFIG_([%w_-]+)%.json$")
        if name then names[#names+1]=name end
    end
    table.sort(names)
    return names
end
makeActionButton(importedUI.settingsList,"Save Current Config",function()
    local path=configPath(configField.Text)
    if not path or type(writefile)~="function" then configMessage("Save unavailable") return end
    local ok,err=pcall(function() writefile(path,AR2_HttpService:JSONEncode(snapshotMerged())) end)
    configMessage(ok and ("Saved: "..safeConfigName(configField.Text)) or ("Save failed: "..tostring(err)))
end)
makeActionButton(importedUI.settingsList,"Load Config",function()
    local path=configPath(configField.Text)
    if not path or type(readfile)~="function" then configMessage("Load unavailable") return end
    local ok,result=pcall(function() return AR2_HttpService:JSONDecode(readfile(path)) end)
    if not ok or type(result)~="table" then configMessage("Load failed: "..tostring(result)) return end
    if applyMergedConfig then applyMergedConfig(result) end
    configMessage("Loaded: "..safeConfigName(configField.Text))
end)
makeActionButton(importedUI.settingsList,"Refresh Config List",function()
    local names=listConfigNames()
    configMessage(#names>0 and ("Saved: "..table.concat(names,", ")) or "No saved configs")
end)
makeActionButton(importedUI.settingsList,"Delete Config",function()
    local path=configPath(configField.Text)
    if not path or type(delfile)~="function" then configMessage("Delete unavailable") return end
    local ok,err=pcall(delfile,path)
    configMessage(ok and ("Deleted: "..safeConfigName(configField.Text)) or ("Delete failed: "..tostring(err)))
end)
makeActionButton(importedUI.settingsList,"Reset To Default",function()
    if applyMergedConfig then
        applyMergedConfig({attached=copyDefaultSettings(),imported=importedDefaults,
            toggles={esp=false,airJump=false,teleport=false,checkpoints=false,aimbot=false}})
    end
    configMessage("Default settings restored")
end)

mergedLabel(importedUI.settingsList,"UI SIZE")
local sizeNames={"Tiny","Small","Default","Large","Huge","Colossal"}
local sizeScales={Tiny=0.65,Small=0.8,Default=1,Large=1.2,Huge=1.45,Colossal=1.75}
local sizeButton
sizeButton=makeActionButton(importedUI.settingsList,"Size: Default  ›",function(button)
    local index=table.find(sizeNames,AR2_CFG.ui.sizePreset) or 3
    local nextSize=sizeNames[index % #sizeNames+1]
    AR2_CFG.ui.sizePreset=nextSize
    uiScaleMultiplier=sizeScales[nextSize] or 1
    updatePanelFit()
    frameScale.Scale=panelFitScale
    shadowScale.Scale=panelFitScale
    button.Text="Size: "..nextSize.."  ›"
end)
featureRefresh(function() sizeButton.Text="Size: "..AR2_CFG.ui.sizePreset.."  ›" end)

updateImportedBadges=function()
    setButton(importedUI.carsButton,AR2_carNoclipActive)
    setButton(importedUI.freezeButton,AR2_CFG.misc.freeze or AR2_CFG.misc.playerJesus)
    setButton(importedUI.mapButton,AR2_CFG.radar.on or AR2_CFG.minimap.on)
    local v=AR2_CFG.visuals
    setButton(importedUI.lightingButton,v.fullbright or v.nofog or v.setTime
        or v.skybox~="Default" or AR2_CFG.misc.removeShadows)
    updateStatus()
end

local function applyMenuTheme(accent,background,panelColor)
    local old={}
    for k,v in pairs(uiColors) do old[k]=v end
    uiColors.accent=accent or uiColors.accent
    uiColors.surface=background or uiColors.surface
    uiColors.card=panelColor or uiColors.card
    uiColors.selected=uiColors.accent:Lerp(uiColors.surface,0.55)
    uiColors.active=uiColors.accent:Lerp(uiColors.surface,0.72)
    uiColors.edge=uiColors.accent:Lerp(uiColors.surface,0.66)
    uiColors.badge=uiColors.selected:Lerp(uiColors.surface,0.5)
    uiColors.track=uiColors.card:Lerp(uiColors.surface,0.3)
    local palette={}
    for key,value in pairs(old) do
        if uiColors[key] and typeof(value)=="Color3" then
            palette[#palette+1]={value,uiColors[key]}
        end
    end
    local function recolor(value)
        for _,entry in ipairs(palette) do
            if value==entry[1] then return entry[2] end
        end
        return nil
    end
    for _,object in ipairs(screenGui:GetDescendants()) do
        if object:IsA("GuiObject") then
            local bg=recolor(object.BackgroundColor3)
            if bg then object.BackgroundColor3=bg end
            if object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox") then
                local fg=recolor(object.TextColor3)
                if fg then object.TextColor3=fg end
            end
        elseif object:IsA("UIStroke") then
            local col=recolor(object.Color)
            if col then object.Color=col end
        end
    end
    AR2_CFG.ui.accentRGB={math.floor(uiColors.accent.R*255+0.5),
        math.floor(uiColors.accent.G*255+0.5),math.floor(uiColors.accent.B*255+0.5)}
    AR2_CFG.ui.backgroundRGB={math.floor(uiColors.surface.R*255+0.5),
        math.floor(uiColors.surface.G*255+0.5),math.floor(uiColors.surface.B*255+0.5)}
    AR2_CFG.ui.panelRGB={math.floor(uiColors.card.R*255+0.5),
        math.floor(uiColors.card.G*255+0.5),math.floor(uiColors.card.B*255+0.5)}
    frame.BackgroundColor3=uiColors.surface
    frameStroke.Color=uiColors.accent
    uiGlass.frame=AR2_CFG.ui.transparency
    frame.BackgroundTransparency=uiGlass.frame
    for _,object in ipairs(screenGui:GetDescendants()) do
        if object:IsA("UICorner") and object.CornerRadius.Scale==0
            and object.CornerRadius.Offset<=12 then
            object.CornerRadius=UDim.new(0,AR2_CFG.ui.cornerRadius)
        end
    end
end

mergedLabel(importedUI.settingsList,"UI PERSONALIZATION")
local setHue=mergedSlider(importedUI.settingsList,"Accent Hue",AR2_CFG.ui,"accentHue",0,360,0,
    function(value)
        applyMenuTheme(Color3.fromHSV(value/360,0.82,0.96))
    end)
local transparencyUI={value=AR2_CFG.ui.transparency*100}
local setTransparency=mergedSlider(importedUI.settingsList,"Window transparency %",transparencyUI,
    "value",0,100,0,function(value)
        AR2_CFG.ui.transparency=value/100
        uiGlass.frame=AR2_CFG.ui.transparency
        frame.BackgroundTransparency=uiGlass.frame
    end)
local setCorners=mergedSlider(importedUI.settingsList,"Corner radius",AR2_CFG.ui,"cornerRadius",0,24,0,
    function() applyMenuTheme() end)
featureRefresh(function()
    setHue(AR2_CFG.ui.accentHue,false)
    setTransparency(AR2_CFG.ui.transparency*100,false)
    setCorners(AR2_CFG.ui.cornerRadius,false)
end)
featureRefresh(mergedToggle(importedUI.settingsList,"Glow Effects",AR2_CFG.ui,"glow",function(value)
    shadow.BackgroundTransparency=value and uiGlass.shadow or 1
end))
featureRefresh(mergedToggle(importedUI.settingsList,"Compact Mode",AR2_CFG.ui,"compact",function()
    if menuOpen then resizeMenu(true,true) end
end))

mergedLabel(importedUI.settingsList,"CUSTOM COLORS (R,G,B OR #RRGGBB)")
local function rgbToText(color)
    return string.format("%d,%d,%d",math.floor(color.R*255+0.5),
        math.floor(color.G*255+0.5),math.floor(color.B*255+0.5))
end
local function colorEntry(label,current)
    mergedLabel(importedUI.settingsList,label)
    local field=widget("TextBox",{
        Name="Color"..label:gsub("%W",""), Size=UDim2.new(1,-4,0,32),
        BackgroundColor3=uiColors.card,BackgroundTransparency=uiGlass.card,
        BorderSizePixel=0,Text=rgbToText(current),ClearTextOnFocus=false,
        TextColor3=uiColors.text,Font=Enum.Font.Gotham,TextSize=12,ZIndex=62,
    },importedUI.settingsList)
    addCorner(field,4)
    addStroke(field,uiColors.edge,1,0.2)
    return field
end
local accentField=colorEntry("Accent Color",uiColors.accent)
local backgroundField=colorEntry("Background Color",uiColors.surface)
local panelField=colorEntry("Panel Color",uiColors.card)
local function parseColor(value)
    local hex=tostring(value):match("^%s*#?(%x%x%x%x%x%x)%s*$")
    if hex then
        return Color3.fromRGB(tonumber(hex:sub(1,2),16),
            tonumber(hex:sub(3,4),16),tonumber(hex:sub(5,6),16))
    end
    local r,g,b=tostring(value):match("^%s*(%d+)%s*,%s*(%d+)%s*,%s*(%d+)%s*$")
    r,g,b=tonumber(r),tonumber(g),tonumber(b)
    if r and g and b and r<=255 and g<=255 and b<=255 then
        return Color3.fromRGB(r,g,b)
    end
end
makeActionButton(importedUI.settingsList,"Apply Custom Colors",function()
    local accent=parseColor(accentField.Text)
    local background=parseColor(backgroundField.Text)
    local panelColor=parseColor(panelField.Text)
    if not (accent and background and panelColor) then
        configMessage("Invalid colors: use 255,100,20 or #FF6414")
        return
    end
    applyMenuTheme(accent,background,panelColor)
    AR2_CFG.ui.accentHue=math.floor(select(1,accent:ToHSV())*360+0.5)
    setHue(AR2_CFG.ui.accentHue,false)
    configMessage("Custom colors applied")
end)
featureRefresh(function()
    accentField.Text=rgbToText(uiColors.accent)
    backgroundField.Text=rgbToText(uiColors.surface)
    panelField.Text=rgbToText(uiColors.card)
end)

mergedLabel(importedUI.settingsList,"THEME PRESETS")
for _,preset in ipairs({
    {"Pink",Color3.fromRGB(245,71,145),Color3.fromRGB(32,8,24),Color3.fromRGB(46,18,33)},
    {"Orange & Black",Color3.fromRGB(255,140,30),Color3.fromRGB(14,14,14),Color3.fromRGB(20,20,20)},
    {"Red & Black",Color3.fromRGB(230,40,60),Color3.fromRGB(14,14,14),Color3.fromRGB(20,20,20)},
    {"Cyan & Black",Color3.fromRGB(40,200,230),Color3.fromRGB(10,14,18),Color3.fromRGB(18,22,28)},
    {"Purple & Black",Color3.fromRGB(160,60,240),Color3.fromRGB(14,10,20),Color3.fromRGB(22,18,30)},
}) do
    makeActionButton(importedUI.settingsList,"Preset: "..preset[1],function()
        applyMenuTheme(preset[2],preset[3],preset[4])
        AR2_CFG.ui.accentHue=math.floor(select(1,preset[2]:ToHSV())*360+0.5)
        setHue(AR2_CFG.ui.accentHue,false)
    end)
end

local function syncImportedFeatures()
    -- Older saved presets may still contain switches removed from the Map tab.
    AR2_CFG.radar.localToo=false
    AR2_CFG.radar.weapon=false
    AR2_CFG.radar.dist=false
    AR2_CFG.radar.corpses.on=false
    -- Removed Cars and Freeze controls must not keep running from old presets.
    AR2_CFG.misc.freezeAll=false
    AR2_CFG.misc.freezeAnchor=true
    AR2_CFG.misc.freezeRadius=300
    AR2_CFG.car.fuel=false
    AR2_CFG.car.boost=false
    AR2_CFG.car.god=false
    AR2_CFG.car.maxTraction=false
    AR2_CFG.car.allCars=false
    AR2_CFG.car.boatMode=false
    AR2_CFG.car.removeDrag=false
    AR2_CFG.car.fullSteer=false
    AR2_CFG.car.fly=false
    if AR2_CFG.misc.freeze then AR2_freeze.start() else AR2_freeze.stop() end
    AR2_setBoatMode(false)
    AR2_carMods.destroy()
    AR2_setRemoveDrag(false)
    AR2_setFullSteer(false)
    AR2_carFlyStop()
    AR2_setPlayerJesus(AR2_CFG.misc.playerJesus)
    if AR2_CFG.misc.carNoclip then
        AR2_CFG.misc.carNoclip=AR2_carNoclipSetEnabled(true)
    elseif AR2_carNoclipActive then AR2_carNoclipSetEnabled(false) end
    if AR2_CFG.radar.on then AR2_radar.start() else AR2_radar.stop() end
    AR2_minimapEnabled=AR2_CFG.minimap.on
    AR2_minimapUpdate()
    AR2_updateMinimap()
    AR2_visuals.apply()
    AR2_applySkybox(AR2_CFG.visuals.skybox)
    AR2_setRemoveShadows(AR2_CFG.misc.removeShadows)
    local ui=AR2_CFG.ui
    local function color(rgb,fallback)
        return type(rgb)=="table" and Color3.fromRGB(
            tonumber(rgb[1]) or 0,tonumber(rgb[2]) or 0,tonumber(rgb[3]) or 0) or fallback
    end
    applyMenuTheme(color(ui.accentRGB,uiColors.accent),
        color(ui.backgroundRGB,uiColors.surface),color(ui.panelRGB,uiColors.card))
    uiScaleMultiplier=sizeScales[AR2_CFG.ui.sizePreset] or 1
    updatePanelFit()
    frameScale.Scale=panelFitScale
    shadowScale.Scale=panelFitScale
    for _,refresh in ipairs(refreshMergedControls) do refresh() end
    setButton(importedUI.freezeButton,AR2_CFG.misc.freeze or AR2_CFG.misc.playerJesus)
    setButton(importedUI.mapButton,AR2_CFG.radar.on or AR2_CFG.minimap.on)
    updateImportedBadges()
end

applyMergedConfig=function(data)
    if type(data)~="table" then return end
    if type(data.attached)=="table" then
        applySettings(data.attached)
        refreshSettingsUI()
        if espEnabled then updateESP() end
    end
    if type(data.imported)=="table" then mergeConfig(AR2_CFG,data.imported) end
    syncImportedFeatures()
    if type(data.toggles)=="table" then
        if data.toggles.esp~=nil and AR2_setEspFromConfig then
            AR2_setEspFromConfig(data.toggles.esp==true)
        end
        if data.toggles.aimbot~=nil and headshotControls
            and headshotControls.isEnabled()~=(data.toggles.aimbot==true) then
            headshotControls.toggle()
        end
        if data.toggles.teleport~=nil then
            teleportEnabled=data.toggles.teleport==true
            setButton(teleportButton,teleportEnabled)
            refreshClickTeleport()
            refreshTeleportPanel(false)
        end
        if data.toggles.checkpoints~=nil then
            checkpointsEnabled=data.toggles.checkpoints==true
            setButton(checkpointsButton,checkpointsEnabled)
            setDeathMarkersEnabled(checkpointsEnabled)
            if refreshCheckpointsFeature then refreshCheckpointsFeature(false) end
            refreshCheckpoints()
        end
    end
    updateStatus()
end

end
buildImportedControls()
end

--==================================================
-- SETTINGS MENU TOGGLE
--==================================================

local tabPanels = {
    {espButton, espSettingsMenu}, {aimbotButton, aimbotSettingsMenu},
    {movementButton, movementSettingsMenu},
    {teleportButton, teleportSettingsMenu}, {checkpointsButton, checkpointsSettingsMenu},
    {importedUI.freezeButton, importedUI.freezeSettingsMenu}, {importedUI.carsButton, importedUI.carsSettingsMenu},
    {importedUI.mapButton, importedUI.mapSettingsMenu}, {importedUI.lightingButton, importedUI.lightingSettingsMenu},
    {importedUI.settingsButton, importedUI.settingsMenu},
}
local function tabExpanded(panel)
    if panel == espSettingsMenu then return espEnabled end
    if panel == aimbotSettingsMenu then
        return headshotControls and headshotControls.isEnabled() or false
    end
    if panel == movementSettingsMenu then return airJumpEnabled end
    if panel == checkpointsSettingsMenu then return checkpointsEnabled end
    if panel == importedUI.freezeSettingsMenu or panel == importedUI.carsSettingsMenu or panel == importedUI.mapSettingsMenu
        or panel == importedUI.lightingSettingsMenu or panel == importedUI.settingsMenu then return true end
    if panel == teleportSettingsMenu then
        return teleportEnabled or teleportAccess.ShowPlayers
    end
    return false
end
local function selectTab(button, panel)
    if selectedButton == button and panel.Visible then
        if panel == espSettingsMenu and refreshEspFeature then
            refreshEspFeature(true)
        else
            resizeMenu(tabExpanded(panel), true)
        end
        return
    end
    closeAllSettingsMenus()
    selectedButton = button
    panel.Visible = true
    title.Text = buttonData[button].title
    subtitle.Text = buttonData[button].description
    for tab, data in pairs(buttonData) do data.refresh(false) end
    if panel == checkpointsSettingsMenu then refreshCheckpoints() end
    if panel == espSettingsMenu and refreshEspFeature then
        refreshEspFeature(true)
    else
        resizeMenu(tabExpanded(panel),true)
    end
end
for _, entry in ipairs(tabPanels) do
    local button, panel = entry[1], entry[2]
    button.MouseButton1Click:Connect(function() selectTab(button, panel) end)
end

--==================================================
-- ESP ENABLE / DISABLE
--==================================================

local function enableESP()

        espEnabled = true

        setButton(
                espButton,
                true
        )

        for _, plr in ipairs(Players:GetPlayers()) do
        local ok, err = pcall(createESP, plr)
        if not ok then warn("[AR2 SCRIPTS] ESP create: " .. tostring(err)) end
    end
    local ok, err = pcall(updateESP)
    if not ok then warn("[AR2 SCRIPTS] ESP initial update: " .. tostring(err)) end
        updateStatus()
end

local function disableESP()

        espEnabled = false

        setButton(
                espButton,
                false
        )

    local trackedPlayers = {}
    for plr in pairs(espObjects) do trackedPlayers[#trackedPlayers + 1] = plr end
        for _, plr in ipairs(trackedPlayers) do
        local ok, err = pcall(destroyESP, plr)
        if not ok then
            espObjects[plr] = nil
            warn("[AR2 SCRIPTS] ESP cleanup: " .. tostring(err))
        end
    end

        updateStatus()
end

AR2_setEspFromConfig=function(enabled)
    if enabled and not espEnabled then enableESP()
    elseif not enabled and espEnabled then disableESP() end
    if refreshEspFeature then refreshEspFeature() end
end

local espMasterToggle
espMasterToggle, refreshEspFeature = makeFeatureSwitch(espSettingsMenu, espSettingsList, "ESP", function() return espEnabled end, function(value)
    if value then enableESP() else disableESP() end
end)

--==================================================
-- PLAYERS
--==================================================

Players.PlayerAdded:Connect(function(plr)

        refreshTeleportPlayerList()

        plr.CharacterAdded:Connect(function()

                task.wait(0.8)

                if espEnabled then

                        destroyESP(plr)
                        createESP(plr)
                        updateESP()

                end
        end)
end)

Players.PlayerRemoving:Connect(function(plr)

        destroyESP(plr)

        -- PlayerRemoving can run before the player list updates,
        -- so rebuild the list after a short delay.
        task.delay(0.1, function()
                refreshTeleportPlayerList()
        end)

end)

for _, plr in ipairs(
        Players:GetPlayers()
) do

        if plr ~= player then

                plr.CharacterAdded:Connect(function()

                        task.wait(0.8)

                        if espEnabled then

                                destroyESP(plr)
                                createESP(plr)
                                updateESP()

                        end
                end)
        end
end

--==================================================
-- TELEPORT TO CURSOR
--==================================================

local function teleportToMouse()

        local root = getRoot()

        if not root then
                return
        end

        local hit = mouse.Hit

        if not hit then
                return
        end

        local targetPosition = hit.Position

        -- Move three studs above the surface
        -- to keep the character clear of the ground.
        root.CFrame = CFrame.new(
                targetPosition + Vector3.new(0, 3, 0)
        )
end

--==================================================
-- TELEPORT TO PLAYER
--==================================================

resetLastTeleport = function()

        if not lastTeleportPivot then
                return false, "NO TELEPORT TO UNDO"
        end

        local character = getCharacter()
        local root = getRoot()

        if not character or not root then
                return false, "YOUR CHARACTER IS NOT AVAILABLE"
        end

        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero

        character:PivotTo(lastTeleportPivot)

        -- Reset is one-use: after returning, there is no older saved position.
        lastTeleportPivot = nil

        return true, "TELEPORT UNDONE"
end

teleportToPlayer = function(targetPlayer)

        if not targetPlayer or targetPlayer == player then
                return false, "INVALID PLAYER"
        end

        local character = getCharacter()
        local root = getRoot()

        if not character or not root then
                return false, "YOUR CHARACTER IS NOT AVAILABLE"
        end

        local targetCharacter = targetPlayer.Character

        local targetHumanoid =
                targetCharacter
                and targetCharacter:FindFirstChildOfClass("Humanoid")

        local targetRoot =
                targetCharacter
                and targetCharacter:FindFirstChild("HumanoidRootPart")

        if not targetCharacter
                or not targetHumanoid
                or targetHumanoid.Health <= 0
                or not targetRoot then

                return false, "PLAYER IS NOT READY"
        end

        -- Save current position so UNDO LAST TELEPORT can return here.
        lastTeleportPivot = character:GetPivot()

        -- Stop momentum before teleporting.
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero

        -- Move the complete character model instead of only its root part.
        local destination =
                targetRoot.CFrame
                * CFrame.new(0, 1.5, 4.5)

        character:PivotTo(destination)

        -- Apply the destination again on the next deferred cycle
        -- to reduce immediate displacement from local physics.
        task.defer(function()

                local currentCharacter = getCharacter()

                if currentCharacter == character
                        and character.Parent
                        and targetRoot.Parent then

                        character:PivotTo(
                                targetRoot.CFrame
                                * CFrame.new(0, 1.5, 4.5)
                        )
                end
        end)

        return true, "TELEPORTED"
end

--==================================================
-- MULTI JUMP / DOUBLE JUMP / TRIPLE JUMP
--==================================================

local airJumpCount = 0
local wasGrounded = true
local lastAirJumpTime = 0
local AIR_JUMP_COOLDOWN = 0.08

local function getHumanoidAndRoot()
        local character = getCharacter()

        if not character then
                return nil, nil
        end

        local humanoid =
                character:FindFirstChildOfClass("Humanoid")

        local root =
                character:FindFirstChild("HumanoidRootPart")

        return humanoid, root
end

local function resetAirJumpsIfLanded()
        local humanoid = getHumanoidAndRoot()

        if not humanoid or humanoid.Health <= 0 then
                airJumpCount = 0
                wasGrounded = true
                return
        end

        local grounded =
                humanoid.FloorMaterial ~= Enum.Material.Air

        if grounded then
                if not wasGrounded then
                        airJumpCount = 0
                end

                wasGrounded = true
        else
                wasGrounded = false
        end
end

local function doAirJump()
        if not airJumpEnabled then
                return
        end

        if UserInputService:GetFocusedTextBox() then
                return
        end

        local humanoid, root =
                getHumanoidAndRoot()

        if not humanoid
                or not root
                or humanoid.Health <= 0 then
                return
        end

        if humanoid.Sit
                or humanoid:GetState()
                        == Enum.HumanoidStateType.Seated then
                return
        end

        -- Roblox handles the initial jump from the ground.
        -- Additional jumps are only applied while airborne.
        if humanoid.FloorMaterial ~= Enum.Material.Air then
                airJumpCount = 0
                return
        end

        if airJumpCount >= MAX_AIR_JUMPS then
                return
        end

        local now = os.clock()

        if now - lastAirJumpTime < AIR_JUMP_COOLDOWN then
                return
        end

        lastAirJumpTime = now
        airJumpCount += 1

        local jumpVelocity = 50

        if humanoid.UseJumpPower then
                jumpVelocity =
                        math.max(
                                humanoid.JumpPower,
                                50
                        )
        else
                jumpVelocity =
                        math.max(
                                math.sqrt(
                                        2
                                        * Workspace.Gravity
                                        * humanoid.JumpHeight
                                ),
                                50
                        )
        end

        local currentVelocity =
                root.AssemblyLinearVelocity

        humanoid.Jump = true
        humanoid:ChangeState(
                Enum.HumanoidStateType.Jumping
        )

        root.AssemblyLinearVelocity =
                Vector3.new(
                        currentVelocity.X,
                        jumpVelocity,
                        currentVelocity.Z
                )
end

--==================================================
-- INPUT
--==================================================

UserInputService.InputBegan:Connect(
        function(input, gameProcessed)

                if gameProcessed then
                        return
                end

                -- SPACE = ANOTHER AIR JUMP
                if input.KeyCode == Enum.KeyCode.Space then
                        doAirJump()
                end

                -- MIDDLE MOUSE CLICK = TELEPORT TO CURSOR
                if input.UserInputType
                        == Enum.UserInputType.MouseButton3 then

                        if teleportEnabled and not menuOpen then
                                teleportToMouse()
                        end
                end

        end
)

--==================================================
-- RENDER LOOP
--==================================================

local animationTimer = 0
local espTimer = 0

-- Keep ESP updates independent of menu animations and other render work.
-- Its distance labels must refresh even if an unrelated UI callback fails.
do
local frameConnections = {}
local function guardedFrame(signal, label, callback)
    local connection
    local lastWarning = -math.huge
    connection = signal:Connect(function(dt)
        local ok, err = pcall(callback, dt)
        if not ok then
            if label == "ESP loop" then
                if os.clock() - lastWarning >= 5 then
                    lastWarning = os.clock()
                    warn("[AR2 SCRIPTS] ESP update retry: " .. tostring(err))
                end
            else
                connection:Disconnect()
                warn("[AR2 SCRIPTS] " .. label .. " stopped: " .. tostring(err))
            end
        end
    end)
    return connection
end
frameConnections.heartbeat = guardedFrame(RunService.Heartbeat, "ESP loop", function(dt)
        if not espEnabled then
                espTimer = 0
                hoveredEspPlayer = nil
                return
        end
        espTimer += dt
        if espTimer < 0.1 then return end
        espTimer = 0
        updateESP()
        updateHoveredEspPlayer()
end)

frameConnections.render = guardedFrame(RunService.RenderStepped, "menu loop",
        function(dt)

        if menuOpen and not menuAnimating then
            local previousFit=panelFitScale
            updatePanelFit()
            if panelFitScale ~= previousFit
                or frameScale.Scale ~= panelFitScale
                or shadowScale.Scale ~= panelFitScale then
                frameScale.Scale = panelFitScale
                shadowScale.Scale = panelFitScale
            end
        end

                resetAirJumpsIfLanded()

                animationTimer += dt

                frameStroke.Transparency =
            (AR2_CFG.ui.glow and 0.04 or 0.65)
                        + math.abs(
                                math.sin(
                                        animationTimer * 1.2
                                )
                        ) * 0.08

        end
)
screenGui.Destroying:Connect(function()
    frameConnections.heartbeat:Disconnect()
    frameConnections.render:Disconnect()
end)
end

updateStatus()

-- Aimbot controls in their own tab.
local function initializeHeadshotPanel()
local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local userInputService = game:GetService("UserInputService")
local runService = game:GetService("RunService")
local players = game:GetService("Players")

local aimbotEnabled = false
local showFOV = true
local target = nil
local FOVCircle = 120
local minFOVSize = 30
local maxFOVSize = 200
local aimDistance = 1000
local minAimDistance = 10
local maxAimDistance = 2000

-- Approximate FRONT SIGHT positions measured at 1920x1080 in the supplied
-- recording.
-- An exposed 3D/GUI sight takes precedence. Tune these estimates per weapon
-- in the menu; zero for a scope means its visible reticle intersection.
local weaponSightProfiles = {
    {id = "AKM", names = {"AKM"}, x = 0, y = 0, unmeasured = true},
    {id = "AKS", names = {"AKS"}, x = 0, y = 0, unmeasured = true},
    {id = "AK-47", names = {"AK47"}, x = -4, y = -12},
    {id = "RPK-74M", names = {"RPK74M"}, x = -4, y = -20},
    {id = "RPK", names = {"RPK"}, x = -5, y = -22},
    {id = "AK-74", names = {"AK74"}, x = -4, y = -14},
    {id = "XM177", names = {"XM177", "XM"}, x = 0, y = -9},
    {id = "M16A2", names = {"M16A2"}, x = 0, y = 0, unmeasured = true},
    {id = "G3", names = {"G3"}, x = 0, y = 0, unmeasured = true},
    {id = "L85A1", names = {"L85A1"}, x = 0, y = 0, unmeasured = true},
    {id = "M16A1", names = {"M16A1"}, x = 0, y = 0, unmeasured = true},
    {id = "AS VAL", names = {"ASVAL"}, x = 0, y = 0, unmeasured = true},
    {id = "M4A1", names = {"M4A1"}, x = 0, y = -8},
    {id = "AUG", names = {"AUG"}, x = 0, y = 0, unmeasured = true},
    {id = "Operator M4A1", names = {"OPERATORM4A1", "OPEATORM4A1", "M4A1OPERATOR"}, x = 0, y = 0, unmeasured = true},
    {id = "ACC", names = {"ACC"}, x = 0, y = 0, unmeasured = true},
    {id = "AC-556", names = {"AC556"}, x = 0, y = 18},
    {id = "FAL", names = {"FAL"}, x = 0, y = 2},
    {id = "FAMAS", names = {"FAMAS"}, x = 0, y = 0, unmeasured = true},
    {id = "PSG-1", names = {"PSG1", "PSG"}, x = 0, y = 0},
    {id = "Dragunov", names = {"DRAGUNOV", "DRAGONVW", "SVD"}, x = 0, y = 0},
    {id = "MSG-90", names = {"MSG90", "MSG"}, x = 0, y = 0},
    {id = "VSS Vintorez", names = {"VSSVINTOREZ", "VSS"}, x = 0, y = 0},
    {id = "RPK-74", names = {"RPK74"}, x = 0, y = 0, unmeasured = true},
    {id = "PKM", names = {"PKM"}, x = -5, y = 12},
    {id = "M249 SAW", names = {"M249SAW", "M249"}, x = 0, y = -6},
    {id = "M60", names = {"M60"}, x = 0, y = 8},
    {id = "M1919A6", names = {"M1919A6"}, x = -4, y = -10},
    {id = "Patriot", names = {"PATRIOT"}, x = 0, y = -9},
}
local profileById = {}
local profileIndexById = {}
for index, profile in ipairs(weaponSightProfiles) do
    profileById[profile.id] = profile
    profileIndexById[profile.id] = index
end
local function identifySightWeapon(name)
    if type(name) ~= "string" then return nil end
    local normalized = string.upper(name):gsub("[^A-Z0-9]", "")
    local longestAlias, bestId = 0, nil
    for _, profile in ipairs(weaponSightProfiles) do
        for _, alias in ipairs(profile.names) do
            if normalized == alias then return profile.id end
            -- HUD labels can append ammunition. Prefer the most specific gun
            -- name, regardless of the order of the settings list.
            if #alias > longestAlias and string.sub(normalized, 1, #alias) == alias then
                longestAlias, bestId = #alias, profile.id
            end
        end
    end
    return bestId
end
local sightAdjustments = {}
local manualSightIndex = 0 -- zero means automatic detection
local lastManualSightIndex = 1
local displayedWeaponId = nil
local sightCalibrationFile = "AR2_weapon_sight_calibration.json"
local sightJSON = game:GetService("HttpService")
local savedPresetVersion = 0
if type(readfile) == "function" then
    local ok, saved = pcall(function()
        return sightJSON:JSONDecode(readfile(sightCalibrationFile))
    end)
    if ok and type(saved) == "table" then
        savedPresetVersion = tonumber(saved.__presetVersion) or 0
        for id, adjustment in pairs(saved) do
            if profileById[id] and type(adjustment) == "table" then
                local y = tonumber(adjustment.y)
                if y then
                    sightAdjustments[id] = {
                        y = math.floor(math.clamp(y, -100, 100) + 0.5),
                    }
                end
            end
        end
    end
end
local function saveSightCalibration()
    if type(writefile) == "function" then
        pcall(function()
            writefile(sightCalibrationFile, sightJSON:JSONEncode(sightAdjustments))
        end)
    end
end
-- Apply the updated defaults once, then keep any later per-weapon Y edits.
if savedPresetVersion < 1 then
    sightAdjustments["M1919A6"] = nil
end
if savedPresetVersion < 2 then
    sightAdjustments["M249 SAW"] = nil
    sightAdjustments.__presetVersion = 2
    saveSightCalibration()
else
    sightAdjustments.__presetVersion = savedPresetVersion
end

-- Create the menu
local oldAimbotGui = game:GetService("CoreGui"):FindFirstChild("AimbotMenu")
if oldAimbotGui then oldAimbotGui:Destroy() end
local dashboardGui = screenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = game:GetService("CoreGui")
screenGui.Name = "AimbotMenu"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true

-- Main window
local mainFrame = Instance.new("Frame")
mainFrame.Name = "AimbotOptions"
mainFrame.Size = UDim2.new(1, -28, 1, -132)
mainFrame.Position = UDim2.new(0, 14, 0, 120)
mainFrame.BackgroundColor3 = uiColors.surface
mainFrame.BackgroundTransparency = uiGlass.card
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = false
mainFrame.Parent = aimbotSettingsMenu
mainFrame.ZIndex = 62
mainFrame.Visible = false
aimbotSettingsList.Visible = false

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 3)
frameCorner.Parent = mainFrame
do
    local border = addStroke(mainFrame, Color3.new(1, 1, 1), 1.5, 0.2)
    border.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    border.Color = uiColors.edge
end

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = uiColors.card
title.BackgroundTransparency = uiGlass.card
title.TextColor3 = uiColors.accent
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Text = "Aimbot"
title.Parent = mainFrame

-- FOV size setting
local fovSizeLabel = Instance.new("TextLabel")
fovSizeLabel.Size = UDim2.new(0.8, 0, 0, 20)
fovSizeLabel.Position = UDim2.new(0.1, 0, 0, 234)
fovSizeLabel.BackgroundTransparency = 1
fovSizeLabel.TextColor3 = uiColors.muted
fovSizeLabel.Font = Enum.Font.Gotham
fovSizeLabel.TextSize = 11
fovSizeLabel.Text = "FOV Size: " .. FOVCircle
fovSizeLabel.TextXAlignment = Enum.TextXAlignment.Left
fovSizeLabel.Parent = mainFrame

-- Drag the FOV radius directly, with mouse or touch.
local fovSlider = Instance.new("Frame")
fovSlider.Name = "FOVSizeSlider"
fovSlider.Size = UDim2.new(0.8, 0, 0, 6)
fovSlider.Position = UDim2.new(0.1, 0, 0, 267)
fovSlider.BackgroundColor3 = uiColors.track
fovSlider.BorderSizePixel = 0
fovSlider.Active = true
fovSlider.Parent = mainFrame
local fovSliderCorner = Instance.new("UICorner")
fovSliderCorner.CornerRadius = UDim.new(1, 0)
fovSliderCorner.Parent = fovSlider
local fovSliderFill = Instance.new("Frame")
fovSliderFill.Size = UDim2.fromScale((FOVCircle - minFOVSize) / (maxFOVSize - minFOVSize), 1)
fovSliderFill.BackgroundColor3 = uiColors.accent
fovSliderFill.BorderSizePixel = 0
fovSliderFill.Parent = fovSlider
local fovSliderFillCorner = Instance.new("UICorner")
fovSliderFillCorner.CornerRadius = UDim.new(1, 0)
fovSliderFillCorner.Parent = fovSliderFill
local fovSliderKnob = Instance.new("TextButton")
fovSliderKnob.Name = "FOVSizeKnob"
fovSliderKnob.Size = UDim2.fromOffset(14, 14)
fovSliderKnob.AnchorPoint = Vector2.new(0.5, 0.5)
fovSliderKnob.Position = UDim2.new((FOVCircle - minFOVSize) / (maxFOVSize - minFOVSize), 0, 0.5, 0)
fovSliderKnob.BackgroundColor3 = uiColors.accent
fovSliderKnob.BorderSizePixel = 0
fovSliderKnob.Text = ""
fovSliderKnob.Parent = fovSlider
local fovSliderKnobCorner = Instance.new("UICorner")
fovSliderKnobCorner.CornerRadius = UDim.new(1, 0)
fovSliderKnobCorner.Parent = fovSliderKnob

-- Maximum aim distance setting
local aimDistanceLabel = Instance.new("TextLabel")
aimDistanceLabel.Size = UDim2.new(0.8, 0, 0, 20)
aimDistanceLabel.Position = UDim2.new(0.1, 0, 0, 296)
aimDistanceLabel.BackgroundTransparency = 1
aimDistanceLabel.TextColor3 = uiColors.muted
aimDistanceLabel.Font = Enum.Font.Gotham
aimDistanceLabel.TextSize = 11
aimDistanceLabel.Text = string.format("Aim Range: %d studs", aimDistance)
aimDistanceLabel.TextXAlignment = Enum.TextXAlignment.Left
aimDistanceLabel.Parent = mainFrame

local aimDistanceSlider = Instance.new("Frame")
aimDistanceSlider.Size = UDim2.new(0.8, 0, 0, 6)
aimDistanceSlider.Position = UDim2.new(0.1, 0, 0, 329)
aimDistanceSlider.BackgroundColor3 = uiColors.track
aimDistanceSlider.BorderSizePixel = 0
aimDistanceSlider.Active = true
aimDistanceSlider.Parent = mainFrame

local sliderCorner = Instance.new("UICorner")
sliderCorner.CornerRadius = UDim.new(1, 0)
sliderCorner.Parent = aimDistanceSlider

local aimDistanceKnob = Instance.new("TextButton")
aimDistanceKnob.Size = UDim2.new(0, 14, 0, 14)
aimDistanceKnob.AnchorPoint = Vector2.new(0.5, 0.5)
aimDistanceKnob.Position = UDim2.new((aimDistance - minAimDistance) / (maxAimDistance - minAimDistance), 0, 0.5, 0)
aimDistanceKnob.BackgroundColor3 = uiColors.accent
aimDistanceKnob.BorderSizePixel = 0
aimDistanceKnob.Text = ""
aimDistanceKnob.Parent = aimDistanceSlider

local knobCorner = Instance.new("UICorner")
knobCorner.CornerRadius = UDim.new(1, 0)
knobCorner.Parent = aimDistanceKnob

local draggingAimDistance = false

local function updateAimDistanceSlider(inputX)
    local sliderPercent = math.clamp((inputX - aimDistanceSlider.AbsolutePosition.X) / aimDistanceSlider.AbsoluteSize.X, 0, 1)
    aimDistance = math.floor(minAimDistance + sliderPercent * (maxAimDistance - minAimDistance) + 0.5)
    aimDistanceKnob.Position = UDim2.new(sliderPercent, 0, 0.5, 0)
    aimDistanceLabel.Text = string.format("Aim Range: %d studs", aimDistance)
end

aimDistanceKnob.MouseButton1Down:Connect(function()
    mainFrame.Draggable = false
    draggingAimDistance = true
end)

aimDistanceSlider.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        mainFrame.Draggable = false
        draggingAimDistance = true
        updateAimDistanceSlider(input.Position.X)
    end
end)

userInputService.InputChanged:Connect(function(input)
    if draggingAimDistance and input.UserInputType == Enum.UserInputType.MouseMovement then
        updateAimDistanceSlider(input.Position.X)
    end
end)

userInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 and draggingAimDistance then
        mainFrame.Draggable = false
        draggingAimDistance = false
    end
end)

local sightScanAfter = 0
local activeSightObject = nil

-- Status
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 0, 20)
statusLabel.Position = UDim2.new(0, 0, 0, 360)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = uiColors.muted
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 11
statusLabel.Text = "Hold RMB: head lock | R-Ctrl: ON/OFF"
statusLabel.Parent = mainFrame

local weaponNameLabel = Instance.new("TextLabel")
weaponNameLabel.Name = "ActiveSightWeapon"
weaponNameLabel.Position = UDim2.fromOffset(24, 126)
weaponNameLabel.Size = UDim2.new(1, -48, 0, 22)
weaponNameLabel.BackgroundTransparency = 1
weaponNameLabel.TextXAlignment = Enum.TextXAlignment.Left
weaponNameLabel.TextColor3 = uiColors.text
weaponNameLabel.Font = Enum.Font.GothamBold
weaponNameLabel.TextSize = 12
weaponNameLabel.Parent = mainFrame

local yOffsetLabel = Instance.new("TextLabel")
yOffsetLabel.Name = "SightYOffsetValue"
yOffsetLabel.Position = UDim2.fromOffset(24, 34)
yOffsetLabel.Size = UDim2.new(1, -48, 0, 18)
yOffsetLabel.BackgroundTransparency = 1
yOffsetLabel.TextXAlignment = Enum.TextXAlignment.Left
yOffsetLabel.TextColor3 = uiColors.muted
yOffsetLabel.Font = Enum.Font.Gotham
yOffsetLabel.TextSize = 10
yOffsetLabel.Parent = mainFrame

local function selectedSightWeapon()
    if manualSightIndex > 0 then return weaponSightProfiles[manualSightIndex].id end
    -- Make Y calibration usable as soon as the menu opens, even before ADS.
    -- A named equipped Tool takes precedence; an unknown Tool must not be
    -- mistaken for an AKM. Empty hands start with the AKM fallback profile.
    local character = player.Character
    if character and type(character.GetChildren) == "function" then
        for _, object in ipairs(character:GetChildren()) do
            if object:IsA("Tool") then return identifySightWeapon(object.Name) end
        end
    end
    return displayedWeaponId or "AKM"
end
local autoWeaponButton
local autoWeaponSwitchRefresh
local function refreshSightCalibration()
    local id = selectedSightWeapon()
    weaponNameLabel.Text = "Weapon: " .. (id or "not detected")
        .. (manualSightIndex > 0
            and string.format(" (%d/%d)", manualSightIndex, #weaponSightProfiles)
            or " (auto)")
    local profile = id and profileById[id]
    local adjustment = id and sightAdjustments[id]
    yOffsetLabel.Text = string.format("Y = %d",
        (profile and profile.y or 0) + (adjustment and adjustment.y or 0))
    if autoWeaponButton then
        local automatic = manualSightIndex == 0
        autoWeaponButton.Text = "    AUTO WEAPON"
        if autoWeaponSwitchRefresh then autoWeaponSwitchRefresh(automatic,false) end
        autoWeaponButton.BackgroundColor3 = automatic and uiColors.selected or uiColors.card
    end
end

local function makeSightButton(name, label, xScale, yOffset, widthScale, onClick)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Position = UDim2.new(xScale, 3, 0, yOffset)
    button.Size = UDim2.new(widthScale, -6, 0, 31)
    button.BackgroundColor3 = uiColors.card
    button.BackgroundTransparency = uiGlass.card
    button.TextColor3 = uiColors.text
    button.Font = Enum.Font.GothamBold
    button.TextSize = 12
    button.Text = label
    button.Parent = mainFrame
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 5)
    corner.Parent = button
    button.MouseButton1Click:Connect(onClick)
    return button
end
local sightControls = {}
local function addSightButton(...) table.insert(sightControls, makeSightButton(...)) end
addSightButton("PreviousSightWeapon", "Previous weapon", 0.04, 152, 0.46, function()
    manualSightIndex = manualSightIndex == 0 and lastManualSightIndex
        or (manualSightIndex - 2 + #weaponSightProfiles) % #weaponSightProfiles + 1
    lastManualSightIndex = manualSightIndex
    activeSightObject, sightScanAfter = nil, 0
    refreshSightCalibration()
end)
addSightButton("NextSightWeapon", "Next weapon", 0.5, 152, 0.46, function()
    manualSightIndex = manualSightIndex == 0 and lastManualSightIndex
        or manualSightIndex % #weaponSightProfiles + 1
    lastManualSightIndex = manualSightIndex
    activeSightObject, sightScanAfter = nil, 0
    refreshSightCalibration()
end)
local function adjustSight(delta)
    local id = selectedSightWeapon()
    if not id then return end
    local adjustment = sightAdjustments[id] or {y = 0}
    adjustment.y = math.clamp(adjustment.y + delta, -100, 100)
    sightAdjustments[id] = adjustment
    saveSightCalibration()
    refreshSightCalibration()
end
addSightButton("SightUp", "Y -2", 0.04, 54, 0.46, function() adjustSight(-2) end)
addSightButton("SightDown", "Y +2", 0.5, 54, 0.46, function() adjustSight(2) end)
addSightButton("ResetSightCalibration", "Reset Y", 0.04, 90, 0.92, function()
    local id = selectedSightWeapon()
    if id then sightAdjustments[id] = nil; saveSightCalibration() end
    refreshSightCalibration()
end)
autoWeaponButton = Instance.new("TextButton")
autoWeaponButton.Name = "AutoWeaponToggle"
autoWeaponButton.Position = UDim2.new(0.04, 3, 0, 190)
autoWeaponButton.Size = UDim2.new(0.92, -6, 0, 31)
autoWeaponButton.BackgroundColor3 = uiColors.selected
autoWeaponButton.BackgroundTransparency = uiGlass.selected
autoWeaponButton.TextColor3 = uiColors.text
autoWeaponButton.Font = Enum.Font.GothamBold
autoWeaponButton.TextSize = 12
autoWeaponButton.TextXAlignment = Enum.TextXAlignment.Left
autoWeaponButton.Text = "    AUTO WEAPON"
autoWeaponButton.AutoButtonColor = false
autoWeaponButton.Parent = mainFrame
local autoWeaponCorner = Instance.new("UICorner")
autoWeaponCorner.CornerRadius = UDim.new(0, 5)
autoWeaponCorner.Parent = autoWeaponButton
autoWeaponSwitchRefresh = addOrangeSwitch(autoWeaponButton,55,5,44,21,64)
autoWeaponSwitchRefresh(manualSightIndex == 0,false)
autoWeaponButton.MouseButton1Click:Connect(function()
    if manualSightIndex == 0 then
        manualSightIndex = profileIndexById[selectedSightWeapon()] or lastManualSightIndex
        lastManualSightIndex = manualSightIndex
    else
        lastManualSightIndex = manualSightIndex
        manualSightIndex = 0
    end
    activeSightObject, sightScanAfter = nil, 0
    refreshSightCalibration()
end)
refreshSightCalibration()

-- Keep the master toggle visible and scroll the extended weapon controls.
local controlsScroll = Instance.new("ScrollingFrame")
controlsScroll.Name = "AimbotControlsScroll"
controlsScroll.Position = UDim2.fromOffset(0, 32)
controlsScroll.Size = UDim2.new(1, 0, 1, -32)
controlsScroll.BackgroundTransparency = 1
controlsScroll.BorderSizePixel = 0
controlsScroll.ScrollBarThickness = 4
controlsScroll.CanvasSize = UDim2.fromOffset(0, 366)
controlsScroll.ZIndex = 63
controlsScroll.Parent = mainFrame
for _, control in ipairs({yOffsetLabel, fovSizeLabel, fovSlider,
    aimDistanceLabel, aimDistanceSlider, statusLabel,
    weaponNameLabel, autoWeaponButton}) do
    local position = control.Position
    control.Parent = controlsScroll
    control.Position = UDim2.new(position.X.Scale, position.X.Offset,
        position.Y.Scale, position.Y.Offset - 32)
end
for _, button in ipairs(sightControls) do
    local position = button.Position
    button.Parent = controlsScroll
    button.Position = UDim2.new(position.X.Scale, position.X.Offset,
        position.Y.Scale, position.Y.Offset - 32)
end

-- FOV circle follows the cursor in menus and the weapon sight while aiming.
local fovCircle = Instance.new("Frame")
fovCircle.Size = UDim2.new(0, FOVCircle * 2, 0, FOVCircle * 2)
fovCircle.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
fovCircle.BackgroundTransparency = 0.92
fovCircle.BorderSizePixel = 0
fovCircle.Visible = false
fovCircle.Parent = screenGui

local circleCorner = Instance.new("UICorner")
circleCorner.CornerRadius = UDim.new(1, 0)
circleCorner.Parent = fovCircle

-- Update the FOV circle position
local function updateFOVPosition(sightPoint)
    local camera = workspace.CurrentCamera
    local aiming = aimbotEnabled and not menuOpen
        and userInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
    if aiming and not sightPoint then
        fovCircle.Visible = false
        return
    end
    fovCircle.Visible = showFOV and aimbotEnabled
    local aimPoint = aiming and sightPoint or userInputService:GetMouseLocation()
    fovCircle.Position = UDim2.fromOffset(aimPoint.X - FOVCircle, aimPoint.Y - FOVCircle)
end

-- Update the FOV circle size
local function updateFOVSize()
    fovCircle.Size = UDim2.new(0, FOVCircle * 2, 0, FOVCircle * 2)
    updateFOVPosition()
    fovSizeLabel.Text = "FOV Size: " .. FOVCircle
    local progress = (FOVCircle - minFOVSize) / (maxFOVSize - minFOVSize)
    fovSliderFill.Size = UDim2.fromScale(progress, 1)
    fovSliderKnob.Position = UDim2.new(progress, 0, 0.5, 0)
end

-- Exact head center, with no offset toward the neck or torso
local function getHeadPosition(character)
    local head = character:FindFirstChild("Head")
    if head and head:IsA("BasePart") then
        return head.Position
    end
    return nil
end

-- Only named aim/reticle markers in the first-person camera model are treated
-- as weapon sights. A generic Scope/Sight part or muzzle is not a reliable
-- aiming point. Recheck the candidates when the camera or weapon is replaced.
local sightNames = {
    aimpoint = 100, sightpoint = 100, opticcenter = 100,
    opticpoint = 100, adspoint = 100, reticlepoint = 100,
    aimattachment = 90, sightattachment = 90,
    scopeaim = 90, ironsightpoint = 90, reticle = 80,
}
local sightCandidates = {}
local hudSightCandidates = {}
local hudSightScanAfter = 0
local sightCamera = nil
local sightSourceText = nil
local sightWeaponId = nil
local sightWasAiming = false
local hudWeaponId = nil
local hudWeaponLabel = nil
local hudScanAfter = 0
local hudWeaponWalkRoot = nil
local hudWeaponWalkQueue = {}
local hudWeaponWalkIndex = 1
local hudWeaponScanLabel, hudWeaponScanId, hudWeaponScanY = nil, nil, -math.huge
local function guiItemVisible(object, root)
    local ancestor = object
    while ancestor and ancestor ~= root do
        if ancestor:IsA("GuiObject") and not ancestor.Visible then return false end
        if ancestor:IsA("ScreenGui") and not ancestor.Enabled then return false end
        ancestor = ancestor.Parent
    end
    return ancestor == root
end
local function guiViewportPoint(object)
    local position, size = object.AbsolutePosition, object.AbsoluteSize
    if not position or not size or size.X <= 0 or size.Y <= 0 then return nil end
    local point = Vector2.new(position.X + size.X * 0.5,
        position.Y + size.Y * 0.5)
    local ancestor = object.Parent
    while ancestor and not ancestor:IsA("ScreenGui") do ancestor = ancestor.Parent end
    if ancestor and not ancestor.IgnoreGuiInset then
        local ok, inset = pcall(function()
            return game:GetService("GuiService"):GetGuiInset()
        end)
        if ok and inset then point = point + inset end
    end
    return point
end
local function stepHudWeaponLabels(playerGui, camera)
    if not playerGui or type(playerGui.GetChildren) ~= "function" then return true end
    if hudWeaponWalkRoot ~= playerGui or hudWeaponWalkIndex > #hudWeaponWalkQueue then
        hudWeaponWalkRoot = playerGui
        hudWeaponWalkQueue = {playerGui}
        hudWeaponWalkIndex = 1
        hudWeaponScanLabel, hudWeaponScanId, hudWeaponScanY = nil, nil, -math.huge
    end
    -- A Roblox GUI can have thousands of objects. Traverse a fixed number per
    -- frame instead of building its entire descendant array on the ADS frame.
    local visited = 0
    while hudWeaponWalkIndex <= #hudWeaponWalkQueue and visited < 32 do
        local object = hudWeaponWalkQueue[hudWeaponWalkIndex]
        hudWeaponWalkIndex = hudWeaponWalkIndex + 1
        visited = visited + 1
        for _, child in ipairs(object:GetChildren()) do
            hudWeaponWalkQueue[#hudWeaponWalkQueue + 1] = child
        end
        if (object:IsA("TextLabel") or object:IsA("TextButton"))
            and guiItemVisible(object, playerGui)
            and type(object.Text) == "string" and #object.Text < 80 then
            local id = identifySightWeapon(object.Text)
            local pos = object.AbsolutePosition
            local view = camera and camera.ViewportSize
            if id and pos and pos.Y > hudWeaponScanY
                and (not view or (pos.X >= 0 and pos.X < view.X * 0.55
                    and pos.Y > view.Y * 0.5 and pos.Y < view.Y)) then
                hudWeaponScanId, hudWeaponScanLabel, hudWeaponScanY = id, object, pos.Y
            end
        end
    end
    if hudWeaponWalkIndex <= #hudWeaponWalkQueue then return false end
    hudWeaponLabel, hudWeaponId = hudWeaponScanLabel, hudWeaponScanId
    hudWeaponWalkQueue = {}
    hudWeaponScanLabel, hudWeaponScanId = nil, nil
    hudScanAfter = 0.8
    return true
end
local function getActiveSightWeapon(dt)
    if manualSightIndex > 0 then return weaponSightProfiles[manualSightIndex].id, false end
    local character = player.Character
    if character and type(character.GetChildren) == "function" then
        for _, object in ipairs(character:GetChildren()) do
            if object:IsA("Tool") then
                -- An unfamiliar newly equipped Tool must invalidate the
                -- previous gun's cached HUD label immediately.
                return identifySightWeapon(object.Name), false
            end
        end
    end
    hudScanAfter = hudScanAfter - (dt or 1 / 60)
    local playerGui = player:FindFirstChildOfClass("PlayerGui")
    if hudWeaponWalkRoot ~= playerGui then hudScanAfter = 0 end
    local cachedId = nil
    if hudWeaponLabel and hudWeaponLabel.Parent and playerGui
        and guiItemVisible(hudWeaponLabel, playerGui) then
        -- The game can update one label's Text on weapon switch. Reading it
        -- avoids walking the whole PlayerGui on every aiming frame.
        hudWeaponId = identifySightWeapon(hudWeaponLabel.Text)
        cachedId = hudWeaponId
    else
        hudWeaponLabel, hudWeaponId = nil, nil
    end
    if hudScanAfter <= 0 then
        stepHudWeaponLabels(playerGui, workspace.CurrentCamera)
    end
    -- The second value distinguishes an empty hand from an unknown Tool.
    -- Only an empty hand may use the AKM estimate as the default profile.
    return (hudWeaponLabel and hudWeaponId) or cachedId or hudWeaponScanId, true
end

local function sightMatchesWeapon(object, weaponId, camera)
    local ancestor = object.Parent
    local hasModel = false
    while ancestor and ancestor ~= camera do
        if ancestor:IsA("Model") then
            hasModel = true
            local modelWeapon = identifySightWeapon(ancestor.Name)
            if modelWeapon and weaponId and modelWeapon ~= weaponId then return false end
        end
        ancestor = ancestor.Parent
    end
    return ancestor == camera and hasModel
end

local sightWalkCamera, sightWalkWeapon = nil, nil
local sightWalkQueue, sightWalkIndex = {}, 1
local function scanWeaponSights(camera, weaponId)
    if type(camera.GetChildren) ~= "function" then return true end
    if sightWalkCamera ~= camera or sightWalkWeapon ~= weaponId
        or sightWalkIndex > #sightWalkQueue then
        sightWalkCamera, sightWalkWeapon = camera, weaponId
        sightWalkQueue, sightWalkIndex = {camera}, 1
        sightCandidates = {}
    end
    local visited = 0
    while sightWalkIndex <= #sightWalkQueue and visited < 40 do
        local object = sightWalkQueue[sightWalkIndex]
        sightWalkIndex = sightWalkIndex + 1
        visited = visited + 1
        for _, child in ipairs(object:GetChildren()) do
            sightWalkQueue[#sightWalkQueue + 1] = child
        end
        local name = string.lower(object.Name):gsub("[^%w]", "")
        local score = sightNames[name]
        if score and object:IsA("Attachment")
            and sightMatchesWeapon(object, weaponId, camera) then
            table.insert(sightCandidates, {object = object, score = score})
        end
    end
    if sightWalkIndex <= #sightWalkQueue then return false end
    sightWalkQueue = {}
    table.sort(sightCandidates, function(a, b) return a.score > b.score end)
    return true
end
local guiSightNames = {
    scoperef = true, scopereticle = true, weaponreticle = true,
    opticreticle = true, aimreticle = true, sightsdot = true,
}
local hudSightWalkRoot = nil
local hudSightWalkQueue, hudSightWalkIndex = {}, 1
local hudSightPending = {}
local function scanHudSights(playerGui)
    if not playerGui or type(playerGui.GetChildren) ~= "function" then return true end
    if hudSightWalkRoot ~= playerGui or hudSightWalkIndex > #hudSightWalkQueue then
        hudSightWalkRoot = playerGui
        hudSightWalkQueue, hudSightWalkIndex = {playerGui}, 1
        hudSightPending = {}
    end
    local visited = 0
    while hudSightWalkIndex <= #hudSightWalkQueue and visited < 32 do
        local object = hudSightWalkQueue[hudSightWalkIndex]
        hudSightWalkIndex = hudSightWalkIndex + 1
        visited = visited + 1
        for _, child in ipairs(object:GetChildren()) do
            hudSightWalkQueue[#hudSightWalkQueue + 1] = child
        end
        local name = string.lower(object.Name):gsub("[^%w]", "")
        if guiSightNames[name] and object:IsA("GuiObject") then
            table.insert(hudSightPending, object)
        end
    end
    if hudSightWalkIndex <= #hudSightWalkQueue then return false end
    hudSightCandidates = hudSightPending
    hudSightWalkQueue = {}
    return true
end

local function getWeaponSight(camera, dt)
    local center = camera.ViewportSize * 0.5
    local weaponId, noEquippedTool = getActiveSightWeapon(dt)
    local fallbackId = not weaponId and noEquippedTool and "AKM" or nil
    local profileId = weaponId or fallbackId
    if displayedWeaponId ~= profileId then
        displayedWeaponId = profileId
        refreshSightCalibration()
    end
    sightScanAfter = sightScanAfter - (dt or 1 / 60)
    hudSightScanAfter = hudSightScanAfter - (dt or 1 / 60)
    if sightCamera ~= camera or sightWeaponId ~= weaponId then
        sightCamera = camera
        sightWeaponId = weaponId
        activeSightObject = nil
        sightScanAfter = 0
        hudSightScanAfter = 0
    end
    if not sightWasAiming then
        activeSightObject = nil
        sightWasAiming = true
        sightScanAfter = 0
        hudSightScanAfter = 0
    end
    if sightScanAfter <= 0 and not activeSightObject then
        if scanWeaponSights(camera, weaponId) then sightScanAfter = 0.8 end
    end
    local adjustment = profileId and sightAdjustments[profileId]
    local screenScale = camera.ViewportSize.Y / 1080
    local function addCalibration(point)
        if not adjustment then return point end
        return point + Vector2.new(0, adjustment.y * screenScale)
    end
    local function videoSight()
        local profile = profileId and profileById[profileId]
        if not profile then return nil, nil, weaponId, false end
        return center + Vector2.new(
            profile.x * screenScale,
            (profile.y + (adjustment and adjustment.y or 0)) * screenScale),
            "video estimate: " .. profileId, profileId, false
    end
    local maxOffset = math.min(camera.ViewportSize.X, camera.ViewportSize.Y) * 0.28
    local function projectedSight(object)
        if object.Parent and object:IsDescendantOf(camera)
            and sightMatchesWeapon(object, weaponId, camera) then
            local position = object.WorldPosition
            local depth = (position - camera.CFrame.Position).Magnitude
            if depth > 0.04 and depth < 20 then
                local point, onScreen = camera:WorldToViewportPoint(position)
                if onScreen and point.Z > 0
                    and point.X == point.X and point.Y == point.Y then
                    local projected = Vector2.new(point.X, point.Y)
                    local offset = (projected - center).Magnitude
                    if offset < maxOffset then
                        return projected, offset
                    end
                end
            end
        end
        return nil, nil
    end
    if activeSightObject then
        local projected = projectedSight(activeSightObject)
        if projected then
            return addCalibration(projected), "3D: " .. activeSightObject.Name,
                weaponId, true
        end
        activeSightObject = nil
    end
    -- Acquire on the very first ADS frame even if the user already fires.
    local best, rank = nil, -math.huge
    local restRadius = math.min(camera.ViewportSize.X, camera.ViewportSize.Y) * 0.10
    for _, candidate in ipairs(sightCandidates) do
        local _, offset = projectedSight(candidate.object)
        if offset and offset < restRadius then
            local candidateRank = candidate.score - offset / restRadius * 20
            if candidateRank > rank then
                best, rank = candidate.object, candidateRank
            end
        end
    end
    if best then
        activeSightObject = best
        local projected = projectedSight(best)
        if projected then
            return addCalibration(projected), "3D: " .. best.Name, weaponId, true
        end
    end

    -- Some optics expose a dedicated on-screen reticle instead of an
    -- attachment. Generic HUD crosshairs are deliberately excluded.
    local playerGui = player:FindFirstChildOfClass("PlayerGui")
    if hudSightScanAfter <= 0 then
        if scanHudSights(playerGui) then hudSightScanAfter = 0.8 end
    end
    if playerGui then
        for _, object in ipairs(hudSightCandidates) do
            if object.Parent and guiItemVisible(object, playerGui) then
                local point = guiViewportPoint(object)
                if point and (point - center).Magnitude < maxOffset then
                    return addCalibration(point), "HUD: " .. object.Name,
                        weaponId, true
                end
            end
        end
    end

    return videoSight()
end

-- Use the same viewport-space point for target acquisition and final aim.
local function getTargetInFOV(camera, reticle)
    if not camera then return nil end
    local nearest, bestDistance = nil, FOVCircle
    for _, other in ipairs(players:GetPlayers()) do
        if other ~= player and other.Character then
            local humanoid = other.Character:FindFirstChildOfClass("Humanoid")
            local head = getHeadPosition(other.Character)
            if humanoid and humanoid.Health > 0 and head
                and (head-camera.CFrame.Position).Magnitude <= aimDistance then
                local point, onScreen = camera:WorldToViewportPoint(head)
                if onScreen and point.Z > 0 then
                    local distance = (Vector2.new(point.X, point.Y)-reticle).Magnitude
                    if distance < bestDistance then
                        nearest, bestDistance = other, distance
                    end
                end
            end
        end
    end
    return nearest
end

local function validHead(other)
    if not other or not other.Character or other == player then return nil end
    local camera = workspace.CurrentCamera
    local humanoid = other.Character:FindFirstChildOfClass("Humanoid")
    local head = getHeadPosition(other.Character)
    if not camera or not humanoid or humanoid.Health <= 0 or not head then return nil end
    if (head-camera.CFrame.Position).Magnitude > aimDistance then return nil end
    return head
end

-- Let the game move its own camera with the character. Send only relative
-- mouse input to aim; assigning Camera.CFrame here freezes custom AR2 cameras.
-- Predict a few frames of relative movement so walking sideways does not
-- leave the aim behind a small head.
local aimBindName = "AR2_HeadLock_" .. tostring(player.UserId)
local moveAimMouse = type(mousemoverel) == "function" and mousemoverel
    or (type(syn) == "table" and type(syn.mousemoverel) == "function" and syn.mousemoverel)
local aimInputFailed = false
local wasFiring = false
local firingTime = 0
local lastAimCameraPosition = nil
local aimCameraVelocity = nil
if not moveAimMouse then
    statusLabel.Text = "Aimbot needs mousemoverel in this executor."
end
dashboardGui.Destroying:Connect(function()
    runService:UnbindFromRenderStep(aimBindName)
    if screenGui.Parent then screenGui:Destroy() end
end)
local function aimFrame(dt)
    local holdingRmb = userInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
    if showFOV and aimbotEnabled and not menuOpen
        and not holdingRmb then
        updateFOVPosition()
    end
    if not aimbotEnabled or menuOpen
        or not holdingRmb then
        if aimbotEnabled and not menuOpen and not holdingRmb then
            -- Fill the small HUD caches while idle so RMB need not begin with
            -- a search through the entire game GUI.
            local idleId, noEquippedTool = getActiveSightWeapon(dt)
            local shownId = idleId or (noEquippedTool and "AKM" or nil)
            if displayedWeaponId ~= shownId then
                displayedWeaponId = shownId
                refreshSightCalibration()
            end
            hudSightScanAfter = hudSightScanAfter - (dt or 1 / 60)
            if hudSightScanAfter <= 0 then
                local idleGui = player:FindFirstChildOfClass("PlayerGui")
                if scanHudSights(idleGui) then hudSightScanAfter = 0.8 end
            end
        end
        if menuOpen then fovCircle.Visible = false end
        sightWasAiming = false
        activeSightObject = nil
        target = nil
        wasFiring = false
        firingTime = 0
        lastAimCameraPosition = nil
        aimCameraVelocity = nil
        return
    end
    if not moveAimMouse or aimInputFailed then
        return
    end
    local camera = workspace.CurrentCamera
    if not camera then
        wasFiring = false
        firingTime = 0
        lastAimCameraPosition = nil
        aimCameraVelocity = nil
        return
    end
    local frameTime = math.clamp(dt or 1 / 60, 1 / 240, 0.05)
    local reticle, sightName, weaponId = getWeaponSight(camera, frameTime)
    if showFOV then updateFOVPosition(reticle) end
    local sightText = sightName and ("Sight: " .. sightName)
        or ("Sight unavailable" .. (weaponId and (": " .. weaponId) or ": unknown gun"))
    if sightText ~= sightSourceText then
        sightSourceText = sightText
        statusLabel.Text = sightText
    end
    if not reticle then
        target = nil
        wasFiring = false
        firingTime = 0
        lastAimCameraPosition = nil
        aimCameraVelocity = nil
        return
    end
    local cameraPosition = camera.CFrame.Position
    if lastAimCameraPosition then
        local measuredVelocity = (cameraPosition - lastAimCameraPosition) * (1 / frameTime)
        if measuredVelocity.Magnitude <= 80 then
            aimCameraVelocity = (aimCameraVelocity or cameraPosition * 0) * 0.55
                + measuredVelocity * 0.45
        else
            aimCameraVelocity = cameraPosition * 0
        end
    end
    lastAimCameraPosition = cameraPosition
    local head = validHead(target)
    if head then
        local currentPoint, currentOnScreen = camera:WorldToViewportPoint(head)
        if not currentOnScreen or currentPoint.Z <= 0 then
            target, head = nil, nil
        end
    end
    if not head then
        target = getTargetInFOV(camera, reticle)
        head = validHead(target)
    end
    if not head then
        wasFiring = false
        firingTime = 0
        return
    end
    local headPart = target.Character:FindFirstChild("Head")
    local targetVelocity = headPart and headPart.AssemblyLinearVelocity
    if not targetVelocity or targetVelocity.Magnitude > 80 then
        targetVelocity = head * 0
    end
    local targetHumanoid = target.Character:FindFirstChildOfClass("Humanoid")
    local targetAirborne = (targetHumanoid
        and targetHumanoid.FloorMaterial == Enum.Material.Air)
        or math.abs(targetVelocity.Y) >= 6
    -- Aim a little ahead of a moving head. Keep the correction bounded in
    -- screen space so a nearby sprinting target does not pull aim too far.
    local leadSeconds = math.clamp(
        0.05 + (head - cameraPosition).Magnitude / 9000, 0.055, 0.11
    )
    local predictedHead = head
        + (targetVelocity - (aimCameraVelocity or cameraPosition * 0)) * leadSeconds
    local point, onScreen = camera:WorldToViewportPoint(predictedHead)
    local directPoint, directOnScreen = camera:WorldToViewportPoint(head)
    if not onScreen or point.Z <= 0 then
        point, onScreen = directPoint, directOnScreen
    end
    if not onScreen or point.Z <= 0 then
        target = nil
        wasFiring = false
        firingTime = 0
        return
    end
    local screenScale = camera.ViewportSize.Y / 1080
    if directOnScreen and directPoint.Z > 0 then
        point = Vector2.new(
            directPoint.X + math.clamp(point.X - directPoint.X,
                -18 * screenScale, 18 * screenScale),
            directPoint.Y + math.clamp(point.Y - directPoint.Y,
                -(targetAirborne and 16 or 6) * screenScale,
                (targetAirborne and 16 or 6) * screenScale)
        )
    end
    local firing = userInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
    -- If the selected marker moves with the real reticle, its projection
    -- reflects that movement. Static video estimates cannot measure recoil;
    -- a generic recoil number would be wrong for most guns.
    firingTime = firing and (wasFiring and firingTime + frameTime or 0) or 0
    wasFiring = firing
    local dx = point.X - reticle.X
    local dy = point.Y - reticle.Y
    -- At a long distance even a few screen pixels can miss the head. Keep a
    -- subpixel dead zone, with a capped response to avoid violent jumps.
    if math.abs(dx) < 0.35 then dx = 0 end
    if math.abs(dy) < 0.35 then dy = 0 end
    if dx == 0 and dy == 0 then return end
    local horizontalGain = firing and 0.7 or 0.55
    local verticalGain = targetAirborne and (firing and 0.95 or 0.9)
        or (firing and 0.72 or 0.55)
    local verticalLimit = targetAirborne and 48 or 28
    local ok = pcall(moveAimMouse,
        math.clamp(dx * horizontalGain, -50, 50),
        math.clamp(dy * verticalGain, -verticalLimit, verticalLimit))
    if not ok then
        aimInputFailed = true
        statusLabel.Text = "This executor cannot send aim mouse input."
    end
end
local aimLoopBroken = false
runService:BindToRenderStep(aimBindName, Enum.RenderPriority.Last.Value + 1, function(dt)
    if aimLoopBroken then return end
    local ok, err = pcall(aimFrame, dt)
    if not ok then
        aimLoopBroken = true
        statusLabel.Text = "Aimbot stopped; check F9."
        warn("[AR2 SCRIPTS] Aimbot loop stopped: " .. tostring(err))
    end
end)

local function setAimEnabled(value)
    if value and not aimbotEnabled then
        activeSightObject, sightScanAfter = nil, 0
        controlsScroll.CanvasPosition = Vector2.new(0, 0)
        refreshSightCalibration()
    end
    aimbotEnabled = value
    if not value then target = nil end
    centerRingEnabled = value
    centerRing.Visible = value and not menuOpen
    fovCircle.Visible = value and showFOV
    setButton(aimbotButton,value)
    updateStatus()
end
local _, refreshAimbotFeature = makeFeatureSwitch(
    aimbotSettingsMenu,mainFrame,"AIMBOT",
    function() return aimbotEnabled end,setAimEnabled
)

local draggingFOV = nil
local function setFOVFromPointer(pointerX)
    local width = fovSlider.AbsoluteSize.X
    if width <= 0 then return end
    local progress = math.clamp((pointerX - fovSlider.AbsolutePosition.X) / width, 0, 1)
    FOVCircle = math.floor(minFOVSize + progress * (maxFOVSize - minFOVSize) + 0.5)
    updateFOVSize()
end
local function beginFOVDrag(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        draggingFOV = input
        setFOVFromPointer(input.Position.X)
    end
end
fovSlider.InputBegan:Connect(beginFOVDrag)
fovSliderKnob.InputBegan:Connect(beginFOVDrag)
userInputService.InputChanged:Connect(function(input)
    if draggingFOV and (input == draggingFOV
        or draggingFOV.UserInputType == Enum.UserInputType.MouseButton1
            and input.UserInputType == Enum.UserInputType.MouseMovement) then
        setFOVFromPointer(input.Position.X)
    end
end)
userInputService.InputEnded:Connect(function(input)
    if input == draggingFOV
        or draggingFOV and draggingFOV.UserInputType == Enum.UserInputType.MouseButton1
            and input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingFOV = nil
    end
end)

-- Keyboard shortcuts
userInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.RightControl then
        setAimEnabled(not aimbotEnabled)
        refreshAimbotFeature()
    end
end)

-- Initialize the FOV circle
updateFOVSize()

print("Head Aimbot loaded!")
print("Target stays locked to the head while RMB is held")
print("Right Control - Toggle Aimbot")

-- Keep the aimbot settings controls above their panel background.
for _, widget in ipairs(mainFrame:GetDescendants()) do
    if widget:IsA("GuiObject") then
        widget.ZIndex = 63
    end
end

headshotControls = {
    isEnabled = function()
        return aimbotEnabled
    end,
    toggle = function()
        setAimEnabled(not aimbotEnabled)
        refreshAimbotFeature()
    end,
}

updateStatus()
end

initializeHeadshotPanel()
