class_name AssetStateResolver

static func serialize(incoming_node: Node3D, incoming_state: AssetState) -> void:
	var node_position: Vector3 = incoming_node.global_position
	var node_rotation: Quaternion = incoming_node.basis.get_rotation_quaternion()
	var node_scale: Vector3 = incoming_node.scale
	incoming_state.sync_asset(node_position, node_rotation, node_scale)
