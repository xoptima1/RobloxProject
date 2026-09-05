return {
	MAX_SPEED = 80, -- studs/second
	ACCELERATION = 40, -- studs/second^2 while throttling up
	BRAKE_DECELERATION = 120, -- studs/second^2 when throttle opposes current motion
	COAST_DECELERATION = 20, -- studs/second^2 when no throttle input
	STOP_THRESHOLD = 0.5, -- speed below which the car snaps to a full stop
	TURN_SPEED = 3, -- radians/second at full steer and full speed

	CHASSIS_SIZE = Vector3.new(8, 2, 14),
	WHEEL_SIZE = Vector3.new(2, 4, 4),

	SPAWN_POSITION = Vector3.new(0, 5, 0),
}
