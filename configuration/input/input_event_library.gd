extends Node

const MISSING_KEY_LOG: String = "Incoming Dictionary was missing key \"%s\"; Using value \"%s\""
const NO_MATCHED_TYPE_LOG: String = "Incoming value \"%s\", to method \"%s\", could not be matched to an input type; Returning INPUT_TYPE.UNKNOWN"
const _CONVERT_KEYCODE_STRING: String = "convert_keycode_to_input_type"
const _CONVERT_INT_STRING: String = "convert_int_to_input_type"
const UNSUPPORTED_TYPE_LOG: String = "ControlSetting couldn't be converted to an InputEvent as it is not of a supported type; \"%s\""
const NO_MATCHING_EVENT_LOG: String = "Keycode \"%s\" did not have a match in ALL_INPUTS and could not be converted to an InputEvent"

const MOUSE_TYPE: String = "MOUSE"
const KEYBOARD_TYPE: String = "KEYBOARD"
const UNKNOWN_TYPE: String = "UNKNOWN"

enum INPUT_TYPE {
	MOUSE,
	KEYBOARD,
	JOYSTICK,
	UNKNOWN
}

func get_type_string(incoming_type: INPUT_TYPE) -> String:
	var return_string: String
	match incoming_type:
		INPUT_TYPE.MOUSE:
			return_string = MOUSE_TYPE
		INPUT_TYPE.KEYBOARD:
			return_string = KEYBOARD_TYPE
		_:
			return_string = UNKNOWN_TYPE
	return return_string

# INPUT_TYPE conversions
func convert_keycode_to_input_type(keycode: int) -> INPUT_TYPE:
	var return_type: INPUT_TYPE
	if KEYBOARD_INPUTS.has(keycode):
		return_type = INPUT_TYPE.KEYBOARD
	elif MOUSE_BUTTON_INPUTS.has(keycode):
		return_type = INPUT_TYPE.MOUSE
	else:
		Logger.error(NO_MATCHED_TYPE_LOG, [str(keycode), _CONVERT_KEYCODE_STRING], self)
		return_type = INPUT_TYPE.UNKNOWN
	return return_type

func convert_int_to_input_type(int_value: int) -> INPUT_TYPE:
	var return_type: INPUT_TYPE
	match int_value:
		0:
			return_type = INPUT_TYPE.MOUSE
		1:
			return_type = INPUT_TYPE.KEYBOARD
		2:
			return_type = INPUT_TYPE.JOYSTICK
		_:
			Logger.error(NO_MATCHED_TYPE_LOG, [str(int_value), _CONVERT_INT_STRING], self)
			return_type = INPUT_TYPE.UNKNOWN
	return return_type

# ControlSetting conversions
func convert_event_to_control_setting(event: InputEvent) -> ControlSetting:
	var keycode: int = InputSprite.extract_keycode(event)
	var input_type: INPUT_TYPE = InputSprite.extract_input_type(event)
	var return_setting: ControlSetting = ControlSetting.new(keycode, input_type, event.as_text())
	return return_setting

func convert_dictionary_to_control_setting(incoming_dictionary: Dictionary) -> ControlSetting:
	# Get setting items from dictionary
	var keycode: int = incoming_dictionary.get(CONSTANTS.KEYCODE_STRING)
	var input_type_int := incoming_dictionary.get(CONSTANTS.INPUT_TYPE_STRING) as int
	var input_description: String = incoming_dictionary.get(CONSTANTS.INPUT_DESCRIPTION_STRING)
	if keycode == null:
		keycode = KEY_UNKNOWN
		Logger.error(MISSING_KEY_LOG, [CONSTANTS.KEYCODE_STRING, str(keycode)], self)
	if input_type_int == null:
		input_type_int = INPUT_TYPE.UNKNOWN
		Logger.error(MISSING_KEY_LOG, [CONSTANTS.KEYCODE_STRING, str(input_type_int)], self)
	if input_description == null:
		input_description = UNKNOWN_STRING
		Logger.error(MISSING_KEY_LOG, [CONSTANTS.KEYCODE_STRING, input_description], self)
	# Convert int back to enum
	var input_type: INPUT_TYPE = convert_int_to_input_type(input_type_int)
	return ControlSetting.new(keycode, input_type, input_description)

