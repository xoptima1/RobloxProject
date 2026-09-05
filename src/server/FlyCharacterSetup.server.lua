local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local FlyConfig = require(ReplicatedStorage.Shared.FlyConfig)

-- Every currently-flying character, so the Heartbeat loop below can flap
-- all of their wings each frame. {torso, leftWing, rightWing, flapPhase}
local flies = {}

-- Wings aren't welded because they need to rotate independently of the
-- torso for the flap animation (same reasoning as the car's Anchored,
-- script-driven wheels) -- rigidly attaching them would just fight a
-- per-frame CFrame override.
local function createWing(character, xSign)
	local wing = Instance.new("Part")
	wing.Name = xSign > 0 and "WingRight" or "WingLeft"
	wing.Size = FlyConfig.WING_SIZE
	wing.Color = FlyConfig.WING_COLOR
	wing.Transparency = FlyConfig.WING_TRANSPARENCY
	wing.Material = Enum.Material.Glass
	wing.CanCollide = false
	wing.Massless = true
	wing.Anchored = true
	wing.Parent = character
	return wing
end

local function setupFly(character)
	local humanoid = character:WaitForChild("Humanoid")
	local torso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
	if not torso then
		return
	end

	character:ScaleTo(FlyConfig.SCALE)

	-- Shirt/Pants are separate texture-overlay objects (not BaseParts), and
	-- hats/hair are Accessory models -- none of them are touched by
	-- recoloring BaseParts below, so a plain Color change alone still left
	-- the avatar's normal clothes and hair fully visible on top.
	for _, child in ipairs(character:GetChildren()) do
		if child:IsA("Shirt") or child:IsA("Pants") or child:IsA("Accessory") then
			child:Destroy()
		end
	end

	for _, part in ipairs(character:GetDescendants()) do
		if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
			part.Color = FlyConfig.BODY_COLOR
			part.Material = Enum.Material.Metal
		elseif part:IsA("Decal") then
			-- Hides the default cartoon face -- a plain dark head reads
			-- more like an insect without it.
			part.Transparency = 1
		end
	end

	-- WalkSpeed = 0 stops the Humanoid from also trying to move the
	-- character on its own; FlightController (client-side) still reads
	-- MoveDirection for input even with WalkSpeed at 0, so this only
	-- disables Humanoid's own movement, not input detection. AutoRotate
	-- is off because FlightController's own BodyGyro handles facing.
	humanoid.WalkSpeed = 0
	humanoid.AutoRotate = false

	local leftWing = createWing(character, -1)
	local rightWing = createWing(character, 1)

	table.insert(flies, {
		torso = torso,
		leftWing = leftWing,
		rightWing = rightWing,
		flapPhase = 0,
	})
end

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(setupFly)
	if player.Character then
		setupFly(player.Character)
	end
end)

RunService.Heartbeat:Connect(function(deltaTime)
	for i = #flies, 1, -1 do
		local fly = flies[i]
		if not fly.torso.Parent then
			flies[i] = flies[#flies]
			flies[#flies] = nil
			continue
		end

		fly.flapPhase += FlyConfig.WING_FLAP_SPEED * deltaTime
		local flapAngle = math.sin(fly.flapPhase) * FlyConfig.WING_FLAP_ANGLE

		fly.leftWing.CFrame = fly.torso.CFrame
			* CFrame.new(-FlyConfig.WING_OFFSET.X, FlyConfig.WING_OFFSET.Y, FlyConfig.WING_OFFSET.Z)
			* CFrame.Angles(0, 0, flapAngle)
		fly.rightWing.CFrame = fly.torso.CFrame
			* CFrame.new(FlyConfig.WING_OFFSET.X, FlyConfig.WING_OFFSET.Y, FlyConfig.WING_OFFSET.Z)
			* CFrame.Angles(0, 0, -flapAngle)
	end
end)
