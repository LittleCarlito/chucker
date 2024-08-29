extends Node

## Returns total of parent node heights
func get_parent_heights(total: float, node: Node3D) -> float:
	var newTotal = total + node.position.y
	if node.get_parent_node_3d() != null and node is not CharacterBody3D:
	#if node.get_parent_node_3d() != null and node.get_parent_node_3d().position.y >= 0.0:
		return get_parent_heights(newTotal, node.get_parent_node_3d())
	else:
		return newTotal
