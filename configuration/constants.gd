extends Node
class_name CONSTANTS

const BLOCKING_VALUE: String = "BLOCKING"
const HIGHER: String = "higher"
const LOWER: String = "lower"
const INCREASE: String = "increase"
const DECREASE: String = "decrease"
const SUCCESSFUL: String = "Successful"
const FAILURE: String = "Failure"
# TODO Refactor these out to Logger or a Log Constants file
const KEEPING_CAMERA: String = "Not transferring camera"
const NULL_PARAMETER_STRING: String = "Null parameter given"
const CANNOT_ACTION_STRING: String = "Cannot %s"
const ILLEGAL_STATE_STRING: String = "Illegal state has been reached %s"
const EXISTING_DATA_MISSING: String = "%s \"%s\" was expected to exist but returned null from %s"
const FOR_METHOD_LOG: String = "For method %s"
const METHOD_LOG: String = "\"%s\"; \"%s\""
const NULL_LOG: String = "\"%s\" is null"
const ITEM_OWNER_LOG: String = "item_owner \"%s\""
const UNIMPLEMENTED_LOG: String = "UNIMPLEMENTED METHOD; All %s Objects must implement \"%s\""
const UNSUPPORTED_TYPE_LOG: String = "%s recieved an unsupported type \"%s\""
const RETURNING_NULL_LOG: String = "Returning null"
const RETURNING_FALSE_LOG: String = "Returning false"
const RETURNING_ZERO_LOG: String = "Returning 0"
const NULL_CAMERA_LOG: String = "has no camera and cannot %s"
const ALREADY_EXISTS_LOG: String = "%s already exists"
const NOT_FOUND_LOG: String = "No %s could be found"
const HOLE_NODE_DATA: String = "HoleNodeData"
const TOGGLE_CAMERA: String = "toggle_camera"
const DISABLE_CAMERA: String = "disable_camera"
const ENABLE_CAMERA: String = "enable_camera"
const RESET_ZOOM: String = "reset_zoom"
const ZOOM_IN: String = "zoom_in"
const ZOOM_OUT: String = "zoom_out"
const GET_CAMERA: String = "get_camera"
const IS_CURRENT: String = "is_current"
const LOCATION_LOG: String = "\"%s\" global position \"%s\""
# TODO Refactor other users to use this instead
const RETURNING_UNKNOWN_LOG: String = "Returning unknown"
const PICKED_UP_LOG: String = "%s has been picked up"
const DEACTIVATE_LOG: String = "%s is deactivating"
const LOG_SEPARATOR: String = "; "
const OR_SEPARATOR: String = " OR "
const EITHER_STARTER: String = "Either "
const NO_METHOD_FOUND: String = "No method \"%s\" found on object \"%s\""


# General method names
# TODO Need to implement this method in all assets that contain CameraContainer
const SET_CAMERA: String = "set_camera" # (incoming_camera: Camera3D, focus_point: Vector3 = Vecotr3.INF)
const HAS_CAMERA: String = "has_camera"
# TODO Need to implement this in objects that will initiate transferring of cameras (ChuckChucker, PathDisk)
const GIVE_CAMERA: String = "_give_camera" # (requesting_owner: Node3D)
# TODO CameraContainer needs to implement this to attempt to give ones of its instances of itself to the requesting_owner
#			Will need to update in the future to ask for specific camera
const REQUEST_CAMERA: String = "_request_camera" # (requesting_owner: Node3D)
const RETURN_CAMERA: String = "_return_camera" # (incoming_camera: Camera3D)
# TODO Implement this method in all assets that can be picked up and have a camera transferred to them
const GET_CAMERA_CONTAINER: String = "_get_camera_container"
# TODO All holders of AssetData need getters and setters created
const SET_ASSET_DATA: String = "_set_asset_data" # (incoming_data: AssetData)
const GET_ASSET_DATA: String = "_get_asset_data"
# TODO All holders of FlightData need getters and setters created
const SET_FLIGHT_DATA: String = "_set_flight_data" # (incoming_data: FlightData)
const GET_FLIGHT_DATA: String = "_get_flight_data"
const SET_FLIGHT_BASIS: String = "_set_flight_global_basis" # (incoming_basis:Basis)
# TODO All assets that need the ability to launch must implement below
# TODO Make sure to look at flight data if set to set camera to focused if containing camera and flight data is focused launch
const LAUNCH: String = "_launch"

