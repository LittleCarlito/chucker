class_name TransformResolver

# TODO Rotate the incoming node to the incoming rotation smoothly; Using tweens or lerp or some shit
static func resolve_rotation(incoming_node: Node3D, incoming_rotation: Quaternion) -> bool:
	return false

# TODO Move the incoming node to the incoming position smoothly; Using tweens or lerp or some shit
static func resolve_position(incoming_node: Node3D, incoming_position: Vector3) -> bool:
	return false

# TODO Scale the incoming node to the incoming size smoothly; Using tweens or lerp or some shit
static func resolve_scale(incoming_node: Node3D, incoming_scale: Vector3) -> bool:
	return false
