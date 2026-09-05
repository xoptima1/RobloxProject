-- Config for the AI-generated detailed sports car (see DetailedCarSpawner.server.lua).
--
-- Unlike the parking-lot cars in CarConfig.lua, this car isn't built from
-- primitive shapes at runtime. Roblox restricts assigning MeshId/TextureID
-- from a script (an anti-exploit/content-moderation safeguard: scripts
-- can't just point a part at arbitrary asset content), so AI-generated
-- meshes have to exist as a pre-placed template instead. That template
-- lives in the Studio place itself, at ReplicatedStorage.CarAssets
-- .DetailedSportsCarTemplate (NOT in this git repo -- Rojo only manages
-- ReplicatedStorage.Shared, so this sits alongside it untouched). The
-- spawner script Clones that template rather than building it from scratch.
--
-- The mesh's own local axes also aren't Roblox's usual part convention:
-- measuring the generated wheel positions shows front/rear pairs separated
-- along local X (front is -X) while left/right pairs separate along local
-- Z -- rotated 90 degrees from a normal Roblox part (front is usually -Z).
-- DetailedCarSpawner drives and spins wheels using LOCAL_FORWARD /
-- WHEEL_SPIN_AXIS below instead of assuming -Z.
return {
	TEMPLATE_PATH = { "CarAssets", "DetailedSportsCarTemplate" }, -- under ReplicatedStorage

	LOCAL_FORWARD = Vector3.new(-1, 0, 0),
	WHEEL_SPIN_AXIS = "Z",
	WHEEL_RADIUS = 1.4,

	-- Estimated cockpit position, relative to the chassis -- near the
	-- windshield opening, slightly toward the rear of it.
	SEAT_OFFSET = Vector3.new(0.5, -0.4, 0),
	SEAT_SIZE = Vector3.new(1.8, 0.8, 1.8),

	CHASSIS_DENSITY = 3,
	CHASSIS_FRICTION = 0.4,
	CHASSIS_ELASTICITY = 0,
	BALLAST_DENSITY = 25,

	MAX_SPEED = 90,
	ACCELERATION = 45,
	BRAKE_DECELERATION = 130,
	COAST_DECELERATION = 22,
	STOP_THRESHOLD = 0.5,
	TURN_SPEED = 3,
	FLIP_UP_DOT_THRESHOLD = 0,
	MAX_ANGULAR_SPEED = 4,

	SPAWN_POSITION = Vector3.new(20, 5, 45),
}
