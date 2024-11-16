extends Node

const NO_MATCH_FOUND_LOG: String = "Matching icon for input \"%s\" could not be found"
const UNSUPPORTED_TYPE: String = "Event was unsupported type \"%s\""

const DISK = {
	"SCENE": "res://assets/items/ChuckDisk.tscn",
	"PATH_SCENE": "res://assets/items/PathDisk.tscn"
}

const MESH = {
	"CHARGE_SCENE": "res://assets/items/ChargeDisk.tscn",
	"PULL_SCENE": "res://assets/items/PullDisk.tscn"
}

const CAMERA = {
	# This needs to match the camera node name in ChuckTee scene
	"TEE_CAMERA": "TeeboxCamera"
}

# TODO Verify that every caller is using InputEventLibrary as the key and not KeyCode
var INPUT_ICONS: Dictionary = {
	InputEventLibrary.A_KEY: "res://resources/Sprites/ControlIcons/A_Keycap.png",
	InputEventLibrary.B_KEY: "res://resources/Sprites/ControlIcons/B_Keycap.png",
	InputEventLibrary.C_KEY: "res://resources/Sprites/ControlIcons/C_Keycap.png",
	InputEventLibrary.D_KEY: "res://resources/Sprites/ControlIcons/D_Keycap.png",
	InputEventLibrary.E_KEY: "res://resources/Sprites/ControlIcons/E_Keycap.png",
	InputEventLibrary.F_KEY: "res://resources/Sprites/ControlIcons/F_Keycap.png",
	InputEventLibrary.G_KEY: "res://resources/Sprites/ControlIcons/G_Keycap.png",
	InputEventLibrary.H_KEY: "res://resources/Sprites/ControlIcons/H_Keycap.png",
	InputEventLibrary.I_KEY: "res://resources/Sprites/ControlIcons/I_Keycap.png",
	InputEventLibrary.J_KEY: "res://resources/Sprites/ControlIcons/J_Keycap.png",
	InputEventLibrary.K_KEY: "res://resources/Sprites/ControlIcons/K_Keycap.png",
	InputEventLibrary.L_KEY: "res://resources/Sprites/ControlIcons/L_Keycap.png",
	InputEventLibrary.M_KEY: "res://resources/Sprites/ControlIcons/M_Keycap.png",
	InputEventLibrary.N_KEY: "res://resources/Sprites/ControlIcons/N_Keycap.png",
	InputEventLibrary.O_KEY: "res://resources/Sprites/ControlIcons/O_Keycap.png",
	InputEventLibrary.P_KEY: "res://resources/Sprites/ControlIcons/P_Keycap.png",
	InputEventLibrary.Q_KEY: "res://resources/Sprites/ControlIcons/Q_Keycap.png",
	InputEventLibrary.R_KEY: "res://resources/Sprites/ControlIcons/R_Keycap.png",
	InputEventLibrary.S_KEY: "res://resources/Sprites/ControlIcons/S_Keycap.png",
	InputEventLibrary.T_KEY: "res://resources/Sprites/ControlIcons/T_Keycap.png",
	InputEventLibrary.U_KEY: "res://resources/Sprites/ControlIcons/U_Keycap.png",
	InputEventLibrary.V_KEY: "res://resources/Sprites/ControlIcons/V_Keycap.png",
	InputEventLibrary.W_KEY: "res://resources/Sprites/ControlIcons/W_Keycap.png",
	InputEventLibrary.X_KEY: "res://resources/Sprites/ControlIcons/X_Keycap.png",
	InputEventLibrary.Y_KEY: "res://resources/Sprites/ControlIcons/Y_Keycap.png",
	InputEventLibrary.Z_KEY: "res://resources/Sprites/ControlIcons/Z_Keycap.png",
	InputEventLibrary.ZERO_KEY: "res://resources/Sprites/ControlIcons/0_Keycap.png",
	InputEventLibrary.ONE_KEY: "res://resources/Sprites/ControlIcons/1_Keycap.png",
	InputEventLibrary.TWO_KEY: "res://resources/Sprites/ControlIcons/2_Keycap.png",
	InputEventLibrary.THREE_KEY: "res://resources/Sprites/ControlIcons/3_Keycap.png",
	InputEventLibrary.FOUR_KEY: "res://resources/Sprites/ControlIcons/4_Keycap.png",
	InputEventLibrary.FIVE_KEY: "res://resources/Sprites/ControlIcons/5_Keycap.png",
	InputEventLibrary.SIX_KEY: "res://resources/Sprites/ControlIcons/6_Keycap.png",
	InputEventLibrary.SEVEN_KEY: "res://resources/Sprites/ControlIcons/7_Keycap.png",
	InputEventLibrary.EIGHT_KEY: "res://resources/Sprites/ControlIcons/8_Keycap.png",
	InputEventLibrary.NINE_KEY: "res://resources/Sprites/ControlIcons/9_Keycap.png",
	InputEventLibrary.MINUS_KEY: "res://resources/Sprites/ControlIcons/Minus_Keycap.png",
	InputEventLibrary.EQUAL_KEY: "res://resources/Sprites/ControlIcons/Equals_Keycap.png",
	InputEventLibrary.BRACKETLEFT_KEY: "res://resources/Sprites/ControlIcons/LeftBracket_Keycap.png",
	InputEventLibrary.BRACKETRIGHT_KEY: "res://resources/Sprites/ControlIcons/RightBracket_Keycap.png",
	InputEventLibrary.BACKSLASH_KEY: "res://resources/Sprites/ControlIcons/BackSlash_Keycap.png",
	InputEventLibrary.SEMICOLON_KEY: "res://resources/Sprites/ControlIcons/SemiColon_Keycap.png",
	InputEventLibrary.APOSTROPHE_KEY: "res://resources/Sprites/ControlIcons/Quote_Keycap.png",
	InputEventLibrary.COMMA_KEY: "res://resources/Sprites/ControlIcons/Comma_Keycap.png",
	InputEventLibrary.PERIOD_KEY: "res://resources/Sprites/ControlIcons/Period_Keycap.png",
	InputEventLibrary.SLASH_KEY: "res://resources/Sprites/ControlIcons/ForwardSlash_Keycap.png",
	InputEventLibrary.ESCAPE_KEY: "res://resources/Sprites/ControlIcons/Escape_Keycap.png",
	InputEventLibrary.TAB_KEY: "res://resources/Sprites/ControlIcons/Tab_Keycap.png",
	InputEventLibrary.CAPSLOCK_KEY: "res://resources/Sprites/ControlIcons/CapsLock_Keycap.png",
	InputEventLibrary.SHIFT_KEY: "res://resources/Sprites/ControlIcons/Shift_Keycap.png",
	InputEventLibrary.CTRL_KEY: "res://resources/Sprites/ControlIcons/Control_Keycap.png",
	InputEventLibrary.ALT_KEY: "res://resources/Sprites/ControlIcons/Alt_Keycap.png",
	InputEventLibrary.META_KEY: "res://resources/Sprites/ControlIcons/Command_Keycap.png",
	InputEventLibrary.SPACE_KEY: "res://resources/Sprites/ControlIcons/Space_Keycap.png",
	InputEventLibrary.LEFT_KEY: "res://resources/Sprites/ControlIcons/Left_Keycap.png",
	InputEventLibrary.RIGHT_KEY: "res://resources/Sprites/ControlIcons/Right_Keycap.png",
	InputEventLibrary.DOWN_KEY: "res://resources/Sprites/ControlIcons/Down_Keycap.png",
	InputEventLibrary.UP_KEY: "res://resources/Sprites/ControlIcons/Up_Keycap.png",
	InputEventLibrary.ENTER_KEY: "res://resources/Sprites/ControlIcons/Enter_Keycap.png",
	InputEventLibrary.BACKSPACE_KEY: "res://resources/Sprites/ControlIcons/Backspace_Keycap.png",
	InputEventLibrary.DELETE_KEY: "res://resources/Sprites/ControlIcons/Delete_Keycap.png",
	InputEventLibrary.PAGEUP_KEY: "res://resources/Sprites/ControlIcons/PageUp_Keycap.png",
	InputEventLibrary.PAGEDOWN_KEY: "res://resources/Sprites/ControlIcons/PageDown_Keycap.png",
	InputEventLibrary.END_KEY: "res://resources/Sprites/ControlIcons/End_Keycap.png",
	InputEventLibrary.INSERT_KEY: "res://resources/Sprites/ControlIcons/Insert_Keycap.png",
	InputEventLibrary.LEFT_MOUSE_BUTTON: "res://resources/Sprites/ControlIcons/LeftClick_Mouse.png",
	InputEventLibrary.RIGHT_MOUSE_BUTTON: "res://resources/Sprites/ControlIcons/RightClick_Mouse.png",
	InputEventLibrary.MIDDLE_MOUSE_BUTTON: "res://resources/Sprites/ControlIcons/MiddleClick_Mouse.png",
	InputEventLibrary.XBUTTON1_MOUSE_BUTTON: "res://resources/Sprites/ControlIcons/5Click_Mouse.png",
	InputEventLibrary.XBUTTON2_MOUSE_BUTTON: "res://resources/Sprites/ControlIcons/4Click_Mouse.png",
	InputEventLibrary.UP_MOUSE_BUTTON: "res://resources/Sprites/ControlIcons/ScrollUp_Mouse.png",
	InputEventLibrary.DOWN_MOUSE_BUTTON: "res://resources/Sprites/ControlIcons/ScrollDown_Mouse.png",
	InputEventLibrary.UNKOWN_KEY: "res://resources/Sprites/ControlIcons/Blank_Keycap.png"
}

var UKNOWN_TEXTURE: Texture2D = load("res://resources/Sprites/ControlIcons/Blank_Keycap.png")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

# TODO Refactor users of AssetManagement to use this method instead of direct access
func get_sprite(event: InputEvent) -> Texture2D:
	var possibleInputs: Array = InputEventLibrary.ALL_INPUTS.values()
	var matchedInput: InputEvent
	var matchedKeyCode: int = self.extract_keycode(event)
	for possibleInput in possibleInputs:
		var possibleKeyCode: int = self.extract_keycode(possibleInput)
		if possibleKeyCode == matchedKeyCode:
			matchedInput =  possibleInput
	if matchedInput == null:
		Logger.error(NO_MATCH_FOUND_LOG, [event], self)
		matchedInput = InputEventLibrary.UNKOWN_KEY
	return load(AssetManagement.INPUT_ICONS.get(matchedInput))

func extract_keycode(event: InputEvent) -> int:
	var returnValue: int
	if event is InputEventMouseButton:
		returnValue = event.button_index
	elif event is InputEventKey:
		returnValue = event.physical_keycode
	else:
		Logger.error(UNSUPPORTED_TYPE, [str(event)], self)
	return returnValue
