extends Control
class_name ControlSelectMenu

const INPUT_NOT_FOUND: String = "Input \"%s\" could not be mapped to a texture"
const INPUT_LABEL: String = "New binding for \"%s\""

@onready var waitingTitle: TextureRect = $ControlSelectBackground/CenterContainer/ControlSelectWindow/VBoxContainer/HBoxContainer/VBoxContainer/InputDisplayBackground/InputDisplayCenter/WaitingTitle
@onready var inputIconDisplay: TextureRect = $ControlSelectBackground/CenterContainer/ControlSelectWindow/VBoxContainer/HBoxContainer/VBoxContainer/InputDisplayBackground/InputDisplayCenter/InputIconDisplay
@onready var setInputLabel: Label = $ControlSelectBackground/CenterContainer/ControlSelectWindow/VBoxContainer/HBoxContainer/VBoxContainer/SetInputBackground/SetInputLabel

var controlToUpdate: String
var detectLeftClickInput: bool = false
var cursorOffMenu: bool = false
var pressCount: int = 0 
var selectedInput: ControlSetting = null

signal save_input(controlToUpdate, selectedInput)
signal menu_closed

# TODO Determine if you want to allow setting of controls with undefined key values (if possible should allow setting with N/A icon)

func _input(event: InputEvent) -> void:
	if !(event is InputEventMouseMotion):
		# Left click filtering logic
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and (cursorOffMenu or !detectLeftClickInput):
			if cursorOffMenu:
				if event.is_released() and pressCount > 0:
					self.close_menu()
			if event.is_pressed():
				pressCount += 1
		# Regular input handling
		elif event.is_pressed():
			pressCount += 1
			self._set_icon_texture(event)

func _set_icon_texture(event: InputEvent) -> void:
	var inputTexture: Texture2D = InputSprite.get_sprite(event)
	self.inputIconDisplay.texture = inputTexture
	self.selectedInput = InputEventLibrary.convert_event_to_control_setting(event)
	self.waitingTitle.visible = false

func reset_ui() -> void:
	self.inputIconDisplay.texture = null
	self.controlToUpdate = ""
	self.waitingTitle.visible = true
	self.pressCount = 0
	self.selectedInput = null

func _disable_left_detect() -> void:
	self.detectLeftClickInput = false

func _enable_left_detect() -> void:
	self.detectLeftClickInput = true

func close_menu() -> void:
	self.visible = false
	self.reset_ui()
	self.process_mode = Node.PROCESS_MODE_DISABLED
	menu_closed.emit()

func _cursor_off_menu() -> void:
	self.cursorOffMenu = true

func _cursor_on_menu() -> void:
	self.cursorOffMenu = false

func _save_input() -> void:
	if selectedInput != null:
		save_input.emit(controlToUpdate, selectedInput)
	self.close_menu()

func open_menu(incomingControl: String) -> void:
	self.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	self.controlToUpdate = incomingControl
	self.setInputLabel.text = INPUT_LABEL % incomingControl
	self.visible = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
