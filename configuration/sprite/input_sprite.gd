extends Node

const NO_MATCH_FOUND_LOG: String = "Matching icon for input \"%s\" could not be found; Returning blank keycap"
const UNSUPPORTED_TYPE: String = "%s recieved an unsupported event type \"%s\"; Returning value for Unknown"
const _EXTRACT_KEYCODE_STRING: String = "extract_keycode"
const _EXTRACT_INPUT_TYPE_STRING: String = "extract_input_type"

const INPUT_ICONS: Dictionary = {
	KEY_A: "res://resources/Sprites/ControlIcons/A_Keycap.png",
	KEY_B: "res://resources/Sprites/ControlIcons/B_Keycap.png",
	KEY_C: "res://resources/Sprites/ControlIcons/C_Keycap.png",
	KEY_D: "res://resources/Sprites/ControlIcons/D_Keycap.png",
	KEY_E: "res://resources/Sprites/ControlIcons/E_Keycap.png",
	KEY_F: "res://resources/Sprites/ControlIcons/F_Keycap.png",
	KEY_G: "res://resources/Sprites/ControlIcons/G_Keycap.png",
	KEY_H: "res://resources/Sprites/ControlIcons/H_Keycap.png",
	KEY_I: "res://resources/Sprites/ControlIcons/I_Keycap.png",
	KEY_J: "res://resources/Sprites/ControlIcons/J_Keycap.png",
	KEY_K: "res://resources/Sprites/ControlIcons/K_Keycap.png",
	KEY_L: "res://resources/Sprites/ControlIcons/L_Keycap.png",
	KEY_M: "res://resources/Sprites/ControlIcons/M_Keycap.png",
	KEY_N: "res://resources/Sprites/ControlIcons/N_Keycap.png",
	KEY_O: "res://resources/Sprites/ControlIcons/O_Keycap.png",
	KEY_P: "res://resources/Sprites/ControlIcons/P_Keycap.png",
	KEY_Q: "res://resources/Sprites/ControlIcons/Q_Keycap.png",
	KEY_R: "res://resources/Sprites/ControlIcons/R_Keycap.png",
	KEY_S: "res://resources/Sprites/ControlIcons/S_Keycap.png",
	KEY_T: "res://resources/Sprites/ControlIcons/T_Keycap.png",
	KEY_U: "res://resources/Sprites/ControlIcons/U_Keycap.png",
	KEY_V: "res://resources/Sprites/ControlIcons/V_Keycap.png",
	KEY_W: "res://resources/Sprites/ControlIcons/W_Keycap.png",
	KEY_X: "res://resources/Sprites/ControlIcons/X_Keycap.png",
	KEY_Y: "res://resources/Sprites/ControlIcons/Y_Keycap.png",
	KEY_Z: "res://resources/Sprites/ControlIcons/Z_Keycap.png",
	KEY_0: "res://resources/Sprites/ControlIcons/0_Keycap.png",
	KEY_1: "res://resources/Sprites/ControlIcons/1_Keycap.png",
	KEY_2: "res://resources/Sprites/ControlIcons/2_Keycap.png",
	KEY_3: "res://resources/Sprites/ControlIcons/3_Keycap.png",
	KEY_4: "res://resources/Sprites/ControlIcons/4_Keycap.png",
	KEY_5: "res://resources/Sprites/ControlIcons/5_Keycap.png",
	KEY_6: "res://resources/Sprites/ControlIcons/6_Keycap.png",
	KEY_7: "res://resources/Sprites/ControlIcons/7_Keycap.png",
	KEY_8: "res://resources/Sprites/ControlIcons/8_Keycap.png",
	KEY_9: "res://resources/Sprites/ControlIcons/9_Keycap.png",
	KEY_MINUS: "res://resources/Sprites/ControlIcons/Minus_Keycap.png",
	KEY_EQUAL: "res://resources/Sprites/ControlIcons/Equals_Keycap.png",
	KEY_BRACKETLEFT: "res://resources/Sprites/ControlIcons/LeftBracket_Keycap.png",
	KEY_BRACKETRIGHT: "res://resources/Sprites/ControlIcons/RightBracket_Keycap.png",
	KEY_BACKSLASH: "res://resources/Sprites/ControlIcons/BackSlash_Keycap.png",
	KEY_SEMICOLON: "res://resources/Sprites/ControlIcons/SemiColon_Keycap.png",
	KEY_APOSTROPHE: "res://resources/Sprites/ControlIcons/Quote_Keycap.png",
	KEY_COMMA: "res://resources/Sprites/ControlIcons/Comma_Keycap.png",
	KEY_PERIOD: "res://resources/Sprites/ControlIcons/Period_Keycap.png",
	KEY_SLASH: "res://resources/Sprites/ControlIcons/ForwardSlash_Keycap.png",
	KEY_ESCAPE: "res://resources/Sprites/ControlIcons/Escape_Keycap.png",
	KEY_TAB: "res://resources/Sprites/ControlIcons/Tab_Keycap.png",
	KEY_CAPSLOCK: "res://resources/Sprites/ControlIcons/CapsLock_Keycap.png",
	KEY_SHIFT: "res://resources/Sprites/ControlIcons/Shift_Keycap.png",
	KEY_CTRL: "res://resources/Sprites/ControlIcons/Control_Keycap.png",
	KEY_ALT: "res://resources/Sprites/ControlIcons/Alt_Keycap.png",
	KEY_META: "res://resources/Sprites/ControlIcons/Command_Keycap.png",
	KEY_SPACE: "res://resources/Sprites/ControlIcons/Space_Keycap.png",
	KEY_LEFT: "res://resources/Sprites/ControlIcons/Left_Keycap.png",
	KEY_RIGHT: "res://resources/Sprites/ControlIcons/Right_Keycap.png",
	KEY_DOWN: "res://resources/Sprites/ControlIcons/Down_Keycap.png",
	KEY_UP: "res://resources/Sprites/ControlIcons/Up_Keycap.png",
	KEY_ENTER: "res://resources/Sprites/ControlIcons/Enter_Keycap.png",
	KEY_BACKSPACE: "res://resources/Sprites/ControlIcons/Backspace_Keycap.png",
	KEY_DELETE: "res://resources/Sprites/ControlIcons/Delete_Keycap.png",
	KEY_PAGEUP: "res://resources/Sprites/ControlIcons/PageUp_Keycap.png",
	KEY_PAGEDOWN: "res://resources/Sprites/ControlIcons/PageDown_Keycap.png",
	KEY_END: "res://resources/Sprites/ControlIcons/End_Keycap.png",
	KEY_INSERT: "res://resources/Sprites/ControlIcons/Insert_Keycap.png",
	MOUSE_BUTTON_LEFT: "res://resources/Sprites/ControlIcons/LeftClick_Mouse.png",
	MOUSE_BUTTON_RIGHT: "res://resources/Sprites/ControlIcons/RightClick_Mouse.png",
	MOUSE_BUTTON_MIDDLE: "res://resources/Sprites/ControlIcons/MiddleClick_Mouse.png",
	MOUSE_BUTTON_XBUTTON1: "res://resources/Sprites/ControlIcons/5Click_Mouse.png",
	MOUSE_BUTTON_XBUTTON2: "res://resources/Sprites/ControlIcons/4Click_Mouse.png",
	MOUSE_BUTTON_WHEEL_UP: "res://resources/Sprites/ControlIcons/ScrollUp_Mouse.png",
	MOUSE_BUTTON_WHEEL_DOWN: "res://resources/Sprites/ControlIcons/ScrollDown_Mouse.png",
	KEY_UNKNOWN: "res://resources/Sprites/ControlIcons/Blank_Keycap.png"
}

