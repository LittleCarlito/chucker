extends Node

## Returns total rotation on the x axis of parent nodes up to character
func get_parent_x_rotation(node: Node3D) -> float:
	if node.get_parent() != null:
		if node is ChuckChucker:
			return node.rotation_degrees.x
		else:
			return node.rotation_degrees.x + get_parent_x_rotation(node.get_parent())
	return node.rotation_degrees.x

## Determines if parent Character node is grounded
## Returns false if no parent Character is found
func is_parent_grounded(node: Node3D) -> bool:
	if node is CharacterBody3D:
		return node.is_on_floor()
	if node.get_parent_node_3d() != null:
		return is_parent_grounded(node.get_parent_node_3d())
	push_error("is_parent_grounded for " + node.name + ", no parent object found; Returning false")
	return false

## Returns gravity value for the environment
## Returns 0 if no parent with gravity is found
func get_gravity(node: Node3D) -> Vector3:
	if node.get_parent() != null:
		if node is ChuckChucker:
			return node.get_gravity()
		else:
			return get_gravity(node.get_parent())
	push_error("get_gravity for " + node.name + ", no parent object found; Returning empty vector")
	return Vector3(0, 0, 0)

## Calculates the trajectory distance given parameters
func calculate_range(height: float, gravity: float, angle: float, velocity: float) -> float:
	# Convert angle from degrees to radians if needed
	angle = deg_to_rad(angle)  # Uncomment this if angle is given in degrees
	# Calculate horizontal and vertical components of the velocity
	var v0_x = velocity * cos(angle)
	var v0_y = velocity * sin(angle)
	# Calculate the time of flight using the quadratic formula
	var discriminant = v0_y * v0_y + 2 * gravity * height
	if discriminant < 0:
		return 0  # The projectile does not reach the ground
	var sqrt_discriminant = sqrt(discriminant)
	var t = (v0_y + sqrt_discriminant) / gravity
	# Calculate the range
	var returnRange = v0_x * t
	return returnRange

## Gets mouse hovering location in 3D space
func get_mouse_position() -> Vector3:
	# Get the physics space state to perform raycasting in the 3D world
	var space_state = get_parent().get_world_3d().get_direct_space_state()
	# Get the current mouse position on the viewport
	var mouse_position = get_viewport().get_mouse_position()
	# Get the camera node from the scene tree to project the ray
	var camera = get_tree().root.get_camera_3d()
	# Calculate the ray's origin point from the camera, starting from the mouse position
	var ray_origin = camera.project_ray_origin(mouse_position)
	# Calculate the ray's end point far into the scene to perform the intersection test
	var ray_end = ray_origin + camera.project_ray_normal(mouse_position) * 1000
	# Prepare the parameters for the raycasting
	var params = PhysicsRayQueryParameters3D.new()
	params.from = ray_origin
	params.to = ray_end
	params.collision_mask = 0b00000000_00000000_00000000_00000010# Define which layers the ray should collide with.
	params.exclude = [] # Define any objects to exclude from the test."collision_priority"
	# Perform the raycasting in the 3D world and check for intersections.
	var rayDic = space_state.intersect_ray(params)
	# If the ray hit an object, return the hit position; otherwise, return a very far point (infinity).
	if rayDic.has("position"):
		return rayDic["position"]
	return Vector3.INF

## Traverses the ownership of the passed in node until null or ChuckChucker is found
## Returns original Nod3D if ChuckChucker isn't found
func find_chucker(findChuck: Node) -> Node:
	if findChuck is ChuckChucker:
		return findChuck
	else:
		if findChuck.owner != null:
			return find_chucker(findChuck.owner)
		else:
			return Node.new()
