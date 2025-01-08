extends Node
class_name CameraConfig

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
	MIN_HEIGHT: 0,
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

func _ready() -> void:
	add_to_group(GroupData.CONFIG_HANDLER)

## Retrieves the configured idle rotate speed value
static func get_idle_rotate_speed() -> float:
	return UserSettingData.get_category_value(CameraConfig.NAME, CameraConfig.IDLE_ROTATE_SPEED)

## Retrieves the configured shot watch time value
static func get_shot_watch_time() -> float:
	return UserSettingData.get_category_value(CameraConfig.NAME, CameraConfig.SHOT_WATCH_TIME)

## Retrieves the configured fov value
static func get_fov_value() -> int:
	return UserSettingData.get_category_value(CameraConfig.NAME, CameraConfig.PLAYER_FOV)

## Retrieves the configured stationary fov value
static func get_stationary_fov_value() -> int:
	return UserSettingData.get_category_value(CameraConfig.NAME, CameraConfig.STATIONARY_FOV)

## Retrieves the configured horizontal aim sense value
static func get_horizontal_aim_sens() -> float:
	return UserSettingData.get_category_value(CameraConfig.NAME, CameraConfig.HORIZONTAL_AIM_SENSITIVITY)

## Retrieves the configured horizontal look sense value
static func get_horizontal_look_sens() -> float:
	return UserSettingData.get_category_value(CameraConfig.NAME, CameraConfig.HORIZONTAL_LOOK_SENSITIVITY)

## Retrieves the configured veritical aim sense value
static func get_vertical_aim_sense() -> float:
	return UserSettingData.get_category_value(CameraConfig.NAME, CameraConfig.VERTICAL_AIM_SENSITIVITY)

## Retrieves the configured veritical look sense value
static func get_vertical_look_sense() -> float:
	return UserSettingData.get_category_value(CameraConfig.NAME, CameraConfig.VERTICAL_LOOK_SENSITIVITY)

## Retrieves the configured veritical inversion value
static func is_vertical_invert() -> bool:
	return UserSettingData.get_category_value(CameraConfig.NAME, CameraConfig.INVERT_VERTICAL)

## Retrieves the configured horizontal inversion value
static func is_horizontal_invert() -> bool:
	return UserSettingData.get_category_value(CameraConfig.NAME, CameraConfig.INVERT_HORIZONTAL)

## Retrieves the configured rotation speed value
static func get_rotate_speed() -> float:
	return UserSettingData.get_category_value(CameraConfig.NAME, CameraConfig.ROTATE_SPEED)

## Retrieves the configured max horizontal rotation value
static func get_max_horizontal_rotation() -> float:
	return UserSettingData.get_category_value(CameraConfig.NAME, CameraConfig.MAX_HORIZONTAL_ROTATION)

## Retrieves the configured min horizontal rotation value
static func get_min_horizontal_rotation() -> float:
	return UserSettingData.get_category_value(CameraConfig.NAME, CameraConfig.MIN_HORIZONTAL_ROTATION)

## Retrieves the configured max vertical rotation value
static func get_max_vertical_rotation() -> float:
	return UserSettingData.get_category_value(CameraConfig.NAME, CameraConfig.MAX_VERTICAL_ROTATION)

## Retrieves the configured min vertical rotation value
static func get_min_vertical_rotation() -> float:
	return UserSettingData.get_category_value(CameraConfig.NAME, CameraConfig.MIN_VERTICAL_ROTATION)

## Retrieves the configured out adjust value
static func get_in_adjust() -> float:
	return UserSettingData.get_category_value(CameraConfig.NAME, CameraConfig.IN_ADJUST)

## Retrieves the configured in adjust value
static func get_out_adjust() -> float:
	return UserSettingData.get_category_value(CameraConfig.NAME, CameraConfig.OUT_ADJUST)

## Retrieves the configured player focus value
static func get_player_focus_offset() -> Vector3:
	return UserSettingData.get_category_value(CameraConfig.NAME, CameraConfig.PLAYER_FOCUS_OFFSET)

## Retrieves the configured stationary focus value
static func get_stationary_focus_offset() -> Vector3:
	return UserSettingData.get_category_value(CameraConfig.NAME, CameraConfig.TEE_FOCUS_OFFSET)