var UNKNOWN_PATH: String = "res://resources/Sprites/ControlIcons/Blank_Keycap.png"
var UNKNOWN_TEXTURE: Texture2D = load(UNKNOWN_PATH)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func get_sprite(event: InputEvent) -> Texture2D:
	var possible_inputs: Array = InputEventLibrary.ALL_INPUTS.values()
	var matched_input_keycode: int = KEY_UNKNOWN
	var incoming_keycode: int = extract_keycode(event)
	for possible_input in possible_inputs:
		var possible_keycode: int = extract_keycode(possible_input)
		if possible_keycode == incoming_keycode:
			matched_input_keycode = possible_keycode
	if (incoming_keycode != KEY_UNKNOWN) && (matched_input_keycode == KEY_UNKNOWN):
		Logger.error(NO_MATCH_FOUND_LOG, [str(event)], self)
	return load(INPUT_ICONS.get(matched_input_keycode))

func extract_keycode(event: InputEvent) -> int:
	var return_value: int
	if event is InputEventMouseButton || event is InputEventJoypadButton:
		return_value = event.button_index
	elif event is InputEventKey:
		return_value = event.physical_keycode
	else:
		Logger.error(UNSUPPORTED_TYPE, [_EXTRACT_KEYCODE_STRING, str(event)], self)
		return_value = KEY_UNKNOWN
	return return_value

func extract_input_type(event: InputEvent) -> InputEventLibrary.INPUT_TYPE:
	var return_type: InputEventLibrary.INPUT_TYPE
	if event is InputEventMouseButton:
		return_type = InputEventLibrary.INPUT_TYPE.MOUSE
	elif event is InputEventKey:
		return_type = InputEventLibrary.INPUT_TYPE.KEYBOARD
	elif event is InputEventJoypadButton:
		return_type = InputEventLibrary.INPUT_TYPE.JOYSTICK
	else:
		Logger.error(UNSUPPORTED_TYPE, [_EXTRACT_INPUT_TYPE_STRING, str(event)], self)
		return_type = InputEventLibrary.INPUT_TYPE.UNKNOWN
	return return_type