func convert_controlsetting_to_dictionary(control_setting: ControlSetting) -> Dictionary:
	var return_dictionary = {}
	return_dictionary.get_or_add(CONSTANTS.KEYCODE_STRING, control_setting.keycode)
	return_dictionary.get_or_add(CONSTANTS.INPUT_TYPE_STRING, str(control_setting.inputType))
	return_dictionary.get_or_add(CONSTANTS.INPUT_DESCRIPTION_STRING, control_setting.inputDescription)
	return return_dictionary

# InputEvent conversions
func convert_control_setting_to_input_event(control_setting: ControlSetting) -> InputEvent:
	var return_event: InputEvent
	match control_setting.inputType:
		INPUT_TYPE.MOUSE:
			return_event = MOUSE_BUTTON_INPUTS.get(control_setting.keycode)
		INPUT_TYPE.KEYBOARD:
			return_event = KEYBOARD_INPUTS.get(control_setting.keycode)
		_:
			Logger.error(UNSUPPORTED_TYPE_LOG, [str(control_setting)], self)
			return_event = UNKNOWN_KEY
	return return_event

func convert_keycode_to_input_event(keycode: int) -> InputEvent:
	var return_event: InputEvent = ALL_INPUTS.get(keycode, null)
	if return_event == null:
		Logger.error(NO_MATCHING_EVENT_LOG, [str(keycode)], self)
		return_event = UNKNOWN_KEY
	return return_event

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _ready() -> void:
	# A-Z keys
	A_KEY.physical_keycode = KEY_A
	B_KEY.physical_keycode = KEY_B
	C_KEY.physical_keycode = KEY_C
	D_KEY.physical_keycode = KEY_D
	E_KEY.physical_keycode = KEY_E
	F_KEY.physical_keycode = KEY_F
	G_KEY.physical_keycode = KEY_G
	H_KEY.physical_keycode = KEY_H
	I_KEY.physical_keycode = KEY_I
	J_KEY.physical_keycode = KEY_J
	K_KEY.physical_keycode = KEY_K
	L_KEY.physical_keycode = KEY_L
	M_KEY.physical_keycode = KEY_M
	N_KEY.physical_keycode = KEY_N
	O_KEY.physical_keycode = KEY_O
	P_KEY.physical_keycode = KEY_P
	Q_KEY.physical_keycode = KEY_Q
	R_KEY.physical_keycode = KEY_R
	S_KEY.physical_keycode = KEY_S
	T_KEY.physical_keycode = KEY_T
	U_KEY.physical_keycode = KEY_U
	V_KEY.physical_keycode = KEY_V
	W_KEY.physical_keycode = KEY_W
	X_KEY.physical_keycode = KEY_X
	Y_KEY.physical_keycode = KEY_Y
	Z_KEY.physical_keycode = KEY_Z
	# 0 - 9 keys
	ZERO_KEY.physical_keycode = KEY_0
	ONE_KEY.physical_keycode = KEY_1
	TWO_KEY.physical_keycode = KEY_2
	THREE_KEY.physical_keycode = KEY_3
	FOUR_KEY.physical_keycode = KEY_4
	FIVE_KEY.physical_keycode = KEY_5
	SIX_KEY.physical_keycode = KEY_6
	SEVEN_KEY.physical_keycode = KEY_7
	EIGHT_KEY.physical_keycode = KEY_8
	NINE_KEY.physical_keycode = KEY_9
	# Misc keys
	MINUS_KEY.physical_keycode = KEY_MINUS
	EQUAL_KEY.physical_keycode = KEY_EQUAL
	BRACKETLEFT_KEY.physical_keycode = KEY_BRACKETLEFT
	BRACKETRIGHT_KEY.physical_keycode = KEY_BRACKETRIGHT
	BACKSLASH_KEY.physical_keycode = KEY_BACKSLASH
	SEMICOLON_KEY.physical_keycode = KEY_SEMICOLON
	APOSTROPHE_KEY.physical_keycode = KEY_APOSTROPHE
	COMMA_KEY.physical_keycode = KEY_COMMA
	PERIOD_KEY.physical_keycode = KEY_PERIOD
	SLASH_KEY.physical_keycode = KEY_SLASH
	ESCAPE_KEY.physical_keycode = KEY_ESCAPE
	TAB_KEY.physical_keycode = KEY_TAB
	CAPSLOCK_KEY.physical_keycode = KEY_CAPSLOCK
	SHIFT_KEY.physical_keycode = KEY_SHIFT
	CTRL_KEY.physical_keycode = KEY_CTRL
	ALT_KEY.physical_keycode = KEY_ALT
	META_KEY.physical_keycode = KEY_META
	SPACE_KEY.physical_keycode = KEY_SPACE
	LEFT_KEY.physical_keycode = KEY_LEFT
	RIGHT_KEY.physical_keycode = KEY_RIGHT
	DOWN_KEY.physical_keycode = KEY_DOWN
	UP_KEY.physical_keycode = KEY_UP
	ENTER_KEY.physical_keycode = KEY_ENTER
	BACKSPACE_KEY.physical_keycode = KEY_BACKSPACE
	DELETE_KEY.physical_keycode = KEY_DELETE
	PAGEUP_KEY.physical_keycode = KEY_PAGEUP
	PAGEDOWN_KEY.physical_keycode = KEY_PAGEDOWN
	END_KEY.physical_keycode = KEY_END
	INSERT_KEY.physical_keycode = KEY_INSERT
	UNKNOWN_KEY.physical_keycode = KEY_UNKNOWN
	# Mouse buttons
	LEFT_MOUSE_BUTTON.button_index = MOUSE_BUTTON_LEFT
	RIGHT_MOUSE_BUTTON.button_index = MOUSE_BUTTON_RIGHT
	MIDDLE_MOUSE_BUTTON.button_index = MOUSE_BUTTON_MIDDLE
	XBUTTON1_MOUSE_BUTTON.button_index = MOUSE_BUTTON_XBUTTON1
	XBUTTON2_MOUSE_BUTTON.button_index = MOUSE_BUTTON_XBUTTON2
	UP_MOUSE_BUTTON.button_index = MOUSE_BUTTON_WHEEL_UP
	DOWN_MOUSE_BUTTON.button_index = MOUSE_BUTTON_WHEEL_DOWN

