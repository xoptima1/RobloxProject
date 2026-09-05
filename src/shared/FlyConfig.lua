return {
	-- Shrinks the whole character via Model:ScaleTo -- the same method used
	-- to resize the detailed car.
	SCALE = 0.35,

	BODY_COLOR = Color3.fromRGB(25, 25, 28),
	WING_COLOR = Color3.fromRGB(230, 230, 235),
	WING_TRANSPARENCY = 0.55,

	-- studs/second. Applies to the combined move vector (horizontal input
	-- plus vertical), so diagonal flight isn't faster than straight flight.
	FLY_SPEED = 45,

	WING_SIZE = Vector3.new(2.2, 0.1, 1.1),
	-- Offset from the torso's center; X is mirrored for the left/right wing.
	WING_OFFSET = Vector3.new(0.6, 0.6, -0.3),
	WING_FLAP_SPEED = 25, -- radians/second of the flap oscillation
	WING_FLAP_ANGLE = math.rad(35), -- how far each wing rotates per flap
}
