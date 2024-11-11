extends Control

# TODO Make Save button work
#			Should signal out with keybinding that was saved
#			Then make self not visible with same method as back and clicking outside

@onready var waitingTitle: TextureRect = $ControlSelectBackground/CenterContainer/ControlSelectWindow/VBoxContainer/HBoxContainer/VBoxContainer/InputDisplayBackground/InputDisplayCenter/WaitingTitle
@onready var inputIconDisplay: TextureRect = $ControlSelectBackground/CenterContainer/ControlSelectWindow/VBoxContainer/HBoxContainer/VBoxContainer/InputDisplayBackground/InputDisplayCenter/InputIconDisplay
@onready var setInputLabel: Label = $ControlSelectBackground/CenterContainer/ControlSelectWindow/VBoxContainer/HBoxContainer/VBoxContainer/SetInputBackground/SetInputLabel

const INPUT_NOT_FOUND: String = "Input \"%s\" could not be mapped to a texture"
const INPUT_LABEL: String = "New binding for \"%s\""
var controlToUpdate: String
var newInput: String
var detectLeftClickInput: bool = true
var cursorOffMenu: bool = false

signal save_input(controlToUpdate, newInput)

# TODO Determine if you want to allow setting of controls with undefined key values (if possible should allow setting with N/A icon)

func _input(event: InputEvent) -> void:
	if !(event is InputEventMouseMotion):
		if event is InputEventMouseButton:
			# Need to filter left clicks on buttons and outside window
			if event.button_index == 1:
				if self.detectLeftClickInput:
					self._set_icon_texture(CONSTANTS.INPUT_ICONS.get(event.button_index, ""), event)
				elif self.cursorOffMenu:
					self.close_menu()
			else:
				self._set_icon_texture(CONSTANTS.INPUT_ICONS.get(event.button_index, ""), event)
		if event is InputEventKey:
			self._set_icon_texture(CONSTANTS.INPUT_ICONS.get(event.physical_keycode, ""), event)

func _set_icon_texture(texturePath: String, event: InputEvent) -> void:
	if texturePath == "":
		Logger.error(INPUT_NOT_FOUND, [event], self)
		texturePath = CONSTANTS.INPUT_ICONS.get(KEY_UNKNOWN)
	var inputTexture: Texture2D = load(texturePath)
	self.inputIconDisplay.texture = inputTexture
	self.waitingTitle.visible = false

func reset_ui() -> void:
	self.inputIconDisplay.texture = null
	self.controlToUpdate = ""
	self.newInput = ""
	self.waitingTitle.visible = true

func _disable_left_detect() -> void:
	self.detectLeftClickInput = false

func _enable_left_detect() -> void:
	self.detectLeftClickInput = true

func close_menu() -> void:
	self.visible = false
	self.reset_ui()

func _cursor_off_menu() -> void:
	self.cursorOffMenu = true

func _cursor_on_menu() -> void:
	self.cursorOffMenu = false

func _save_input() -> void:
	save_input.emit(controlToUpdate, newInput)
	self.close_menu()

func open_menu(controlToUpdate: String) -> void:
	self.controlToUpdate = controlToUpdate
	self.setInputLabel.text = INPUT_LABEL % controlToUpdate
	self.visible = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
