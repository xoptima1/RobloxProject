local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local FlyConfig = require(ReplicatedStorage.Shared.FlyConfig)

local player = Players.LocalPlayer

local ascending = false
local descending = false

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end
	if input.KeyCode == Enum.KeyCode.Space then
		ascending = true
	elseif input.KeyCode == Enum.KeyCode.LeftShift then
		descending = true
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.Space then
		ascending = false
	elseif input.KeyCode == Enum.KeyCode.LeftShift then
		descending = false
	end
end)

-- Roblox already turns WASD + camera direction into humanoid.MoveDirection
-- (a world-space vector) for normal walking, so reusing it here means we
-- don't have to reimplement camera-relative input by hand -- we just add
-- Space/Shift for the vertical axis and apply the result as raw velocity
-- instead of letting Humanoid walk with it.
local function attachFlight(character)
	local humanoid = character:WaitForChild("Humanoid")
	local rootPart = character:WaitForChild("HumanoidRootPart")

	-- MaxForce on all three axes (not just X/Z, like the car) is what fully
	-- cancels gravity here -- Y needs to be overridden too so the character
	-- can hover in place instead of sinking.
	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
	bodyVelocity.Velocity = Vector3.new()
	bodyVelocity.Parent = rootPart

	local bodyGyro = Instance.new("BodyGyro")
	bodyGyro.MaxTorque = Vector3.new(0, math.huge, 0)
	bodyGyro.P = 3000
	bodyGyro.CFrame = rootPart.CFrame
	bodyGyro.Parent = rootPart

	local connection
	connection = RunService.Heartbeat:Connect(function()
		if not character.Parent or humanoid.Health <= 0 then
			connection:Disconnect()
			bodyVelocity:Destroy()
			bodyGyro:Destroy()
			return
		end

		local horizontal = humanoid.MoveDirection
		local vertical = (ascending and 1 or 0) - (descending and 1 or 0)
		local moveVector = horizontal + Vector3.new(0, vertical, 0)

		if moveVector.Magnitude > 0.01 then
			bodyVelocity.Velocity = moveVector.Unit * FlyConfig.FLY_SPEED
		else
			bodyVelocity.Velocity = Vector3.new()
		end

		if horizontal.Magnitude > 0.01 then
			bodyGyro.CFrame = CFrame.lookAt(rootPart.Position, rootPart.Position + horizontal)
		end
	end)
end

if player.Character then
	attachFlight(player.Character)
end
player.CharacterAdded:Connect(attachFlight)
