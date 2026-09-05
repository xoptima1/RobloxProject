return {
	-- Driving feel
	MAX_SPEED = 80, -- studs/second
	ACCELERATION = 40, -- studs/second^2 while throttling up
	BRAKE_DECELERATION = 120, -- studs/second^2 when throttle opposes current motion
	COAST_DECELERATION = 20, -- studs/second^2 when no throttle input
	STOP_THRESHOLD = 0.5, -- speed below which the car snaps to a full stop
	TURN_SPEED = 3, -- radians/second at full steer and full speed

	-- Flip handling
	FLIP_UP_DOT_THRESHOLD = 0, -- car loses control once tipped past ~90 degrees from upright
	MAX_ANGULAR_SPEED = 4, -- radians/second cap on tumbling, so collisions can't send it spinning wildly

	-- Core body / physics
	CHASSIS_SIZE = Vector3.new(8, 2, 14),
	CHASSIS_DENSITY = 3, -- heavier than Roblox's ~0.7 default, so hits impart less spin
	CHASSIS_FRICTION = 0.4,
	CHASSIS_ELASTICITY = 0, -- no bounce on impact

	HOOD_SIZE = Vector3.new(6, 1, 4),
	TRUNK_SIZE = Vector3.new(6, 1, 3),

	-- Invisible, extra-dense block welded low on the chassis. It doesn't
	-- change how the car looks, only where its combined center of mass
	-- sits -- lower and heavier means it takes a much bigger hit to tip over.
	BALLAST_SIZE = Vector3.new(4, 1, 6),
	BALLAST_DENSITY = 25,

	-- Cabin / glass
	ROOF_SIZE = Vector3.new(6, 0.5, 7),
	ROOF_OFFSET_Y = 3.5,
	ROOF_OFFSET_Z = 0.25,
	WINDSHIELD_SIZE = Vector3.new(6, 1.5, 0.2),
	WINDSHIELD_OFFSET = Vector3.new(0, 2.75, -3.3),
	REAR_WINDOW_SIZE = Vector3.new(6, 1.5, 0.2),
	REAR_WINDOW_OFFSET = Vector3.new(0, 2.75, 3.9),
	PILLAR_SIZE = Vector3.new(0.3, 1.75, 0.3),

	-- Bumpers, grille, plates
	BUMPER_SIZE = Vector3.new(8.4, 0.8, 0.6),
	FRONT_BUMPER_OFFSET = Vector3.new(0, -0.5, -7.3),
	REAR_BUMPER_OFFSET = Vector3.new(0, -0.5, 7.3),
	GRILLE_SIZE = Vector3.new(4, 0.6, 0.15),
	GRILLE_OFFSET = Vector3.new(0, 1, -7.05),
	LICENSE_PLATE_SIZE = Vector3.new(1.5, 0.6, 0.05),
	FRONT_PLATE_OFFSET = Vector3.new(0, 0, -7.62),
	REAR_PLATE_OFFSET = Vector3.new(0, 0, 7.62),

	-- Lights
	HEADLIGHT_SIZE = Vector3.new(1, 0.5, 0.3),
	HEADLIGHT_X = 2.5,
	HEADLIGHT_OFFSET_Y = 1.3,
	HEADLIGHT_OFFSET_Z = -7.05,
	TAILLIGHT_SIZE = Vector3.new(1, 0.5, 0.3),
	TAILLIGHT_OFFSET_Y = 1.3,
	TAILLIGHT_OFFSET_Z = 7.05,

	-- Mirrors
	MIRROR_SIZE = Vector3.new(0.3, 0.4, 0.8),
	MIRROR_OFFSET = Vector3.new(4.3, 2.2, -3.3),

	-- Spoiler
	SPOILER_STRUT_SIZE = Vector3.new(0.3, 1, 0.3),
	SPOILER_STRUT_X = 2,
	SPOILER_STRUT_OFFSET_Y = 2.5,
	SPOILER_OFFSET_Z = 6.7,
	SPOILER_WING_SIZE = Vector3.new(5, 0.3, 1.2),
	SPOILER_WING_OFFSET_Y = 3.15,

	-- Exhaust pipes (cylinder Size.X is the length once rotated to point backward)
	EXHAUST_SIZE = Vector3.new(1, 0.5, 0.5),
	EXHAUST_X = 1.5,
	EXHAUST_OFFSET_Y = -0.7,
	EXHAUST_OFFSET_Z = 7.6,

	-- Wheels
	WHEEL_SIZE = Vector3.new(2, 4, 4),
	RIM_SIZE = Vector3.new(1.2, 2.2, 2.2),

	-- Colors
	BODY_COLOR = Color3.fromRGB(200, 30, 30),
	ACCENT_COLOR = Color3.fromRGB(40, 40, 40),
	GLASS_COLOR = Color3.fromRGB(120, 170, 190),
	CHROME_COLOR = Color3.fromRGB(210, 210, 215),
	HEADLIGHT_COLOR = Color3.fromRGB(255, 255, 240),
	TAILLIGHT_COLOR = Color3.fromRGB(255, 40, 40),
	PLATE_COLOR = Color3.fromRGB(230, 230, 220),

	SPAWN_POSITION = Vector3.new(0, 5, 0),
}
