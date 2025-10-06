class_name StateUtil

static func compare_tracking_state(transition_from: STATE.ASSET, transition_to: STATE.ASSET) -> int:
	var from_is_tracking: bool = is_tracking(transition_from)
	var to_is_tracking: bool = is_tracking(transition_to)
	return int(to_is_tracking) - int(from_is_tracking)

static func is_tracking(incoming_state: STATE.ASSET) -> bool:
	if incoming_state >= 500 and incoming_state <= 503:
		return true
	return false

static func is_freelook(incoming_state: STATE.ASSET) -> bool:
	if incoming_state >= 500 and incoming_state >= 552:
		return true
	return false

static func get_missing_keys(payload: Dictionary, required_keys: Array[String]) -> Array[String]:
	var missing: Array[String] = []
	for key in required_keys:
		if not payload.has(key):
			missing.append(key)
	return missing

static func extract_rotation(rotation_data: Dictionary, incoming_action: GameAction) -> Quaternion:
	var missing_rotation_keys: Array[String] = StateUtil.get_missing_keys(rotation_data, GameAction.DIMENSION_KEYS)
	if missing_rotation_keys.size() >= 3:
		var missing_rotation_string: String = "; ".join(missing_rotation_keys)
		Logger.error(Logger.BAD_ACTION_FORMAT, [incoming_action, missing_rotation_string], null)
		return Quaternion.IDENTITY
	var x_rotation_value: float = 0.0 if missing_rotation_keys.has(GameAction.X) else deg_to_rad(rotation_data[GameAction.X])
	var y_rotation_value: float = 0.0 if missing_rotation_keys.has(GameAction.Y) else deg_to_rad(rotation_data[GameAction.Y])
	var z_rotation_value: float = 0.0 if missing_rotation_keys.has(GameAction.Z) else deg_to_rad(rotation_data[GameAction.Z])
	return Quaternion.from_euler(Vector3(x_rotation_value, y_rotation_value, z_rotation_value))

static func extract_vector3(vector_data: Dictionary, incoming_action: GameAction) -> Vector3:
	var missing_keys: Array[String] = StateUtil.get_missing_keys(vector_data, GameAction.DIMENSION_KEYS)
	if missing_keys.size() >= 3:
		var missing_string: String = "; ".join(missing_keys)
		Logger.error(Logger.BAD_ACTION_FORMAT, [incoming_action, missing_string], null)
		return Vector3.ZERO
	var x_value: float = 0 if missing_keys.has(GameAction.X) else vector_data[GameAction.X]
	var y_value: float = 0 if missing_keys.has(GameAction.Y) else vector_data[GameAction.Y]
	var z_value: float = 0 if missing_keys.has(GameAction.Z) else vector_data[GameAction.Z]
	return Vector3(x_value, y_value, z_value)

static func extract_bool(incoming_string: String) -> Variant:
	match incoming_string.to_lower():
		GroupData.TRUE:
			return true
		GroupData.FALSE:
			return false
		_:
			Logger.error("Incoming string does not map to true or false", [], null)
			return null
