return {
	MAX_SPEED = 80, -- studs/second
	ACCELERATION = 40, -- studs/second^2 while throttling up
	BRAKE_DECELERATION = 120, -- studs/second^2 when throttle opposes current motion
	COAST_DECELERATION = 20, -- studs/second^2 when no throttle input
	STOP_THRESHOLD = 0.5, -- speed below which the car snaps to a full stop
	TURN_SPEED = 3, -- radians/second at full steer and full speed

	FLIP_UP_DOT_THRESHOLD = 0, -- car loses control once tipped past ~90 degrees from upright
	MAX_ANGULAR_SPEED = 4, -- radians/second cap on tumbling, so collisions can't send it spinning wildly

	CHASSIS_SIZE = Vector3.new(8, 2, 14),
	CHASSIS_DENSITY = 3, -- heavier than Roblox's ~0.7 default, so hits impart less spin
	CHASSIS_FRICTION = 0.4,
	CHASSIS_ELASTICITY = 0, -- no bounce on impact

	WHEEL_SIZE = Vector3.new(2, 4, 4),
	HOOD_SIZE = Vector3.new(6, 1, 4),
	TRUNK_SIZE = Vector3.new(6, 1, 3),

	-- Invisible, extra-dense block welded low on the chassis. It doesn't
	-- change how the car looks, only where its combined center of mass
	-- sits -- lower and heavier means it takes a much bigger hit to tip over.
	BALLAST_SIZE = Vector3.new(4, 1, 6),
	BALLAST_DENSITY = 25,

	BODY_COLOR = Color3.fromRGB(200, 30, 30),
	ACCENT_COLOR = Color3.fromRGB(40, 40, 40),

	SPAWN_POSITION = Vector3.new(0, 5, 0),
}
