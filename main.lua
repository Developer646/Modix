-- KRUTAX MODIX | ESP + HEALTH + AIMBOT + TRACERS + SPEEDHACK

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LP = Players.LocalPlayer

-- ================= SETTINGS =================
local ESP_ON = true
local AIM_ON = false
local TRACER_ON = true
local AIM_FOV = 150

-- SPEEDHACK
local SPEED_ON = false
local SPEED_VALUE = 26
local NORMAL_SPEED = 16

local TEAM_COLOR = Color3.fromRGB(0,120,255)
local ENEMY_COLOR = Color3.fromRGB(255,60,60)

-- ================= UI =================
local gui = Instance.new("ScreenGui", LP.PlayerGui)
gui.Name = "KrutaxModix"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.fromOffset(220,215)
frame.Position = UDim2.fromScale(0.05,0.3)
frame.BackgroundColor3 = Color3.fromRGB(25,25,30)
frame.Active, frame.Draggable = true, true
frame.BorderSizePixel = 0
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,12)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.fromOffset(220,32)
title.BackgroundTransparency = 1
title.Text = "KRUTAX MODIX"
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.TextColor3 = Color3.fromRGB(180,120,255)

local function mkBtn(text,y)
	local b = Instance.new("TextButton", frame)
	b.Size = UDim2.fromOffset(180,32)
	b.Position = UDim2.fromOffset(20,y)
	b.Text = text
	b.Font = Enum.Font.Gotham
	b.TextSize = 15
	b.TextColor3 = Color3.new(1,1,1)
	b.BackgroundColor3 = Color3.fromRGB(40,40,50)
	b.BorderSizePixel = 0
	Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)
	b.MouseEnter:Connect(function()
		b.BackgroundColor3 = Color3.fromRGB(140,90,255)
	end)
	b.MouseLeave:Connect(function()
		b.BackgroundColor3 = Color3.fromRGB(40,40,50)
	end)
	return b
end

local espBtn = mkBtn("ESP: ON",45)
local aimBtn = mkBtn("Aimbot: OFF",85)
local tracerBtn = mkBtn("Tracers: ON",125)
local speedBtn = mkBtn("Speedhack: OFF",165)

espBtn.MouseButton1Click:Connect(function()
	ESP_ON = not ESP_ON
	espBtn.Text = "ESP: "..(ESP_ON and "ON" or "OFF")
end)

aimBtn.MouseButton1Click:Connect(function()
	AIM_ON = not AIM_ON
	aimBtn.Text = "Aimbot: "..(AIM_ON and "ON" or "OFF")
end)

tracerBtn.MouseButton1Click:Connect(function()
	TRACER_ON = not TRACER_ON
	tracerBtn.Text = "Tracers: "..(TRACER_ON and "ON" or "OFF")
end)

speedBtn.MouseButton1Click:Connect(function()
	SPEED_ON = not SPEED_ON
	speedBtn.Text = "Speedhack: "..(SPEED_ON and "ON" or "OFF")
end)

UIS.InputBegan:Connect(function(i,gp)
	if not gp and i.KeyCode == Enum.KeyCode.RightShift then
		frame.Visible = not frame.Visible
	end
end)

-- ================= SPEED =================
local function applySpeed()
	local c = LP.Character
	if c and c:FindFirstChild("Humanoid") then
		c.Humanoid.WalkSpeed = SPEED_ON and SPEED_VALUE or NORMAL_SPEED
	end
end
LP.CharacterAdded:Connect(function()
	task.wait(0.3)
	applySpeed()
end)

-- ================= FOV =================
local FOV = Drawing.new("Circle")
FOV.Thickness = 2
FOV.Filled = false
FOV.Color = Color3.new(1,1,1)

-- ================= TEAM CHECK =================
local function isEnemy(player, model)
	if player and player ~= LP then
		if LP.Team and player.Team then
			return player.Team ~= LP.Team
		end
		return true
	end
	if model and model:FindFirstChild("Team") and LP.Team then
		return model.Team.Value ~= LP.Team.Name
	end
	return true
end

-- ================= ESP =================
local espCache = {}

