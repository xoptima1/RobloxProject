local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local CarConfig = require(ReplicatedStorage.Shared.CarConfig)

-- Builds one purely cosmetic part welded to the chassis: no collision and
-- no mass, so styling detail (mirrors, spoiler, exhaust, glass, etc.) can
-- never snag on the world or throw off the car's physics -- only the
-- Chassis and Ballast parts in createCar are solid/heavy.
local function createDetail(options)
	-- className lets a detail be a WedgePart (for the sloped glass) instead
	-- of a plain Part -- WedgePart is its own Instance class in Roblox, not
	-- a Part with a "wedge" Shape, so it has to be chosen at creation time.
	local part = Instance.new(options.className or "Part")
	part.Name = options.name
	if options.shape then
		part.Shape = options.shape
	end
	part.Size = options.size
	part.CFrame = options.chassis.CFrame * CFrame.new(options.offset) * (options.rotation or CFrame.new())
	part.Color = options.color
	part.Material = options.material or Enum.Material.SmoothPlastic
	part.Transparency = options.transparency or 0
	part.CanCollide = false
	part.Massless = true
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = options.car

	if options.anchored then
		-- Anchored parts ignore gravity/physics entirely and only move when
		-- script explicitly sets their CFrame -- used for the wheels, which
		-- we reposition and spin by hand every frame instead of welding.
		part.Anchored = true
	else
		local weld = Instance.new("WeldConstraint")
		weld.Part0 = part
		weld.Part1 = options.chassis
		weld.Parent = part
	end

	return part
end

