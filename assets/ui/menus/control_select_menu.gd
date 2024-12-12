extends Control
class_name ControlSelectMenu

const INPUT_NOT_FOUND: String = "Input \"%s\" could not be mapped to a texture"
const INPUT_LABEL: String = "New binding for \"%s\""

@onready var waiting_title: TextureRect = $ControlSelectBackground/CenterContainer/ControlSelectWindow/VBoxContainer/HBoxContainer/VBoxContainer/InputDisplayBackground/InputDisplayCenter/WaitingTitle
@onready var input_icon_display: TextureRect = $ControlSelectBackground/CenterContainer/ControlSelectWindow/VBoxContainer/HBoxContainer/VBoxContainer/InputDisplayBackground/InputDisplayCenter/InputIconDisplay
@onready var set_input_label: Label = $ControlSelectBackground/CenterContainer/ControlSelectWindow/VBoxContainer/HBoxContainer/VBoxContainer/SetInputBackground/SetInputLabel

var control_to_update: String
var detect_left_click: bool = false
var cursor_off_menu: bool = false
var press_count: int = 0 
var selected_input: ControlSetting = null

signal save_input(controlToUpdate, selectedInput)
signal menu_closed

func _input(event: InputEvent) -> void:
	if !(event is InputEventMouseMotion):
		# Left click filtering logic
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and (cursor_off_menu or !detect_left_click):
			if cursor_off_menu:
				if event.is_released() and press_count > 0:
					close_menu()
			if event.is_pressed():
				press_count += 1
		# Regular input handling
		elif event.is_pressed():
			press_count += 1
			_set_icon_texture(event)

func _set_icon_texture(event: InputEvent) -> void:
	var input_texture: Texture2D = InputSprite.get_sprite(event)
	input_icon_display.texture = input_texture
	selected_input = InputEventLibrary.convert_event_to_control_setting(event)
	waiting_title.visible = false

func reset_ui() -> void:
	input_icon_display.texture = null
	control_to_update = ""
	waiting_title.visible = true
	press_count = 0
	selected_input = null

func _disable_left_detect() -> void:
	detect_left_click = false

func _enable_left_detect() -> void:
	detect_left_click = true

func close_menu() -> void:
	self.visible = false
	reset_ui()
	self.process_mode = Node.PROCESS_MODE_DISABLED
	menu_closed.emit()

func _cursor_off_menu() -> void:
	cursor_off_menu = true

func _cursor_on_menu() -> void:
	cursor_off_menu = false

func _save_input() -> void:
	if selected_input != null:
		save_input.emit(control_to_update, selected_input)
	close_menu()

func open_menu(incoming_control: String) -> void:
	self.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	control_to_update = incoming_control
	set_input_label.text = INPUT_LABEL % incoming_control
	self.visible = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
