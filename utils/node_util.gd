extends Node

## Returns total of parent node heights
func get_parent_heights(node: Node3D) -> float:
	if node.get_parent_node_3d() != null:
		if node is ChuckChucker:
			return node.get_height()/2
		else:
			return abs(node.position.y) + get_parent_heights(node.get_parent_node_3d())
	return abs(node.position.y)

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
