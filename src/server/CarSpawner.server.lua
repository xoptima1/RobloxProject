local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local CarConfig = require(ReplicatedStorage.Shared.CarConfig)

local function createWheel(name, offset, car, chassis)
	local wheel = Instance.new("Part")
	wheel.Name = name
	wheel.Shape = Enum.PartType.Cylinder
	wheel.Size = CarConfig.WHEEL_SIZE
	wheel.CFrame = chassis.CFrame * CFrame.new(offset)
	wheel.Color = Color3.fromRGB(35, 35, 35)
	wheel.TopSurface = Enum.SurfaceType.Smooth
	wheel.BottomSurface = Enum.SurfaceType.Smooth
	wheel.Parent = car

	local weld = Instance.new("WeldConstraint")
	weld.Part0 = wheel
	weld.Part1 = chassis
	weld.Parent = wheel
end

local function createCar(spawnPosition)
	local car = Instance.new("Model")
	car.Name = "TestCar"

	local chassis = Instance.new("Part")
	chassis.Name = "Chassis"
	chassis.Size = CarConfig.CHASSIS_SIZE
	chassis.CFrame = CFrame.new(spawnPosition)
	chassis.Color = Color3.fromRGB(200, 30, 30)
	chassis.TopSurface = Enum.SurfaceType.Smooth
	chassis.BottomSurface = Enum.SurfaceType.Smooth
	chassis.Parent = car

	car.PrimaryPart = chassis

	-- Wheel cylinders default to spinning around their local X axis, which already
	-- lines up with the chassis's left/right axis, so no extra rotation is needed.
	local sideOffset = CarConfig.CHASSIS_SIZE.X / 2 + CarConfig.WHEEL_SIZE.X / 2
	local frontBackOffset = CarConfig.CHASSIS_SIZE.Z / 2 - CarConfig.WHEEL_SIZE.Y / 2
	local heightOffset = -CarConfig.CHASSIS_SIZE.Y / 2

	createWheel("WheelFrontLeft", Vector3.new(-sideOffset, heightOffset, -frontBackOffset), car, chassis)
	createWheel("WheelFrontRight", Vector3.new(sideOffset, heightOffset, -frontBackOffset), car, chassis)
	createWheel("WheelBackLeft", Vector3.new(-sideOffset, heightOffset, frontBackOffset), car, chassis)
	createWheel("WheelBackRight", Vector3.new(sideOffset, heightOffset, frontBackOffset), car, chassis)

	local seat = Instance.new("VehicleSeat")
	seat.Name = "DriverSeat"
	seat.Size = Vector3.new(4, 1, 4)
	seat.CFrame = chassis.CFrame * CFrame.new(0, CarConfig.CHASSIS_SIZE.Y / 2 + 0.5, 0)
	seat.Parent = car

	local seatWeld = Instance.new("WeldConstraint")
	seatWeld.Part0 = seat
	seatWeld.Part1 = chassis
	seatWeld.Parent = seat

	car.Parent = workspace

	return chassis, seat
end

local function moveTowards(current, target, maxDelta)
	if math.abs(target - current) <= maxDelta then
		return target
	end
	return current + math.sign(target - current) * maxDelta
end

local function attachDriving(chassis, seat)
	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.MaxForce = Vector3.new(math.huge, 0, math.huge)
	bodyVelocity.Velocity = Vector3.new()
	bodyVelocity.Parent = chassis

	local bodyGyro = Instance.new("BodyGyro")
	bodyGyro.MaxTorque = Vector3.new(0, math.huge, 0)
	bodyGyro.P = 3000
	bodyGyro.CFrame = chassis.CFrame
	bodyGyro.Parent = chassis

	-- Signed forward speed along the chassis's LookVector. Kept separate from
	-- the chassis's actual velocity so we can ease it towards the target
	-- speed instead of snapping BodyVelocity straight to the throttle input.
	local currentSpeed = 0

	RunService.Heartbeat:Connect(function(deltaTime)
		local targetSpeed = seat.Throttle * CarConfig.MAX_SPEED

		local rate
		if targetSpeed == 0 then
			rate = CarConfig.COAST_DECELERATION
		elseif currentSpeed == 0 or (targetSpeed > 0) == (currentSpeed > 0) then
			rate = CarConfig.ACCELERATION
		else
			rate = CarConfig.BRAKE_DECELERATION
		end

		currentSpeed = moveTowards(currentSpeed, targetSpeed, rate * deltaTime)
		if math.abs(currentSpeed) < CarConfig.STOP_THRESHOLD and targetSpeed == 0 then
			currentSpeed = 0
		end

		bodyVelocity.Velocity = chassis.CFrame.LookVector * currentSpeed

		-- Scale turning by how fast (and which direction) the car is moving, so it
		-- can't spin in place, turns tighter at speed, and reverses naturally when
		-- backing up. Steer is -1..1 (A..D); flip the sign so positive Steer turns right.
		local speedRatio = currentSpeed / CarConfig.MAX_SPEED
		local turnAngle = -seat.Steer * CarConfig.TURN_SPEED * deltaTime * speedRatio
		bodyGyro.CFrame = bodyGyro.CFrame * CFrame.Angles(0, turnAngle, 0)
	end)
end

local chassis, seat = createCar(CarConfig.SPAWN_POSITION)
attachDriving(chassis, seat)
