extends Node

## Returns total of parent node heights
func get_parent_heights(node: Node3D, zDistance: float = 0) -> float:
	if node.get_parent_node_3d() != null:
		if node is ChuckChucker:
			return node.get_height()/2
		else:
			return abs(node.position.y) + get_parent_heights(node.get_parent_node_3d(), zDistance)
	return abs(node.position.y)

## Determines if parent Character node is grounded
## Returns null if no parent Character is found
func is_parent_grounded(node: Node3D):
	if node is CharacterBody3D:
		return node.is_on_floor()
	if node.get_parent_node_3d() != null:
		return is_parent_grounded(node.get_parent_node_3d())
	return null
