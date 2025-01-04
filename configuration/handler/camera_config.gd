extends Node

const _NO_CATEGORY_MATCH: String = "No configuration match or default match could be found for incoming category name \"%s\" and key \"%s\""

const NAME: String = "camera"
const PAN_SPEED: String = "PAN_SPEED"
const ROTATE_SPEED: String = "ROTATE_SPEED"
const SHOT_WATCH_TIME: String = "SHOT_WATCH_TIME"
const IDLE_ROTATE_SPEED: String = "IDLE_ROTATE_SPEED"
const MIN_HEIGHT: String = "MIN_HEIGHT"
const PLAYER_FOCUS_OFFSET: String = "PLAYER_FOCUS_OFFSET"
const TEE_FOCUS_OFFSET: String = "TEE_FOCUS_OFFSET"
const MAX_HORIZONTAL_ROTATION: String = "MAX_HORIZONTAL_ROTATION"
const MIN_HORIZONTAL_ROTATION: String = "MIN_HORIZONTAL_ROTATION"
const MAX_VERTICAL_ROTATION: String = "MAX_VERTICAL_ROTATION"
const MIN_VERTICAL_ROTATION: String = "MIN_VERTICAL_ROTATION"
const PLAYER_FOV: String = "PLAYER_FOV"
const STATIONARY_FOV: String = "STATIONARY_FOV"
const IN_ADJUST: String = "IN_ADJUST"
const OUT_ADJUST: String = "OUT_ADJUST"
const HORIZONTAL_AIM_SENSITIVITY: String = "HORIZONTAL_AIM_SENSITIVITY"
const HORIZONTAL_LOOK_SENSITIVITY: String = "HORIZONTAL_LOOK_SENSITIVITY"
const VERTICAL_AIM_SENSITIVITY: String = "VERTICAL_AIM_SENSITIVITY"
const VERTICAL_LOOK_SENSITIVITY: String = "VERTICAL_LOOK_SENSITIVITY"
const INVERT_HORIZONTAL: String = "INVERT_HORIZONTAL"
const INVERT_VERTICAL: String = "INVERT_VERTICAL"

const DEFAULTS: Dictionary = {
	PAN_SPEED: .15,
	ROTATE_SPEED: 4,
	IDLE_ROTATE_SPEED: 25.0,
	SHOT_WATCH_TIME: 5,
	MIN_HEIGHT: 4,
	PLAYER_FOCUS_OFFSET: Vector3(0, 0, -10),
	TEE_FOCUS_OFFSET: Vector3(0, 2, 0),
	MAX_HORIZONTAL_ROTATION: 1,
	MIN_HORIZONTAL_ROTATION: -1,
	MAX_VERTICAL_ROTATION: .3,
	MIN_VERTICAL_ROTATION: -.7,
	PLAYER_FOV: 90,
	STATIONARY_FOV: 75,
	IN_ADJUST: 20,
	OUT_ADJUST: 5,
	HORIZONTAL_AIM_SENSITIVITY: .3,
	HORIZONTAL_LOOK_SENSITIVITY: 1.5,
	VERTICAL_AIM_SENSITIVITY: .3,
	VERTICAL_LOOK_SENSITIVITY: 1.5,
	INVERT_HORIZONTAL: false,
	INVERT_VERTICAL: false
}

const CONFIG_LIBRARY: Dictionary = {
	PLAYER_FOV: PLAYER_FOV,
	INVERT_VERTICAL: INVERT_VERTICAL,
	INVERT_HORIZONTAL: INVERT_HORIZONTAL,
	VERTICAL_AIM_SENSITIVITY: VERTICAL_AIM_SENSITIVITY,
	HORIZONTAL_AIM_SENSITIVITY: HORIZONTAL_AIM_SENSITIVITY,
	VERTICAL_LOOK_SENSITIVITY: VERTICAL_LOOK_SENSITIVITY,
	HORIZONTAL_LOOK_SENSITIVITY: HORIZONTAL_LOOK_SENSITIVITY
}

var _user_data: ConfigFile

func _ready() -> void:
	add_to_group(CONSTANTS.CONFIG_HANDLER)
	reload_project_settings()

## Retrieves the configured fov value
func get_fov_value() -> int:
	return _get_category_value(CameraConfig.NAME, CameraConfig.PLAYER_FOV)

