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