# Group names
const ENVIRONMENT: String = "Environment"
const PLAYER: String = "Player"
const DISK: String = "Disk"
const GENERAL: String = "General"
const COURSE: String = "Course"
const TEE_BOX: String = "TeeBox"
const CAMERA_CONTAINER: String = "CameraContainer"
# Group methods
const HOLD_ACTION: String = "hold_action"
const RELEASE_ACTION: String = "release_action"
const DISABLE_MOVEMENT: String = "disable_movement"
const ENABLE_MOVEMENT: String = "enable_movement"
const DISABLE_ROTATION: String = "disable_rotation"
const ENABLE_ROTATION: String = "enable_rotation"
const RELOAD_PROJECT_SETTINGS: String = "reload_project_settings"
# TODO General items need to implement this for after launch attempts
const UPDATE_STATE: String = "_update_state"
# TODO Rework these to be ALTER_HOLE_NUMBER and ALTER_HOLE_NODE_NUMBER; These should only be on TeeBox assets
const ALTER_HOLE_NODE_NUMBERS: String = "_alter_hole_node_numbers" # (hole_number: int, update_data: Dictionary[old_value[int], new_value[int])
const ALTER_HOLE_NUMBERS: String = "_alter_hole_numbers" # (update_data: Dictionary[old_value[int], new_value[int])
const RELOAD_COURSE_DATA: String = "_reload_course_data" # (hole_number: int = CONSTANTS.INT64_MAX)
# TODO Rework COURSE group members to not implement this; Will be handled through TeeBox
const INCREASE_NODE_NUMBER: String = "_increase_node_number"
# TODO Implement this in TEEBOX assets
const DECREASE_NODE_NUMBER: String = "_decrease_node_number"
# TODO Implement this in TEEBOX assets
const INCREASE_HOLE_NUMBER: String = "_increase_hole_number"

const MENU: Dictionary = {
	"SCORECARD": {
		"PLAYER_PIXEL_SIZE": .003,
		"TEEBOX_PIXEL_SIZE": .0023
	}
}

# Keys are how it is handled in code
# Values are how project settings handle those behaviors
const USER_INPUT: Dictionary = {
	"FORWARD": "move_forward",
	"BACKWARD": "move_backward",
	"ROTATE_LEFT": "rotate_left",
	"STRAFE_LEFT": "move_left",
	"ROTATE_RIGHT": "rotate_right",
	"STRAFE_RIGHT": "move_right",
	"ROTATE_UP": "rotate_up",
	"ROTATE_DOWN": "rotate_down",
	"JUMP": "move_jump",
	"CROUCH": "move_crouch",
	"SPRINT": "move_sprint",
	"INTERACT": "player_interact",
	"PRIMARY": "player_primary",
	"SECONDARY": "player_secondary",
	"SCORE": "menu_score",
	"PAUSE": "menu_pause",
	"DEBUG": "admin_debug"
}

# Keys are how we display input type on UI
# Values are how project settings handle those behaviors
const INPUT_LABEL: Dictionary = {
	# Menu labels
	"Scorecard": USER_INPUT.SCORE,
	"Pause": USER_INPUT.PAUSE,
	# Action labels
	"Primary Action": USER_INPUT.PRIMARY,
	"Secondary Action": USER_INPUT.SECONDARY,
	"Pick Up": USER_INPUT.INTERACT,
	# Rotate labels
	"Rotate Left": USER_INPUT.ROTATE_LEFT,
	"Rotate Right": USER_INPUT.ROTATE_RIGHT,
	"Rotate Up": USER_INPUT.ROTATE_UP,
	"Rotate Down": USER_INPUT.ROTATE_DOWN,
	# Control labels
	"Forward": USER_INPUT.FORWARD,
	"Backward": USER_INPUT.BACKWARD,
	"Strafe Left": USER_INPUT.STRAFE_LEFT,
	"Strafe Right": USER_INPUT.STRAFE_RIGHT,
	"Jump": USER_INPUT.JUMP, 
	"Crouch": USER_INPUT.CROUCH,
	"Sprint": USER_INPUT.SPRINT
}

const KEYCODE_STRING: String = "keycode"
const INPUT_TYPE_STRING:String = "input_type"
const INPUT_DESCRIPTION_STRING: String = "input_description"

const TEE_CAMERA: String = "TeeboxCamera"
const Camera: String = "Camera"
const PLAYER_FOV: String = "PLAYER_FOV"
const STATIONARY_FOV: String = "STATIONARY_FOV"
const IN_ADJUST: String = "IN_ADJUST"
const OUT_ADJUST: String = "OUT_ADJUST"
const PLAYER_FOCUS_OFFSET: String = "PLAYER_FOCUS_OFFSET"
const TEE_FOCUS_OFFSET: String = "TEE_FOCUS_OFFSET"