local function addStyling(car, chassis, bodyColor)
	local halfX = CarConfig.CHASSIS_SIZE.X / 2
	local halfZ = CarConfig.CHASSIS_SIZE.Z / 2

	-- Hood and trunk: a low panel up front and out back, leaving an open
	-- cockpit in the middle for the seat -- a roadster-style silhouette
	-- instead of one flat slab.
	local hoodOffsetZ = -(halfZ - CarConfig.HOOD_SIZE.Z / 2)
	local trunkOffsetZ = halfZ - CarConfig.TRUNK_SIZE.Z / 2
	local panelOffsetY = CarConfig.CHASSIS_SIZE.Y / 2 + CarConfig.HOOD_SIZE.Y / 2

	createDetail({
		name = "Hood",
		size = CarConfig.HOOD_SIZE,
		offset = Vector3.new(0, panelOffsetY, hoodOffsetZ),
		color = CarConfig.ACCENT_COLOR,
		car = car,
		chassis = chassis,
	})
	createDetail({
		name = "Trunk",
		size = CarConfig.TRUNK_SIZE,
		offset = Vector3.new(0, panelOffsetY, trunkOffsetZ),
		color = CarConfig.ACCENT_COLOR,
		car = car,
		chassis = chassis,
	})

	-- Roof and glass, forming an enclosed-looking cabin around the seat.
	-- Everything here is CanCollide = false so it never blocks the player
	-- from walking up to and sitting in the seat underneath it.
	local roofBottomY = CarConfig.ROOF_OFFSET_Y - CarConfig.ROOF_SIZE.Y / 2
	local roofFrontZ = CarConfig.ROOF_OFFSET_Z - CarConfig.ROOF_SIZE.Z / 2
	local roofBackZ = CarConfig.ROOF_OFFSET_Z + CarConfig.ROOF_SIZE.Z / 2

	createDetail({
		name = "Roof",
		size = CarConfig.ROOF_SIZE,
		offset = Vector3.new(0, CarConfig.ROOF_OFFSET_Y, CarConfig.ROOF_OFFSET_Z),
		color = CarConfig.ACCENT_COLOR,
		car = car,
		chassis = chassis,
	})
	-- WedgePart's tall vertical face is on its local -Z side, tapering down
	-- to a point on local +Z. The windshield needs its tall edge toward the
	-- roof (chassis +Z from here) and its point toward the hood (chassis -Z),
	-- which is backwards from the default, so it's rotated 180 degrees. The
	-- rear window wants tall-toward-roof (chassis -Z from there), which the
	-- default orientation already gives us, so it's left unrotated. (If
	-- either one looks like it's sloping the wrong way in Studio, that's the
	-- part to flip -- swap its rotation between "180 degrees" and "none.")
	createDetail({
		name = "Windshield",
		className = "WedgePart",
		size = CarConfig.WINDSHIELD_SIZE,
		offset = CarConfig.WINDSHIELD_OFFSET,
		rotation = CFrame.Angles(0, math.rad(180), 0),
		color = CarConfig.GLASS_COLOR,
		material = Enum.Material.Glass,
		transparency = 0.4,
		car = car,
		chassis = chassis,
	})
	createDetail({
		name = "RearWindow",
		className = "WedgePart",
		size = CarConfig.REAR_WINDOW_SIZE,
		offset = CarConfig.REAR_WINDOW_OFFSET,
		color = CarConfig.GLASS_COLOR,
		material = Enum.Material.Glass,
		transparency = 0.4,
		car = car,
		chassis = chassis,
	})

	-- Four corner pillars connect the roof down to the body, framing the glass.
	local pillarX = halfX - 0.15
	local pillarY = roofBottomY - CarConfig.PILLAR_SIZE.Y / 2

	local pillarOffsets = {
		PillarFrontLeft = Vector3.new(-pillarX, pillarY, roofFrontZ),
		PillarFrontRight = Vector3.new(pillarX, pillarY, roofFrontZ),
		PillarBackLeft = Vector3.new(-pillarX, pillarY, roofBackZ),
		PillarBackRight = Vector3.new(pillarX, pillarY, roofBackZ),
	}
	for pillarName, offset in pairs(pillarOffsets) do
		createDetail({
			name = pillarName,
			size = CarConfig.PILLAR_SIZE,
			offset = offset,
			color = CarConfig.ACCENT_COLOR,
			car = car,
			chassis = chassis,
		})
	end

	-- Bumpers, grille, and license plates.
	createDetail({
		name = "FrontBumper",
		size = CarConfig.BUMPER_SIZE,
		offset = CarConfig.FRONT_BUMPER_OFFSET,
		color = CarConfig.CHROME_COLOR,
		material = Enum.Material.Metal,
		car = car,
		chassis = chassis,
	})
	createDetail({
		name = "RearBumper",
		size = CarConfig.BUMPER_SIZE,
		offset = CarConfig.REAR_BUMPER_OFFSET,
		color = CarConfig.CHROME_COLOR,
		material = Enum.Material.Metal,
		car = car,
		chassis = chassis,
	})
	createDetail({
		name = "Grille",
		size = CarConfig.GRILLE_SIZE,
		offset = CarConfig.GRILLE_OFFSET,
		color = CarConfig.ACCENT_COLOR,
		car = car,
		chassis = chassis,
	})
	createDetail({
		name = "FrontPlate",
		size = CarConfig.LICENSE_PLATE_SIZE,
		offset = CarConfig.FRONT_PLATE_OFFSET,
		color = CarConfig.PLATE_COLOR,
		car = car,
		chassis = chassis,
	})
	createDetail({
		name = "RearPlate",
		size = CarConfig.LICENSE_PLATE_SIZE,
		offset = CarConfig.REAR_PLATE_OFFSET,
		color = CarConfig.PLATE_COLOR,
		car = car,
		chassis = chassis,
	})

	-- Headlights and taillights. Neon material makes them glow even without
	-- an actual light source -- a cheap way to sell "the lights are on."
	createDetail({
		name = "HeadlightLeft",
		size = CarConfig.HEADLIGHT_SIZE,
		offset = Vector3.new(-CarConfig.HEADLIGHT_X, CarConfig.HEADLIGHT_OFFSET_Y, CarConfig.HEADLIGHT_OFFSET_Z),
		color = CarConfig.HEADLIGHT_COLOR,
		material = Enum.Material.Neon,
		car = car,
		chassis = chassis,
	})
	createDetail({
		name = "HeadlightRight",
		size = CarConfig.HEADLIGHT_SIZE,
		offset = Vector3.new(CarConfig.HEADLIGHT_X, CarConfig.HEADLIGHT_OFFSET_Y, CarConfig.HEADLIGHT_OFFSET_Z),
		color = CarConfig.HEADLIGHT_COLOR,
		material = Enum.Material.Neon,
		car = car,
		chassis = chassis,
	})
	createDetail({
		name = "TaillightLeft",
		size = CarConfig.TAILLIGHT_SIZE,
		offset = Vector3.new(-CarConfig.HEADLIGHT_X, CarConfig.TAILLIGHT_OFFSET_Y, CarConfig.TAILLIGHT_OFFSET_Z),
		color = CarConfig.TAILLIGHT_COLOR,
		material = Enum.Material.Neon,
		car = car,
		chassis = chassis,
	})
	createDetail({
		name = "TaillightRight",
		size = CarConfig.TAILLIGHT_SIZE,
		offset = Vector3.new(CarConfig.HEADLIGHT_X, CarConfig.TAILLIGHT_OFFSET_Y, CarConfig.TAILLIGHT_OFFSET_Z),
		color = CarConfig.TAILLIGHT_COLOR,
		material = Enum.Material.Neon,
		car = car,
		chassis = chassis,
	})

	-- Side mirrors.
	createDetail({
		name = "MirrorLeft",
		size = CarConfig.MIRROR_SIZE,
		offset = Vector3.new(-CarConfig.MIRROR_OFFSET.X, CarConfig.MIRROR_OFFSET.Y, CarConfig.MIRROR_OFFSET.Z),
		color = CarConfig.ACCENT_COLOR,
		car = car,
		chassis = chassis,
	})
	createDetail({
		name = "MirrorRight",
		size = CarConfig.MIRROR_SIZE,
		offset = CarConfig.MIRROR_OFFSET,
		color = CarConfig.ACCENT_COLOR,
		car = car,
		chassis = chassis,
	})

	-- Rear spoiler: two struts holding up a wing.
	createDetail({
		name = "SpoilerStrutLeft",
		size = CarConfig.SPOILER_STRUT_SIZE,
		offset = Vector3.new(-CarConfig.SPOILER_STRUT_X, CarConfig.SPOILER_STRUT_OFFSET_Y, CarConfig.SPOILER_OFFSET_Z),
		color = CarConfig.ACCENT_COLOR,
		car = car,
		chassis = chassis,
	})
	createDetail({
		name = "SpoilerStrutRight",
		size = CarConfig.SPOILER_STRUT_SIZE,
		offset = Vector3.new(CarConfig.SPOILER_STRUT_X, CarConfig.SPOILER_STRUT_OFFSET_Y, CarConfig.SPOILER_OFFSET_Z),
		color = CarConfig.ACCENT_COLOR,
		car = car,
		chassis = chassis,
	})
	createDetail({
		name = "SpoilerWing",
		size = CarConfig.SPOILER_WING_SIZE,
		offset = Vector3.new(0, CarConfig.SPOILER_WING_OFFSET_Y, CarConfig.SPOILER_OFFSET_Z),
		color = bodyColor,
		car = car,
		chassis = chassis,
	})

	-- Exhaust pipes. Cylinders default to spinning around local X, so
	-- rotating 90 degrees around Y swings that axis to point along Z
	-- (backward) instead of sideways.
	local exhaustRotation = CFrame.Angles(0, math.rad(90), 0)
	createDetail({
		name = "ExhaustLeft",
		shape = Enum.PartType.Cylinder,
		size = CarConfig.EXHAUST_SIZE,
		offset = Vector3.new(-CarConfig.EXHAUST_X, CarConfig.EXHAUST_OFFSET_Y, CarConfig.EXHAUST_OFFSET_Z),
		rotation = exhaustRotation,
		color = CarConfig.CHROME_COLOR,
		material = Enum.Material.Metal,
		car = car,
		chassis = chassis,
	})
	createDetail({
		name = "ExhaustRight",
		shape = Enum.PartType.Cylinder,
		size = CarConfig.EXHAUST_SIZE,
		offset = Vector3.new(CarConfig.EXHAUST_X, CarConfig.EXHAUST_OFFSET_Y, CarConfig.EXHAUST_OFFSET_Z),
		rotation = exhaustRotation,
		color = CarConfig.CHROME_COLOR,
		material = Enum.Material.Metal,
		car = car,
		chassis = chassis,
	})

	-- Wheels and rims. These are built anchored (see createDetail) instead of
	-- welded, because attachDriving repositions and spins them by hand every
	-- frame -- a WeldConstraint would just fight that. Wheel cylinders default
	-- to spinning around their local X axis, which already lines up with the
	-- chassis's left/right axis, so that's also the axis we spin them on for
	-- rolling. Each rim shares its wheel's position but is narrower and
	-- smaller in diameter, so it sits inset inside the tire like a hubcap.
	local wheelSideOffset = halfX + CarConfig.WHEEL_SIZE.X / 2
	local wheelFrontBackOffset = halfZ - CarConfig.WHEEL_SIZE.Y / 2
	local wheelHeightOffset = -CarConfig.CHASSIS_SIZE.Y / 2

	local wheelOffsets = {
		WheelFrontLeft = Vector3.new(-wheelSideOffset, wheelHeightOffset, -wheelFrontBackOffset),
		WheelFrontRight = Vector3.new(wheelSideOffset, wheelHeightOffset, -wheelFrontBackOffset),
		WheelBackLeft = Vector3.new(-wheelSideOffset, wheelHeightOffset, wheelFrontBackOffset),
		WheelBackRight = Vector3.new(wheelSideOffset, wheelHeightOffset, wheelFrontBackOffset),
	}

	local wheels = {}
	for wheelName, offset in pairs(wheelOffsets) do
		local wheel = createDetail({
			name = wheelName,
			shape = Enum.PartType.Cylinder,
			size = CarConfig.WHEEL_SIZE,
			offset = offset,
			color = Color3.fromRGB(35, 35, 35),
			anchored = true,
			car = car,
			chassis = chassis,
		})
		local rim = createDetail({
			name = wheelName .. "Rim",
			shape = Enum.PartType.Cylinder,
			size = CarConfig.RIM_SIZE,
			offset = offset,
			color = CarConfig.CHROME_COLOR,
			material = Enum.Material.Metal,
			anchored = true,
			car = car,
			chassis = chassis,
		})
		table.insert(wheels, { wheel = wheel, rim = rim, offset = offset })
	end

	return wheels
