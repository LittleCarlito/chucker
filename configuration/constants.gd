extends Node
class_name CONSTANTS

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
	"Scorecard": self.USER_INPUT.SCORE,
	"Pause": self.USER_INPUT.PAUSE,
	# Action labels
	"Primary Action": self.USER_INPUT.PRIMARY,
	"Secondary Action": self.USER_INPUT.SECONDARY,
	"Pick Up": self.USER_INPUT.INTERACT,
	# Rotate labels
	"Rotate Left": self.USER_INPUT.ROTATE_LEFT,
	"Rotate Right": self.USER_INPUT.ROTATE_RIGHT,
	"Rotate Up": self.USER_INPUT.ROTATE_UP,
	"Rotate Down": self.USER_INPUT.ROTATE_DOWN,
	# Control labels
	"Forward": self.USER_INPUT.FORWARD,
	"Backward": self.USER_INPUT.BACKWARD,
	"Strafe Left": self.USER_INPUT.STRAFE_LEFT,
	"Strafe Right": self.USER_INPUT.STRAFE_RIGHT,
	"Jump": self.USER_INPUT.JUMP, 
	"Crouch": self.USER_INPUT.CROUCH,
	"Sprint": self.USER_INPUT.SPRINT
}

const KEYCODE_STRING: String = "keycode"
const INPUT_TYPE_STRING:String = "input_type"
const INPUT_DESCRIPTION_STRING: String = "input_description"

const TEE_CAMERA: String = "TeeboxCamera"
const Camera: String = "Camera"
const FOV: String = "FOV"
const IN_ADJUST: String = "IN_ADJUST"
const OUT_ADJUST: String = "OUT_ADJUST"

const Controls: String = "Controls"
const HORIZONTAL_AIM_SENSITIVITY: String = "HORIZONTAL_AIM_SENSITIVITY"
const HORIZONTAL_LOOK_SENSITIVITY: String = "HORIZONTAL_LOOK_SENSITIVITY"
const VERTICAL_AIM_SENSITIVITY: String = "VERTICAL_AIM_SENSITIVITY"
const VERTICAL_LOOK_SENSITIVITY: String = "VERTICAL_LOOK_SENSITIVITY"
const INVERT_HORIZONTAL: String = "INVERT_HORIZONTAL"
const INVERT_VERTICAL: String = "INVERT_VERTICAL"

const Display: String = "Display"
const PERFORMANCE: String = "PERFORMANCE"

const SETTING_LABELS: Array[String] = [CONSTANTS.Camera, CONSTANTS.Controls, CONSTANTS.Display]

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