# A - Z keys
var A_KEY: InputEventKey = InputEventKey.new()
var B_KEY: InputEventKey = InputEventKey.new()
var C_KEY: InputEventKey = InputEventKey.new()
var D_KEY: InputEventKey = InputEventKey.new()
var E_KEY: InputEventKey = InputEventKey.new()
var F_KEY: InputEventKey = InputEventKey.new()
var G_KEY: InputEventKey = InputEventKey.new()
var H_KEY: InputEventKey = InputEventKey.new()
var I_KEY: InputEventKey = InputEventKey.new()
var J_KEY: InputEventKey = InputEventKey.new()
var K_KEY: InputEventKey = InputEventKey.new()
var L_KEY: InputEventKey = InputEventKey.new()
var M_KEY: InputEventKey = InputEventKey.new()
var N_KEY: InputEventKey = InputEventKey.new()
var O_KEY: InputEventKey = InputEventKey.new()
var P_KEY: InputEventKey = InputEventKey.new()
var Q_KEY: InputEventKey = InputEventKey.new()
var R_KEY: InputEventKey = InputEventKey.new()
var S_KEY: InputEventKey = InputEventKey.new()
var T_KEY: InputEventKey = InputEventKey.new()
var U_KEY: InputEventKey = InputEventKey.new()
var V_KEY: InputEventKey = InputEventKey.new()
var W_KEY: InputEventKey = InputEventKey.new()
var X_KEY: InputEventKey = InputEventKey.new()
var Y_KEY: InputEventKey = InputEventKey.new()
var Z_KEY: InputEventKey = InputEventKey.new()
# 0 - 9 keys
var ZERO_KEY: InputEventKey = InputEventKey.new()
var ONE_KEY: InputEventKey = InputEventKey.new()
var TWO_KEY: InputEventKey = InputEventKey.new()
var THREE_KEY: InputEventKey = InputEventKey.new()
var FOUR_KEY: InputEventKey = InputEventKey.new()
var FIVE_KEY: InputEventKey = InputEventKey.new()
var SIX_KEY: InputEventKey = InputEventKey.new()
var SEVEN_KEY: InputEventKey = InputEventKey.new()
var EIGHT_KEY: InputEventKey = InputEventKey.new()
var NINE_KEY: InputEventKey = InputEventKey.new()
# Misc keys
var MINUS_KEY: InputEventKey = InputEventKey.new()
var EQUAL_KEY: InputEventKey = InputEventKey.new()
var BRACKETLEFT_KEY: InputEventKey = InputEventKey.new()
var BRACKETRIGHT_KEY: InputEventKey = InputEventKey.new()
var BACKSLASH_KEY: InputEventKey = InputEventKey.new()
var SEMICOLON_KEY: InputEventKey = InputEventKey.new()
var APOSTROPHE_KEY: InputEventKey = InputEventKey.new()
var COMMA_KEY: InputEventKey = InputEventKey.new()
var PERIOD_KEY: InputEventKey = InputEventKey.new()
var SLASH_KEY: InputEventKey = InputEventKey.new()
var ESCAPE_KEY: InputEventKey = InputEventKey.new()
var TAB_KEY: InputEventKey = InputEventKey.new()
var CAPSLOCK_KEY: InputEventKey = InputEventKey.new()
var SHIFT_KEY: InputEventKey = InputEventKey.new()
var CTRL_KEY: InputEventKey = InputEventKey.new()
var ALT_KEY: InputEventKey = InputEventKey.new()
var META_KEY: InputEventKey = InputEventKey.new()
var SPACE_KEY: InputEventKey = InputEventKey.new()
var LEFT_KEY: InputEventKey = InputEventKey.new()
var RIGHT_KEY: InputEventKey = InputEventKey.new()
var DOWN_KEY: InputEventKey = InputEventKey.new()
var UP_KEY: InputEventKey = InputEventKey.new()
var ENTER_KEY: InputEventKey = InputEventKey.new()
var BACKSPACE_KEY: InputEventKey = InputEventKey.new()
var DELETE_KEY: InputEventKey = InputEventKey.new()
var PAGEUP_KEY: InputEventKey = InputEventKey.new()
var PAGEDOWN_KEY: InputEventKey = InputEventKey.new()
var END_KEY: InputEventKey = InputEventKey.new()
var INSERT_KEY: InputEventKey = InputEventKey.new()
var UNKNOWN_KEY: InputEventKey = InputEventKey.new()
# Mouse buttons
var LEFT_MOUSE_BUTTON: InputEventMouseButton = InputEventMouseButton.new()
var RIGHT_MOUSE_BUTTON: InputEventMouseButton = InputEventMouseButton.new()
var MIDDLE_MOUSE_BUTTON: InputEventMouseButton = InputEventMouseButton.new()
var XBUTTON1_MOUSE_BUTTON: InputEventMouseButton = InputEventMouseButton.new()
var XBUTTON2_MOUSE_BUTTON: InputEventMouseButton = InputEventMouseButton.new()
var UP_MOUSE_BUTTON: InputEventMouseButton = InputEventMouseButton.new()
var DOWN_MOUSE_BUTTON: InputEventMouseButton = InputEventMouseButton.new()

