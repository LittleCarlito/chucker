class_name AssetStateResolver

const _SERIALIZE_STATE: String = "serialize_state"

static func serialize_node(incoming_node: Node3D, incoming_state: AssetState) -> void:
	var node_position: Vector3 = incoming_node.global_position
	var node_rotation: Quaternion = incoming_node.basis.get_rotation_quaternion()
	var node_scale: Vector3 = incoming_node.scale
	incoming_state.sync_asset(node_position, node_rotation, node_scale)

static func serialize_state(incoming_state: StateData, incoming_node: Node3D) -> void:
	if incoming_node.has_method(GroupData.SET_ASSET_DATA):
		var owner_guid: String = incoming_state.get_owner_guid()
		var owner_valid_transitions: Dictionary = incoming_state.get_transitions()
		var owner_values: Dictionary = incoming_state.get_values()
		var owner_windows: Dictionary = incoming_state.get_windows()
		var new_state: AssetState = AssetState.new(owner_guid, owner_valid_transitions, owner_values, owner_windows)
		incoming_node.call(GroupData.SET_ASSET_DATA, new_state)
	else:
		var missing_log: String = "%s missing from incoming node" % GroupData.SET_ASSET_DATA
		Log.error(Log._CANT_PERFORM, [missing_log, _SERIALIZE_STATE], null)
