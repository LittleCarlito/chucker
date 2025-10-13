class_name TransformResolver

static func resolve_rotation(incoming_node: Node3D, incoming_rotation: Quaternion) -> bool:
	incoming_node.transform.basis = Basis(incoming_rotation.normalized())
	return true

static func resolve_position(incoming_node: Node3D, incoming_position: Vector3) -> bool:
	incoming_node.position = incoming_position
	return true

static func resolve_scale(incoming_node: Node3D, incoming_scale: Vector3) -> bool:
	incoming_node.scale = incoming_scale
	return true

static func resolve_velocity(incoming_node: Node3D, incoming_velocity: Vector3) -> bool:
	incoming_node.velocity = incoming_velocity
	return true
