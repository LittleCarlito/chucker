extends Control
class_name PauseMenu

@export var back_timer: Timer
@export var options_menu: OptionsMenu

var sub_menus: Array[Control]

signal close_menu
signal apply_settings

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sub_menus = [options_menu]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed(CONSTANTS.USER_INPUT.PAUSE) and self.visible and back_timer.is_stopped():
		close_menu.emit()

func _on_close_menu() -> void:
	close_menu.emit()
	self.process_mode = Node.PROCESS_MODE_WHEN_PAUSED

func _on_submenu_close_menu() -> void:
	_on_submenu_back()
	_on_close_menu()

func _on_quit() -> void:
	get_tree().quit()

func _on_options_menu() -> void:
	self.process_mode = Node.PROCESS_MODE_DISABLED
	options_menu.visible = true

func _on_submenu_back() -> void:
	for sub_menu in sub_menus:
		sub_menu.visible = false
	self.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	back_timer.start()

func _on_apply_menu() -> void:
	apply_settings.emit()

func reload_ui() -> void:
	options_menu.reload_ui()
