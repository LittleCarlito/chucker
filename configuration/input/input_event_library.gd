extends Node

# TODO Eventually refactor to not be brute force
#		Should be able to programatically work through Mouse and Keyboard enums and create same effect as below

var KEYBOARD_INPUTS: Dictionary = {
	# A-Z keys
	KEY_A: self.A_KEY,
	KEY_B: self.B_KEY,
	KEY_C: self.C_KEY,
	KEY_D: self.D_KEY,
	KEY_E: self.E_KEY,
	KEY_F: self.F_KEY,
	KEY_G: self.G_KEY,
	KEY_H: self.H_KEY,
	KEY_I: self.I_KEY,
	KEY_J: self.J_KEY,
	KEY_K: self.K_KEY,
	KEY_L: self.L_KEY,
	KEY_M: self.M_KEY,
	KEY_N: self.N_KEY,
	KEY_O: self.O_KEY,
	KEY_P: self.P_KEY,
	KEY_Q: self.Q_KEY,
	KEY_R: self.R_KEY,
	KEY_S: self.S_KEY,
	KEY_T: self.T_KEY,
	KEY_U: self.U_KEY,
	KEY_V: self.V_KEY,
	KEY_W: self.W_KEY,
	KEY_X: self.X_KEY,
	KEY_Y: self.Y_KEY,
	KEY_Z: self.Z_KEY,
	# 0 - 9 keys
	KEY_0: self.ZERO_KEY,
	KEY_1: self.ONE_KEY,
	KEY_2: self.TWO_KEY,
	KEY_3: self.THREE_KEY,
	KEY_4: self.FOUR_KEY,
	KEY_5: self.FIVE_KEY,
	KEY_6: self.SIX_KEY,
	KEY_7: self.SEVEN_KEY,
	KEY_8: self.EIGHT_KEY,
	KEY_9: self.NINE_KEY,
	# Misc keys
	KEY_MINUS: self.MINUS_KEY,
	KEY_EQUAL: self.EQUAL_KEY,
	KEY_BRACKETLEFT: self.BRACKETLEFT_KEY,
	KEY_BRACKETRIGHT: self.BRACKETRIGHT_KEY,
	KEY_BACKSLASH: self.BACKSLASH_KEY,
	KEY_SEMICOLON: self.SEMICOLON_KEY,
	KEY_APOSTROPHE: self.APOSTROPHE_KEY,
	KEY_COMMA: self.COMMA_KEY,
	KEY_PERIOD: self.PERIOD_KEY,
	KEY_SLASH: self.SLASH_KEY,
	KEY_ESCAPE: self.ESCAPE_KEY,
	KEY_TAB: self.TAB_KEY,
	KEY_CAPSLOCK: self.CAPSLOCK_KEY,
	KEY_SHIFT: self.SHIFT_KEY,
	KEY_CTRL: self.CTRL_KEY,
	KEY_ALT: self.ALT_KEY,
	KEY_META: self.META_KEY,
	KEY_SPACE: self.SPACE_KEY,
	KEY_LEFT: self.LEFT_KEY,
	KEY_RIGHT: self.RIGHT_KEY,
	KEY_DOWN: self.DOWN_KEY,
	KEY_UP: self.UP_KEY,
	KEY_ENTER: self.ENTER_KEY,
	KEY_BACKSPACE: self.BACKSPACE_KEY,
	KEY_DELETE: self.DELETE_KEY,
	KEY_PAGEUP: self.PAGEUP_KEY,
	KEY_PAGEDOWN: self.PAGEDOWN_KEY,
	KEY_END: self.END_KEY,
	KEY_INSERT: self.INSERT_KEY,
	KEY_UNKNOWN: self.UNKOWN_KEY
}

var MOUSE_BUTTON_INPUTS: Dictionary = {
	MOUSE_BUTTON_LEFT: self.LEFT_MOUSE_BUTTON,
	MOUSE_BUTTON_RIGHT: self.RIGHT_MOUSE_BUTTON,
	MOUSE_BUTTON_MIDDLE: self.MIDDLE_MOUSE_BUTTON,
	MOUSE_BUTTON_XBUTTON1: self.XBUTTON1_MOUSE_BUTTON,
	MOUSE_BUTTON_XBUTTON2: self.XBUTTON2_MOUSE_BUTTON,
	MOUSE_BUTTON_WHEEL_UP: self.UP_MOUSE_BUTTON,
	MOUSE_BUTTON_WHEEL_DOWN: self.DOWN_MOUSE_BUTTON
}

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
var UNKOWN_KEY: InputEventKey = InputEventKey.new()
# Mouse buttons
var LEFT_MOUSE_BUTTON: InputEventMouseButton = InputEventMouseButton.new()
var RIGHT_MOUSE_BUTTON: InputEventMouseButton = InputEventMouseButton.new()
var MIDDLE_MOUSE_BUTTON: InputEventMouseButton = InputEventMouseButton.new()
var XBUTTON1_MOUSE_BUTTON: InputEventMouseButton = InputEventMouseButton.new()
var XBUTTON2_MOUSE_BUTTON: InputEventMouseButton = InputEventMouseButton.new()
var UP_MOUSE_BUTTON: InputEventMouseButton = InputEventMouseButton.new()
var DOWN_MOUSE_BUTTON: InputEventMouseButton = InputEventMouseButton.new()