## Retrieves the configured stationary fov value
func get_stationary_fov_value() -> int:
	return _get_category_value(CameraConfig.NAME, CameraConfig.STATIONARY_FOV)

## Retrieves the configured horizontal aim sense value
func get_horizontal_aim_sens() -> float:
	return _get_category_value(CameraConfig.NAME, CameraConfig.HORIZONTAL_AIM_SENSITIVITY)

## Retrieves the configured horizontal look sense value
func get_horizontal_look_sens() -> float:
	return _get_category_value(CameraConfig.NAME, CameraConfig.HORIZONTAL_LOOK_SENSITIVITY)

## Retrieves the configured veritical aim sense value
func get_vertical_aim_sense() -> float:
	return _get_category_value(CameraConfig.NAME, CameraConfig.VERTICAL_AIM_SENSITIVITY)

## Retrieves the configured veritical look sense value
func get_vertical_look_sense() -> float:
	return _get_category_value(CameraConfig.NAME, CameraConfig.VERTICAL_LOOK_SENSITIVITY)

## Retrieves the configured veritical inversion value
func is_vertical_invert() -> bool:
	return _get_category_value(CameraConfig.NAME, CameraConfig.INVERT_VERTICAL)

## Retrieves the configured horizontal inversion value
func is_horizontal_invert() -> bool:
	return _get_category_value(CameraConfig.NAME, CameraConfig.INVERT_HORIZONTAL)

## Retrieves the configured rotation speed value
func get_rotate_speed() -> float:
	return _get_category_value(CameraConfig.NAME, CameraConfig.ROTATE_SPEED)

## Retrieves the configured max horizontal rotation value
func get_max_horizontal_rotation() -> float:
	return _get_category_value(CameraConfig.NAME, CameraConfig.MAX_HORIZONTAL_ROTATION)

## Retrieves the configured min horizontal rotation value
func get_min_horizontal_rotation() -> float:
	return _get_category_value(CameraConfig.NAME, CameraConfig.MIN_HORIZONTAL_ROTATION)

## Retrieves the configured max vertical rotation value
func get_max_vertical_rotation() -> float:
	return _get_category_value(CameraConfig.NAME, CameraConfig.MAX_VERTICAL_ROTATION)

## Retrieves the configured min vertical rotation value
func get_min_vertical_rotation() -> float:
	return _get_category_value(CameraConfig.NAME, CameraConfig.MIN_VERTICAL_ROTATION)

## Retrieves the configured out adjust value
func get_in_adjust() -> float:
	return _get_category_value(CameraConfig.NAME, CameraConfig.IN_ADJUST)

## Retrieves the configured in adjust value
func get_out_adjust() -> float:
	return _get_category_value(CameraConfig.NAME, CameraConfig.OUT_ADJUST)

## Retrieves the configured player focus value
func get_player_focus_offset() -> Vector3:
	return _get_category_value(CameraConfig.NAME, CameraConfig.PLAYER_FOCUS_OFFSET)

## Retrieves the configured stationary focus value
func get_stationary_focus_offset() -> Vector3:
	return _get_category_value(CameraConfig.NAME, CameraConfig.TEE_FOCUS_OFFSET)

# TODO Get this in a generalized spot so input can use it
# TODO Get Graphics tab using it and DefaultLibrary
## Returns the configured value for the category
func _get_category_value(category_name: String, category_key: String):
	var category_value
	if _user_data.has_section_key(category_name, category_key):
		category_value = _user_data.get_value(category_name, category_key)
	else:
		var category_dictionary: Dictionary = DefaultLibrary.DEFAULTS.get(category_name, {}) as Dictionary
		if !category_dictionary.is_empty():
			if category_dictionary.has(category_key):
				category_value = category_dictionary.get(category_key)
	if category_value == null:
		var formatted_string: String = _NO_CATEGORY_MATCH + CONSTANTS.LOG_SEPARATOR + CONSTANTS.RETURNING_INT16_MAX
		Logger.debug(formatted_string, [category_name, category_key], self)
	return category_value

## usually called via group CONFIG_HANDLER method calls
func reload_project_settings() -> void:
	_user_data = ConfigFileHandler.get_user_setting_file()
	