local function createESP(model, player)
	local hrp = model:FindFirstChild("HumanoidRootPart")
	local hum = model:FindFirstChild("Humanoid")
	if not hrp or not hum then return end
	if espCache[model] then espCache[model]:Destroy() end

	local gui = Instance.new("BillboardGui")
	gui.Size = UDim2.fromOffset(40,70)
	gui.StudsOffset = Vector3.new(0,2,0)
	gui.AlwaysOnTop = true
	gui.Adornee = hrp
	gui.Parent = model

	local col = isEnemy(player,model) and ENEMY_COLOR or TEAM_COLOR

	local function line(p,s)
		local f = Instance.new("Frame", gui)
		f.Position = p
		f.Size = s
		f.BorderSizePixel = 0
		f.BackgroundColor3 = col
	end

	line(UDim2.fromScale(0,0),UDim2.fromScale(1,0.03))
	line(UDim2.fromScale(0,0.97),UDim2.fromScale(1,0.03))
	line(UDim2.fromScale(0,0),UDim2.fromScale(0.03,1))
	line(UDim2.fromScale(0.97,0),UDim2.fromScale(0.03,1))

	espCache[model] = gui
end

-- Hook players
local function hookPlayer(p)
	if p == LP then return end
	if p.Character then createESP(p.Character,p) end
	p.CharacterAdded:Connect(function(c)
		task.wait(0.2)
		createESP(c,p)
	end)
end
for _,p in pairs(Players:GetPlayers()) do hookPlayer(p) end
Players.PlayerAdded:Connect(hookPlayer)

-- Hook bots
local function hookBots()
	for _,m in pairs(workspace:GetChildren()) do
		if m:IsA("Model") and m:FindFirstChild("Humanoid") and not Players:GetPlayerFromCharacter(m) then
			createESP(m,nil)
		end
	end
end
hookBots()
workspace.ChildAdded:Connect(function()
	task.wait(0.2)
	hookBots()
end)

-- ================= TRACERS =================
local tracerCache = {}

local function getTracer(model)
	if tracerCache[model] then return tracerCache[model] end
	local l = Drawing.new("Line")
	l.Thickness = 2
	l.Transparency = 1
	tracerCache[model] = l
	return l
end

local function removeTracer(model)
	if tracerCache[model] then
		tracerCache[model]:Remove()
		tracerCache[model] = nil
	end
end

-- ================= AIMBOT =================
local function getTarget()
	local center = Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y/2)
	local best,dist

	local function check(model,player)
		local head = model:FindFirstChild("Head")
		local hum = model:FindFirstChild("Humanoid")
		if not head or not hum or hum.Health<=0 then return end
		if not isEnemy(player,model) then return end

		local pos,on = Camera:WorldToViewportPoint(head.Position)
		if not on then return end
		local d = (Vector2.new(pos.X,pos.Y)-center).Magnitude
		if d <= AIM_FOV and (not dist or d<dist) then
			dist=d
			best=head
		end
	end

	for _,p in pairs(Players:GetPlayers()) do
		if p~=LP and p.Character then check(p.Character,p) end
	end
	for _,m in pairs(workspace:GetChildren()) do
		if m:IsA("Model") and m:FindFirstChild("Humanoid") and not Players:GetPlayerFromCharacter(m) then
			check(m,nil)
		end
	end
	return best
end

-- ================= LOOP =================
RunService.RenderStepped:Connect(function()
	applySpeed()

	FOV.Position = Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y/2)
	FOV.Radius = AIM_FOV
	FOV.Visible = AIM_ON

	for model,gui in pairs(espCache) do
		if gui then gui.Enabled = ESP_ON end

		-- Tracers
		if TRACER_ON then
			local hrp = model:FindFirstChild("HumanoidRootPart")
			if hrp then
				local pos,on = Camera:WorldToViewportPoint(hrp.Position)
				if on then
					local t = getTracer(model)
					t.From = Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y)
					t.To = Vector2.new(pos.X,pos.Y)
					t.Color = isEnemy(Players:GetPlayerFromCharacter(model),model)
						and ENEMY_COLOR or TEAM_COLOR
					t.Visible = true
				else
					removeTracer(model)
				end
			end
		else
			removeTracer(model)
		end
	end

	if AIM_ON then
		local t = getTarget()
		if t then
			Camera.CFrame = CFrame.new(Camera.CFrame.Position,t.Position)
		end
	end
end)