const Controls: String = "Controls"
const HORIZONTAL_AIM_SENSITIVITY: String = "HORIZONTAL_AIM_SENSITIVITY"
const HORIZONTAL_LOOK_SENSITIVITY: String = "HORIZONTAL_LOOK_SENSITIVITY"
const VERTICAL_AIM_SENSITIVITY: String = "VERTICAL_AIM_SENSITIVITY"
const VERTICAL_LOOK_SENSITIVITY: String = "VERTICAL_LOOK_SENSITIVITY"
const INVERT_HORIZONTAL: String = "INVERT_HORIZONTAL"
const INVERT_VERTICAL: String = "INVERT_VERTICAL"
const MAX_HORIZONTAL_ROTATION: String = "MAX_HORIZONTAL_ROTATION"
const MIN_HORIZONTAL_ROTATION: String = "MIN_HORIZONTAL_ROTATION"
const MAX_VERTICAL_ROTATION: String = "MAX_VERTICAL_ROTATION"
const MIN_VERTICAL_ROTATION: String = "MIN_VERTICAL_ROTATION"

const Display: String = "Display"
const PERFORMANCE: String = "PERFORMANCE"

const Unknown: String = "Unknown"

const SETTING_LABELS: Array[String] = [Camera, Controls, Display]

# TODO Move this to a MathConstants file

#https://gist.github.com/geekley/5bf72d3cbaa1da196545bee977ee8eda
# Public domain, as per The Unlicense. NO WARRANTY. See https://unlicense.org
## Minimum positive 64-bit floating-point number > 0.
## [br]0x0000000000000001
const FLOAT64_MIN_SUBNORMAL: float = 2.0**-1074 # ≈ 4.9406564584124654e-324
## Maximum positive 64-bit floating-point subnormal number (min possible value in binary exponent).
## [br]0x000FFFFFFFFFFFFF
const FLOAT64_MAX_SUBNORMAL: float = 2.0**-1022 - 2.0**-1074 # ≈ 2.2250738585072009e-308
## Minimum positive 64-bit floating-point normalized number (no leading 0 in binary significand).
## [br]0x0010000000000000
const FLOAT64_MIN_NORMAL: float = 2.0**-1022 # ≈ 2.2250738585072014e-308
## Maximum positive 64-bit floating-point number < 1 (≈ 0.9999999999999998889776975375).
## [br]0x3FEFFFFFFFFFFFFF
const FLOAT64_MAX_BELOW_1: float = 1 - 2.0**-53 # ≈ 0.9999999999999998889776975375
## Minimum positive 64-bit floating-point number > 1 (≈ 1.000000000000000222044604925).
## [br]0x3FF0000000000001
const FLOAT64_MIN_ABOVE_1: float = 1 + 2.0**-52 # ≈ 1.000000000000000222044604925
## Maximum positive 64-bit floating-point finite number.
## [br]0x7FEFFFFFFFFFFFFF
const FLOAT64_MAX: float = 2.0**1023 * (2 - 2.0**-52) # ≈ 1.7976931348623157e308

## Minimum positive 32-bit floating-point number > 0.
## [br]0x00000001
const FLOAT32_MIN_SUBNORMAL: float = 2.0**-149 # ≈ 1.4012984643e-45
## Maximum positive 32-bit floating-point subnormal number (min possible value in binary exponent).
## [br]0x007FFFFF
const FLOAT32_MAX_SUBNORMAL: float = 2.0**-126 - 2.0**-149 # ≈ 1.1754942107e-38
## Minimum positive 32-bit floating-point normalized number (no leading 0 in binary significand).
## [br]0x00800000
const FLOAT32_MIN_NORMAL: float = 2.0**-126 # ≈ 1.1754943508e-38
## Maximum positive 32-bit floating-point number < 1 (= 0.999999940395355224609375).
## [br]0x3F7FFFFF
const FLOAT32_MAX_BELOW_1: float = 1 - 2.0**-24 # = 0.999999940395355224609375
## Minimum positive 32-bit floating-point number > 1 (= 1.00000011920928955078125).
## [br]0x3F800001
const FLOAT32_MIN_ABOVE_1: float = 1 + 2.0**-23 # = 1.00000011920928955078125
## Maximum positive 32-bit floating-point finite number.
## [br]0x7F7FFFFF
const FLOAT32_MAX: float = 2.0**127 * (2 - 2.0**-23) # ≈ 3.4028234664e38

