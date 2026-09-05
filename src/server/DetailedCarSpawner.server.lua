local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local DetailedCarConfig = require(ReplicatedStorage.Shared.DetailedCarConfig)

local function getTemplate()
	local instance = ReplicatedStorage
	for _, name in ipairs(DetailedCarConfig.TEMPLATE_PATH) do
		instance = instance:WaitForChild(name)
	end
	return instance
end

local function createDetailedCar(spawnPosition, carName)
	local template = getTemplate()
	local car = template:Clone()
	car.Name = carName

	local chassis = car:FindFirstChild("body")
	chassis.Name = "Chassis"
	chassis.CanCollide = true
	chassis.CustomPhysicalProperties = PhysicalProperties.new(
		DetailedCarConfig.CHASSIS_DENSITY,
		DetailedCarConfig.CHASSIS_FRICTION,
		DetailedCarConfig.CHASSIS_ELASTICITY
	)
	car.PrimaryPart = chassis

	car:PivotTo(CFrame.new(spawnPosition))
	car.Parent = workspace

	-- Capture each other part's position relative to the chassis now, right
	-- after PivotTo, while everything still has the template's original
	-- relative arrangement -- avoids hand-transcribing offsets by hand.
	local wheelNames = { "front left wheel", "front right wheel", "rear left wheel", "rear right wheel" }
	local wheels = {}
	for _, name in ipairs(wheelNames) do
		local wheel = car:FindFirstChild(name)
		local offset = chassis.CFrame:ToObjectSpace(wheel.CFrame)
		wheel.CanCollide = false
		wheel.Massless = true
		wheel.Anchored = true
		table.insert(wheels, { part = wheel, offset = offset })
	end

	local cosmeticNames = { "windshield", "spoiler", "exhaust pipes" }
	for _, name in ipairs(cosmeticNames) do
		local part = car:FindFirstChild(name)
		part.CanCollide = false
		part.Massless = true
		local weld = Instance.new("WeldConstraint")
		weld.Part0 = part
		weld.Part1 = chassis
		weld.Parent = part
	end

	-- An invisible, extra-heavy block welded low on the chassis, same trick
	-- as the parking-lot cars' Ballast: pulls the combined center of mass
	-- down so the car resists tipping, without changing how it looks.
	local ballast = Instance.new("Part")
	ballast.Name = "Ballast"
	ballast.Size = Vector3.new(chassis.Size.X * 0.5, 1, chassis.Size.Z * 0.5)
	ballast.CFrame = chassis.CFrame * CFrame.new(0, -chassis.Size.Y / 2, 0)
	ballast.Transparency = 1
	ballast.CanCollide = false
	ballast.CustomPhysicalProperties = PhysicalProperties.new(DetailedCarConfig.BALLAST_DENSITY, 0.3, 0)
	ballast.Parent = car

	local ballastWeld = Instance.new("WeldConstraint")
	ballastWeld.Part0 = ballast
	ballastWeld.Part1 = chassis
	ballastWeld.Parent = ballast

	local seat = Instance.new("VehicleSeat")
	seat.Name = "DriverSeat"
	seat.Size = DetailedCarConfig.SEAT_SIZE
	seat.CFrame = chassis.CFrame * CFrame.new(DetailedCarConfig.SEAT_OFFSET)
	seat.Parent = car

	local seatWeld = Instance.new("WeldConstraint")
	seatWeld.Part0 = seat
	seatWeld.Part1 = chassis
	seatWeld.Parent = seat

	return chassis, seat, wheels
end

local function moveTowards(current, target, maxDelta)
	if math.abs(target - current) <= maxDelta then
		return target
	end
	return current + math.sign(target - current) * maxDelta
end

local function attachDetailedDriving(chassis, seat, wheels)
	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.MaxForce = Vector3.new(math.huge, 0, math.huge)
	bodyVelocity.Velocity = Vector3.new()
	bodyVelocity.Parent = chassis

	local bodyGyro = Instance.new("BodyGyro")
	bodyGyro.MaxTorque = Vector3.new(0, math.huge, 0)
	bodyGyro.P = 3000
	bodyGyro.CFrame = chassis.CFrame
	bodyGyro.Parent = chassis

	local currentSpeed = 0
	local wheelSpinAngle = 0
	-- This mesh's local axes don't match Roblox's usual -Z-forward part
	-- convention (see DetailedCarConfig's comment), so forward and the
	-- wheel spin axis are read from config instead of assumed.
	local localForward = DetailedCarConfig.LOCAL_FORWARD

	RunService.Heartbeat:Connect(function(deltaTime)
		local upDot = chassis.CFrame.UpVector:Dot(Vector3.new(0, 1, 0))
		local isFlipped = upDot < DetailedCarConfig.FLIP_UP_DOT_THRESHOLD

		local throttle = if isFlipped then 0 else seat.Throttle
		local steer = if isFlipped then 0 else seat.Steer

		local targetSpeed = throttle * DetailedCarConfig.MAX_SPEED

		local rate
		if targetSpeed == 0 then
			rate = DetailedCarConfig.COAST_DECELERATION
		elseif currentSpeed == 0 or (targetSpeed > 0) == (currentSpeed > 0) then
			rate = DetailedCarConfig.ACCELERATION
		else
			rate = DetailedCarConfig.BRAKE_DECELERATION
		end

		currentSpeed = moveTowards(currentSpeed, targetSpeed, rate * deltaTime)
		if math.abs(currentSpeed) < DetailedCarConfig.STOP_THRESHOLD and targetSpeed == 0 then
			currentSpeed = 0
		end

		bodyVelocity.Velocity = chassis.CFrame:VectorToWorldSpace(localForward) * currentSpeed

		local speedRatio = currentSpeed / DetailedCarConfig.MAX_SPEED
		local turnAngle = -steer * DetailedCarConfig.TURN_SPEED * deltaTime * speedRatio
		bodyGyro.CFrame = bodyGyro.CFrame * CFrame.Angles(0, turnAngle, 0)

		local angularVelocity = chassis.AssemblyAngularVelocity
		if angularVelocity.Magnitude > DetailedCarConfig.MAX_ANGULAR_SPEED then
			chassis.AssemblyAngularVelocity = angularVelocity.Unit * DetailedCarConfig.MAX_ANGULAR_SPEED
		end

		wheelSpinAngle += (currentSpeed / DetailedCarConfig.WHEEL_RADIUS) * deltaTime
		local spin = CFrame.Angles(0, 0, wheelSpinAngle)
		for _, wheelData in ipairs(wheels) do
			wheelData.part.CFrame = chassis.CFrame * wheelData.offset * spin
		end
	end)
end

local chassis, seat, wheels = createDetailedCar(DetailedCarConfig.SPAWN_POSITION, "DetailedSportsCar")
attachDetailedDriving(chassis, seat, wheels)