const UNKNOWN_STRING: String = "Unknown input"
var UNKNOWN_CONTROL: ControlSetting = ControlSetting.new(KEY_UNKNOWN, INPUT_TYPE.KEYBOARD, UNKNOWN_STRING)

var KEYBOARD_INPUTS: Dictionary = {
	# A-Z keys
	KEY_A: A_KEY,
	KEY_B: B_KEY,
	KEY_C: C_KEY,
	KEY_D: D_KEY,
	KEY_E: E_KEY,
	KEY_F: F_KEY,
	KEY_G: G_KEY,
	KEY_H: H_KEY,
	KEY_I: I_KEY,
	KEY_J: J_KEY,
	KEY_K: K_KEY,
	KEY_L: L_KEY,
	KEY_M: M_KEY,
	KEY_N: N_KEY,
	KEY_O: O_KEY,
	KEY_P: P_KEY,
	KEY_Q: Q_KEY,
	KEY_R: R_KEY,
	KEY_S: S_KEY,
	KEY_T: T_KEY,
	KEY_U: U_KEY,
	KEY_V: V_KEY,
	KEY_W: W_KEY,
	KEY_X: X_KEY,
	KEY_Y: Y_KEY,
	KEY_Z: Z_KEY,
	# 0 - 9 keys
	KEY_0: ZERO_KEY,
	KEY_1: ONE_KEY,
	KEY_2: TWO_KEY,
	KEY_3: THREE_KEY,
	KEY_4: FOUR_KEY,
	KEY_5: FIVE_KEY,
	KEY_6: SIX_KEY,
	KEY_7: SEVEN_KEY,
	KEY_8: EIGHT_KEY,
	KEY_9: NINE_KEY,
	# Misc keys
	KEY_MINUS: MINUS_KEY,
	KEY_EQUAL: EQUAL_KEY,
	KEY_BRACKETLEFT: BRACKETLEFT_KEY,
	KEY_BRACKETRIGHT: BRACKETRIGHT_KEY,
	KEY_BACKSLASH: BACKSLASH_KEY,
	KEY_SEMICOLON: SEMICOLON_KEY,
	KEY_APOSTROPHE: APOSTROPHE_KEY,
	KEY_COMMA: COMMA_KEY,
	KEY_PERIOD: PERIOD_KEY,
	KEY_SLASH: SLASH_KEY,
	KEY_ESCAPE: ESCAPE_KEY,
	KEY_TAB: TAB_KEY,
	KEY_CAPSLOCK: CAPSLOCK_KEY,
	KEY_SHIFT: SHIFT_KEY,
	KEY_CTRL: CTRL_KEY,
	KEY_ALT: ALT_KEY,
	KEY_META: META_KEY,
	KEY_SPACE: SPACE_KEY,
	KEY_LEFT: LEFT_KEY,
	KEY_RIGHT: RIGHT_KEY,
	KEY_DOWN: DOWN_KEY,
	KEY_UP: UP_KEY,
	KEY_ENTER: ENTER_KEY,
	KEY_BACKSPACE: BACKSPACE_KEY,
	KEY_DELETE: DELETE_KEY,
	KEY_PAGEUP: PAGEUP_KEY,
	KEY_PAGEDOWN: PAGEDOWN_KEY,
	KEY_END: END_KEY,
	KEY_INSERT: INSERT_KEY,
	KEY_UNKNOWN: UNKNOWN_KEY
}