end

local function createCar(spawnPosition, bodyColor, carName)
	local car = Instance.new("Model")
	car.Name = carName

	local chassis = Instance.new("Part")
	chassis.Name = "Chassis"
	chassis.Size = CarConfig.CHASSIS_SIZE
	chassis.CFrame = CFrame.new(spawnPosition)
	chassis.Color = bodyColor
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

	-- Invisible collision block bridging the visible chassis down to the
	-- wheels' bottom edge. The wheels themselves are cosmetic and don't
	-- collide (see addStyling), so without this, nothing would stop the car
	-- from sinking until the chassis box touches the ground -- which is
	-- below where the wheels are drawn, making them poke through the floor.
	local undercarriageHeight = CarConfig.WHEEL_SIZE.Y / 2
	local undercarriage = Instance.new("Part")
	undercarriage.Name = "Undercarriage"
	undercarriage.Size = Vector3.new(CarConfig.CHASSIS_SIZE.X, undercarriageHeight, CarConfig.CHASSIS_SIZE.Z)
	undercarriage.CFrame = chassis.CFrame * CFrame.new(0, -CarConfig.CHASSIS_SIZE.Y / 2 - undercarriageHeight / 2, 0)
	undercarriage.Transparency = 1
	undercarriage.CanCollide = true
	undercarriage.Massless = true
	undercarriage.Parent = car

	local undercarriageWeld = Instance.new("WeldConstraint")
	undercarriageWeld.Part0 = undercarriage
	undercarriageWeld.Part1 = chassis
	undercarriageWeld.Parent = undercarriage

	local wheels = addStyling(car, chassis, bodyColor)

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

	return chassis, seat, wheels