## Minimum positive 16-bit floating-point number > 0.
## [br]0x0001
const FLOAT16_MIN_SUBNORMAL: float = 2.0**-24 # = 0.000000059604644775390625
## Maximum positive 16-bit floating-point subnormal number (min possible value in binary exponent).
## [br]0x03FF
const FLOAT16_MAX_SUBNORMAL: float = 2.0**-14 - 2.0**-24 # = 0.000060975551605224609375
## Minimum positive 16-bit floating-point normalized number (no leading 0 in binary significand).
## [br]0x0400
const FLOAT16_MIN_NORMAL: float = 2.0**-14 # = 0.00006103515625
## Maximum positive 16-bit floating-point number < 1.
## [br]0x3BFF
const FLOAT16_MAX_BELOW_1: float = 1 - 2.0**-11 # = 0.99951171875
## Minimum positive 16-bit floating-point number > 1.
## [br]0x3C01
const FLOAT16_MIN_ABOVE_1: float = 1 + 2.0**-10 # = 1.0009765625
## Maximum positive 16-bit floating-point finite number.
## [br]0x7BFF
const FLOAT16_MAX: float = 2.0**15 * (2 - 2.0**-10) # = 65504

## True only if compiled with [code]precision=double[/code].
## This means floats in data structures such as Vector2 and Vector3 are 64-bit instead of 32-bit.
const IS_DOUBLE_PRECISION: bool = Vector2(1e39, 0).x != INF

## Minimum positive number > 0 used in engine floats. See IS_DOUBLE_PRECISION.
const FLOAT_MIN_SUBNORMAL: float = (FLOAT64_MIN_SUBNORMAL if IS_DOUBLE_PRECISION
else FLOAT32_MIN_SUBNORMAL)
## Maximum positive subnormal number used in engine floats. See IS_DOUBLE_PRECISION.
const FLOAT_MAX_SUBNORMAL: float = (FLOAT64_MAX_SUBNORMAL if IS_DOUBLE_PRECISION
else FLOAT32_MAX_SUBNORMAL)
## Minimum positive normalized number used in engine floats. See IS_DOUBLE_PRECISION.
const FLOAT_MIN_NORMAL: float = (FLOAT64_MIN_NORMAL if IS_DOUBLE_PRECISION
else FLOAT32_MIN_NORMAL)
## Maximum positive number < 1 used in engine floats. See IS_DOUBLE_PRECISION.
const FLOAT_MAX_BELOW_1: float = (FLOAT64_MAX_BELOW_1 if IS_DOUBLE_PRECISION
else FLOAT32_MAX_BELOW_1)
## Minimum positive number > 1 used in engine floats. See IS_DOUBLE_PRECISION.
const FLOAT_MIN_ABOVE_1: float = (FLOAT64_MIN_ABOVE_1 if IS_DOUBLE_PRECISION
else FLOAT32_MIN_ABOVE_1)
## Maximum positive finite number used in engine floats. See IS_DOUBLE_PRECISION.
const FLOAT_MAX: float = (FLOAT64_MAX if IS_DOUBLE_PRECISION
else FLOAT32_MAX)

## Maximum negative 64-bit signed integer number. Its positive cannot be represented in 64 bits.
## [br]0x8000000000000000
const INT64_NEGATIVE_LIMIT: int = -9223372036854775808
## Maximum positive 64-bit signed integer number. Use a minus to obtain its negative.
## [br]0x7FFFFFFFFFFFFFFF
const INT64_MAX: int = 9223372036854775807

## Maximum negative 32-bit signed integer number. Its positive cannot be represented in 32 bits.
## [br]0x80000000
const INT32_NEGATIVE_LIMIT: int = -2147483648
## Maximum positive 32-bit signed integer number. Use a minus to obtain its negative.
## [br]0x7FFFFFFF
const INT32_MAX: int = 2147483647
## Maximum 32-bit unsigned integer number.
## [br]0xFFFFFFFF
const UINT32_MAX: int = 4294967295

## Maximum negative 16-bit signed integer number. Its positive cannot be represented in 16 bits.
## [br]0x8000
const INT16_NEGATIVE_LIMIT: int = -32768
## Maximum positive 16-bit signed integer number. Use a minus to obtain its negative.
## [br]0x7FFF
const INT16_MAX: int = 32767
## Maximum 16-bit unsigned integer number.
## [br]0xFFFF
const UINT16_MAX: int = 65535

## Maximum negative 8-bit signed integer number. Its positive cannot be represented in 8 bits.
## [br]0x80
const INT8_NEGATIVE_LIMIT: int = -128
## Maximum positive 8-bit signed integer number. Use a minus to obtain its negative.
## [br]0x7F
const INT8_MAX: int = 127
## Maximum 8-bit unsigned integer number.
## [br]0xFF
const UINT8_MAX: int = 255


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
