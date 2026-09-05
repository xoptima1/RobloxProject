local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local CarConfig = require(ReplicatedStorage.Shared.CarConfig)

local function createBodyPanel(name, size, offset, color, car, chassis)
	local panel = Instance.new("Part")
	panel.Name = name
	panel.Size = size
	panel.CFrame = chassis.CFrame * CFrame.new(offset)
	panel.Color = color
	panel.TopSurface = Enum.SurfaceType.Smooth
	panel.BottomSurface = Enum.SurfaceType.Smooth
	panel.Parent = car

	local weld = Instance.new("WeldConstraint")
	weld.Part0 = panel
	weld.Part1 = chassis
	weld.Parent = panel

	return panel
end

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
	chassis.Color = CarConfig.BODY_COLOR
	chassis.TopSurface = Enum.SurfaceType.Smooth
	chassis.BottomSurface = Enum.SurfaceType.Smooth
	chassis.CustomPhysicalProperties = PhysicalProperties.new(
		CarConfig.CHASSIS_DENSITY,
		CarConfig.CHASSIS_FRICTION,
		CarConfig.CHASSIS_ELASTICITY
	)
	chassis.Parent = car

	car.PrimaryPart = chassis

	-- An invisible, extra-heavy block welded low on the chassis. Welded parts
	-- combine into one physical assembly, so this pulls the car's effective
	-- center of mass down without changing how it looks -- the same trick
	-- real cars use (heavy engine/battery low down) to resist tipping over.
	local ballast = Instance.new("Part")
	ballast.Name = "Ballast"
	ballast.Size = CarConfig.BALLAST_SIZE
	ballast.CFrame = chassis.CFrame * CFrame.new(0, -CarConfig.CHASSIS_SIZE.Y / 2, 0)
	ballast.Transparency = 1
	ballast.CanCollide = false
	ballast.CustomPhysicalProperties = PhysicalProperties.new(CarConfig.BALLAST_DENSITY, 0.3, 0)
	ballast.Parent = car

	local ballastWeld = Instance.new("WeldConstraint")
	ballastWeld.Part0 = ballast
	ballastWeld.Part1 = chassis
	ballastWeld.Parent = ballast

	-- A low hood up front and a low trunk out back, leaving an open cockpit
	-- in the middle for the seat -- a roadster-style silhouette instead of
	-- one flat slab, built from the same primitive Part shapes.
	local hoodOffsetZ = -(CarConfig.CHASSIS_SIZE.Z / 2 - CarConfig.HOOD_SIZE.Z / 2)
	local trunkOffsetZ = CarConfig.CHASSIS_SIZE.Z / 2 - CarConfig.TRUNK_SIZE.Z / 2
	local panelOffsetY = CarConfig.CHASSIS_SIZE.Y / 2 + CarConfig.HOOD_SIZE.Y / 2

	createBodyPanel(
		"Hood",
		CarConfig.HOOD_SIZE,
		Vector3.new(0, panelOffsetY, hoodOffsetZ),
		CarConfig.ACCENT_COLOR,
		car,
		chassis
	)
	createBodyPanel(
		"Trunk",
		CarConfig.TRUNK_SIZE,
		Vector3.new(0, panelOffsetY, trunkOffsetZ),
		CarConfig.ACCENT_COLOR,
		car,
		chassis
	)

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
		-- UpVector is the direction the chassis's own "up" currently points in
		-- world space. Dotted with world-up (0,1,0), it's 1 when upright, 0
		-- on its side, and negative once past onto its roof -- a cheap way
		-- to tell how tipped over the car is without checking exact angles.
		local upDot = chassis.CFrame.UpVector:Dot(Vector3.new(0, 1, 0))
		local isFlipped = upDot < CarConfig.FLIP_UP_DOT_THRESHOLD

		-- While flipped, ignore the seat's input entirely so the car can't
		-- drive itself back over -- it just coasts to a stop until something
		-- (a collision, or the player) rights it again.
		local throttle = if isFlipped then 0 else seat.Throttle
		local steer = if isFlipped then 0 else seat.Steer

		local targetSpeed = throttle * CarConfig.MAX_SPEED

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
		local turnAngle = -steer * CarConfig.TURN_SPEED * deltaTime * speedRatio
		bodyGyro.CFrame = bodyGyro.CFrame * CFrame.Angles(0, turnAngle, 0)

		-- Cap how fast the car can tumble. A hard collision can otherwise dump a
		-- huge amount of spin into the chassis in one physics step, which is what
		-- sends it cartwheeling high into the air -- clamping the magnitude of its
		-- angular velocity limits that without touching normal driving physics.
		local angularVelocity = chassis.AssemblyAngularVelocity
		if angularVelocity.Magnitude > CarConfig.MAX_ANGULAR_SPEED then
			chassis.AssemblyAngularVelocity = angularVelocity.Unit * CarConfig.MAX_ANGULAR_SPEED
		end
	end)
end

local chassis, seat = createCar(CarConfig.SPAWN_POSITION)
attachDriving(chassis, seat)