func _ready() -> void:
	# A-Z keys
	self.A_KEY.physical_keycode = KEY_A
	self.B_KEY.physical_keycode = KEY_B
	self.C_KEY.physical_keycode = KEY_C
	self.D_KEY.physical_keycode = KEY_D
	self.E_KEY.physical_keycode = KEY_E
	self.F_KEY.physical_keycode = KEY_F
	self.G_KEY.physical_keycode = KEY_G
	self.H_KEY.physical_keycode = KEY_H
	self.I_KEY.physical_keycode = KEY_I
	self.J_KEY.physical_keycode = KEY_J
	self.K_KEY.physical_keycode = KEY_K
	self.L_KEY.physical_keycode = KEY_L
	self.M_KEY.physical_keycode = KEY_M
	self.N_KEY.physical_keycode = KEY_N
	self.O_KEY.physical_keycode = KEY_O
	self.P_KEY.physical_keycode = KEY_P
	self.Q_KEY.physical_keycode = KEY_Q
	self.R_KEY.physical_keycode = KEY_R
	self.S_KEY.physical_keycode = KEY_S
	self.T_KEY.physical_keycode = KEY_T
	self.U_KEY.physical_keycode = KEY_U
	self.V_KEY.physical_keycode = KEY_V
	self.W_KEY.physical_keycode = KEY_W
	self.X_KEY.physical_keycode = KEY_X
	self.Y_KEY.physical_keycode = KEY_Y
	self.Z_KEY.physical_keycode = KEY_Z
	# 0 - 9 keys
	self.ZERO_KEY.physical_keycode = KEY_0
	self.ONE_KEY.physical_keycode = KEY_1
	self.TWO_KEY.physical_keycode = KEY_2
	self.THREE_KEY.physical_keycode = KEY_3
	self.FOUR_KEY.physical_keycode = KEY_4
	self.FIVE_KEY.physical_keycode = KEY_5
	self.SIX_KEY.physical_keycode = KEY_6
	self.SEVEN_KEY.physical_keycode = KEY_7
	self.EIGHT_KEY.physical_keycode = KEY_8
	self.NINE_KEY.physical_keycode = KEY_9
	# Misc keys
	self.MINUS_KEY.physical_keycode = KEY_MINUS
	self.EQUAL_KEY.physical_keycode = KEY_EQUAL
	self.BRACKETLEFT_KEY.physical_keycode = KEY_BRACKETLEFT
	self.BRACKETRIGHT_KEY.physical_keycode = KEY_BRACKETRIGHT
	self.BACKSLASH_KEY.physical_keycode = KEY_BACKSLASH
	self.SEMICOLON_KEY.physical_keycode = KEY_SEMICOLON
	self.APOSTROPHE_KEY.physical_keycode = KEY_APOSTROPHE
	self.COMMA_KEY.physical_keycode = KEY_COMMA
	self.PERIOD_KEY.physical_keycode = KEY_PERIOD
	self.SLASH_KEY.physical_keycode = KEY_SLASH
	self.ESCAPE_KEY.physical_keycode = KEY_ESCAPE
	self.TAB_KEY.physical_keycode = KEY_TAB
	self.CAPSLOCK_KEY.physical_keycode = KEY_CAPSLOCK
	self.SHIFT_KEY.physical_keycode = KEY_SHIFT
	self.CTRL_KEY.physical_keycode = KEY_CTRL
	self.ALT_KEY.physical_keycode = KEY_ALT
	self.META_KEY.physical_keycode = KEY_META
	self.SPACE_KEY.physical_keycode = KEY_SPACE
	self.LEFT_KEY.physical_keycode = KEY_LEFT
	self.RIGHT_KEY.physical_keycode = KEY_RIGHT
	self.DOWN_KEY.physical_keycode = KEY_DOWN
	self.UP_KEY.physical_keycode = KEY_UP
	self.ENTER_KEY.physical_keycode = KEY_ENTER
	self.BACKSPACE_KEY.physical_keycode = KEY_BACKSPACE
	self.DELETE_KEY.physical_keycode = KEY_DELETE
	self.PAGEUP_KEY.physical_keycode = KEY_PAGEUP
	self.PAGEDOWN_KEY.physical_keycode = KEY_PAGEDOWN
	self.END_KEY.physical_keycode = KEY_END
	self.INSERT_KEY.physical_keycode = KEY_INSERT
	self.UNKOWN_KEY.physical_keycode = KEY_UNKNOWN
	# Mouse buttons
	self.LEFT_MOUSE_BUTTON.button_index = MOUSE_BUTTON_LEFT
	self.RIGHT_MOUSE_BUTTON.button_index = MOUSE_BUTTON_RIGHT
	self.MIDDLE_MOUSE_BUTTON.button_index = MOUSE_BUTTON_MIDDLE
	self.XBUTTON1_MOUSE_BUTTON.button_index = MOUSE_BUTTON_XBUTTON1
	self.XBUTTON2_MOUSE_BUTTON.button_index = MOUSE_BUTTON_XBUTTON2
	self.UP_MOUSE_BUTTON.button_index = MOUSE_BUTTON_WHEEL_UP
	self.DOWN_MOUSE_BUTTON.button_index = MOUSE_BUTTON_WHEEL_DOWN