end

local function moveTowards(current, target, maxDelta)
	if math.abs(target - current) <= maxDelta then
		return target
	end
	return current + math.sign(target - current) * maxDelta
end

local function attachDriving(chassis, seat, wheels)
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

	-- Total angle each wheel has rolled through, in radians.
	local wheelSpinAngle = 0
	local wheelRadius = CarConfig.WHEEL_SIZE.Y / 2

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

		-- Roll the wheels. "angular speed = linear speed / radius" is the
		-- standard formula for a wheel rolling without slipping, so this
		-- spins faster the faster the car goes and reverses when backing up.
		-- Each wheel is Anchored (see addStyling), so setting its CFrame here
		-- is the only thing moving it -- this both follows the chassis around
		-- and applies the spin, in one step.
		wheelSpinAngle += (currentSpeed / wheelRadius) * deltaTime
		local spin = CFrame.Angles(wheelSpinAngle, 0, 0)
		for _, wheelData in ipairs(wheels) do
			local wheelCFrame = chassis.CFrame * CFrame.new(wheelData.offset) * spin
			wheelData.wheel.CFrame = wheelCFrame
			wheelData.rim.CFrame = wheelCFrame
		end
	end)
end

-- One parking spot per color in CarConfig.CAR_COLORS, laid out in a row
-- along X (see PARKING_ORIGIN/PARKING_SPACING) so the cars sit parked side
-- by side. Each car still drives independently once someone sits in it --
-- this loop only decides where they start out.
for index, bodyColor in ipairs(CarConfig.CAR_COLORS) do
	local spotPosition = CarConfig.PARKING_ORIGIN + Vector3.new((index - 1) * CarConfig.PARKING_SPACING, 0, 0)
	local chassis, seat, wheels = createCar(spotPosition, bodyColor, "Car" .. index)
	attachDriving(chassis, seat, wheels)
end
