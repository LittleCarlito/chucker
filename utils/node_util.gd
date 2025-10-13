extends Node

const _NO_PARENT_LOG: String = "No parent object found for method \"%s\"; Returning \"%s\""
const _PARENT_GROUNDED: String = "is_parent_grounded"
const _GET_GRAVITY: String = "get_gravity"

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
	Log.error(_NO_PARENT_LOG, [_PARENT_GROUNDED, str(false)], self)
	return false

## Returns gravity value for the environment
## Returns 0 if no parent with gravity is found
func get_gravity(node: Node3D) -> Vector3:
	if node.get_parent() != null:
		if node is ChuckChucker:
			return node.get_gravity()
		else:
			return get_gravity(node.get_parent())
	Log.error(_NO_PARENT_LOG, [_GET_GRAVITY, "Empty Vector3"], self)
	return Vector3(0, 0, 0)

# TODO See about some handling that errors if this returns 0
## Calculates the trajectory distance given parameters
func calculate_range(height: float, gravity: float, angle: float, velocity: float) -> float:
	# Convert angle from degrees to radians if needed
	angle = deg_to_rad(angle)
	# Calculate horizontal and vertical components of the velocity
	var v0_x: float = velocity * cos(angle)
	var v0_y: float = velocity * sin(angle)
	# Calculate the time of flight using the quadratic formula
	var discriminant: float = v0_y * v0_y + 2 * gravity * height
	if discriminant < 0:
		return 0  # The projectile does not reach the ground
	var sqrt_discriminant:float = sqrt(discriminant)
	var t: float = (v0_y + sqrt_discriminant) / gravity
	# Calculate the range
	return v0_x * t

## Gets mouse hovering location in 3D space
func get_mouse_position() -> Vector3:
	# Get the physics space state to perform raycasting in the 3D world
	var space_state: PhysicsDirectSpaceState3D = get_parent().get_world_3d().get_direct_space_state()
	# Get the current mouse position on the viewport
	var mouse_position: Vector2 = get_viewport().get_mouse_position()
	# Get the camera node from the scene tree to project the ray
	var camera: Camera3D = get_tree().root.get_camera_3d()
	# Calculate the ray's origin point from the camera, starting from the mouse position
	var ray_origin: Vector3 = camera.project_ray_origin(mouse_position)
	# Calculate the ray's end point far into the scene to perform the intersection test
	var ray_end: Vector3 = ray_origin + camera.project_ray_normal(mouse_position) * 1000
	# Prepare the parameters for the raycasting
	var params: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.new()
	params.from = ray_origin
	params.to = ray_end
	params.collision_mask = 0b00000000_00000000_00000000_00000010# Define which layers the ray should collide with.
	params.exclude = [] # Define any objects to exclude from the test."collision_priority"
	# Perform the raycasting in the 3D world and check for intersections.
	var rayDic: Dictionary = space_state.intersect_ray(params)
	# If the ray hit an object, return the hit position; otherwise, return a very far point (infinity).
	if rayDic.has("position"):
		return rayDic["position"]
	return Vector3.INF

## Traverses the ownership of the passed in node until null or ChuckChucker is found
## Returns original Nod3D if ChuckChucker isn't found
func find_chucker(find_chuck: Node) -> Node:
	if find_chuck is ChuckChucker:
		return find_chuck
	else:
		if find_chuck.owner != null:
			return find_chucker(find_chuck.owner)
		else:
			return Node.new()

# TODO Refactor to InputEvent helper

func get_horizontal_look_amount(event: InputEvent) -> float:
	return deg_to_rad(event.relative.x) * CameraConfig.get_horizontal_look_sense()

func get_vertical_look_amount(event: InputEvent) -> float:
	return deg_to_rad(event.relative.y) * CameraConfig.get_vertical_look_sense()

func get_horizontal_aim_amount(event: InputEvent) -> float:
	var h_inversion: int = -1
	if CameraConfig.is_horizontal_invert():
		h_inversion = 1
	var h_sense: float = CameraConfig.get_horizontal_aim_sense()
	var h_rotation_amount: float = h_inversion * (event.relative.x / 1000 * h_sense)
	return h_rotation_amount

func get_vertical_aim_amount(event: InputEvent) -> float:
	var v_inversion: int = -1
	if CameraConfig.is_vertical_invert():
		v_inversion = 1
	var v_sense: float = CameraConfig.get_vertical_aim_sense()
	var v_rotation_amount: float = v_inversion * (event.relative.y / 1000 * v_sense)
	return v_rotation_amount

## Gets the index of the nearest value greater than the desired value
## Returns found index or INT64_MAX
func get_nearest_greater_index(desired_value: int, search_array: Array[int]) -> int:
	var start_value: int = NUMBERS.INT64_MAX
	for existing_number in search_array:
		if existing_number > desired_value and start_value == NUMBERS.INT64_MAX:
			start_value = search_array.find(existing_number)
	return start_value

## Determines if given array of ints is sequential
func is_sequential(incoming_data: Array[int]) -> bool:
	var non_sequential_index: int = get_first_non_sequential_index(incoming_data)
	return true if non_sequential_index != NUMBERS.INT64_MAX else false

## Returns the first non sequential index in the array
## Values are expected to be +1 their index (no 0 references allowed)
## If whole array is sequential returns INT64_MAX
func get_first_non_sequential_index(incoming_data: Array[int]) -> int:
	var return_index: int = NUMBERS.INT64_MAX
	for i in incoming_data.size():
		if i + 1 != incoming_data[i]:
			return_index = i
	return return_index