var MOUSE_BUTTON_INPUTS: Dictionary = {
	MOUSE_BUTTON_LEFT: LEFT_MOUSE_BUTTON,
	MOUSE_BUTTON_RIGHT: RIGHT_MOUSE_BUTTON,
	MOUSE_BUTTON_MIDDLE: MIDDLE_MOUSE_BUTTON,
	MOUSE_BUTTON_XBUTTON1: XBUTTON1_MOUSE_BUTTON,
	MOUSE_BUTTON_XBUTTON2: XBUTTON2_MOUSE_BUTTON,
	MOUSE_BUTTON_WHEEL_UP: UP_MOUSE_BUTTON,
	MOUSE_BUTTON_WHEEL_DOWN: DOWN_MOUSE_BUTTON
}

var ALL_INPUTS: Dictionary = {
		# A-Z keys
	KEY_A: A_KEY,
	KEY_B: B_KEY,
	KEY_C: C_KEY,
	KEY_D: D_KEY,
	KEY_E: E_KEY,
	KEY_F: F_KEY,
	KEY_G: G_KEY,
	KEY_H: H_KEY,
	KEY_I: I_KEY,
	KEY_J: J_KEY,
	KEY_K: K_KEY,
	KEY_L: L_KEY,
	KEY_M: M_KEY,
	KEY_N: N_KEY,
	KEY_O: O_KEY,
	KEY_P: P_KEY,
	KEY_Q: Q_KEY,
	KEY_R: R_KEY,
	KEY_S: S_KEY,
	KEY_T: T_KEY,
	KEY_U: U_KEY,
	KEY_V: V_KEY,
	KEY_W: W_KEY,
	KEY_X: X_KEY,
	KEY_Y: Y_KEY,
	KEY_Z: Z_KEY,
	# 0 - 9 keys
	KEY_0: ZERO_KEY,
	KEY_1: ONE_KEY,
	KEY_2: TWO_KEY,
	KEY_3: THREE_KEY,
	KEY_4: FOUR_KEY,
	KEY_5: FIVE_KEY,
	KEY_6: SIX_KEY,
	KEY_7: SEVEN_KEY,
	KEY_8: EIGHT_KEY,
	KEY_9: NINE_KEY,
	# Misc keys
	KEY_MINUS: MINUS_KEY,
	KEY_EQUAL: EQUAL_KEY,
	KEY_BRACKETLEFT: BRACKETLEFT_KEY,
	KEY_BRACKETRIGHT: BRACKETRIGHT_KEY,
	KEY_BACKSLASH: BACKSLASH_KEY,
	KEY_SEMICOLON: SEMICOLON_KEY,
	KEY_APOSTROPHE: APOSTROPHE_KEY,
	KEY_COMMA: COMMA_KEY,
	KEY_PERIOD: PERIOD_KEY,
	KEY_SLASH: SLASH_KEY,
	KEY_ESCAPE: ESCAPE_KEY,
	KEY_TAB: TAB_KEY,
	KEY_CAPSLOCK: CAPSLOCK_KEY,
	KEY_SHIFT: SHIFT_KEY,
	KEY_CTRL: CTRL_KEY,
	KEY_ALT: ALT_KEY,
	KEY_META: META_KEY,
	KEY_SPACE: SPACE_KEY,
	KEY_LEFT: LEFT_KEY,
	KEY_RIGHT: RIGHT_KEY,
	KEY_DOWN: DOWN_KEY,
	KEY_UP: UP_KEY,
	KEY_ENTER: ENTER_KEY,
	KEY_BACKSPACE: BACKSPACE_KEY,
	KEY_DELETE: DELETE_KEY,
	KEY_PAGEUP: PAGEUP_KEY,
	KEY_PAGEDOWN: PAGEDOWN_KEY,
	KEY_END: END_KEY,
	KEY_INSERT: INSERT_KEY,
	KEY_UNKNOWN: UNKNOWN_KEY,
	# Mouse inputs
	MOUSE_BUTTON_LEFT: LEFT_MOUSE_BUTTON,
	MOUSE_BUTTON_RIGHT: RIGHT_MOUSE_BUTTON,
	MOUSE_BUTTON_MIDDLE: MIDDLE_MOUSE_BUTTON,
	MOUSE_BUTTON_XBUTTON1: XBUTTON1_MOUSE_BUTTON,
	MOUSE_BUTTON_XBUTTON2: XBUTTON2_MOUSE_BUTTON,
	MOUSE_BUTTON_WHEEL_UP: UP_MOUSE_BUTTON,
	MOUSE_BUTTON_WHEEL_DOWN: DOWN_MOUSE_BUTTON
}
