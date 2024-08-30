extends Node

## Returns total of parent node heights
func get_parent_heights(total: float, node: Node3D, zDistance: float = 0) -> float:
	if node.get_parent_node_3d() != null and node.name not in APP.EXCLUDE_BODIES:
		var heightLogString: String = "Node \"%s\"; Position.y is \"%s\""
		Logger.debug(heightLogString, [node.name, node.rotation_degrees.y])
		var newTotal = total + abs(node.position.y)
		# TODO Figure out logic for rotation height addition
		if node.rotation.y > 0:
			var rotateHeight: float = tan(node.rotation.y) * zDistance
			var rotationLogString: String = "Node \"%s\"; Rotation is \"%s\"; Height to add from rotation is \"%s\""
			#Logger.debug(rotationLogString, [node.name, node.rotation_degrees.y, rotateHeight])
		#if node.get_parent_node_3d() != null and node.get_parent_node_3d().position.y >= 0.0:
		return get_parent_heights(newTotal, node.get_parent_node_3d(), zDistance)
	return total

## Determines if parent Character node is grounded
## Returns null if no parent Character is found
func is_parent_grounded(node: Node3D):
	if node is CharacterBody3D:
		return node.is_on_floor()
	if node.get_parent_node_3d() != null:
		return is_parent_grounded(node.get_parent_node_3d())
	return null
