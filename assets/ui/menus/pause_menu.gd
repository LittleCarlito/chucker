extends Control
class_name PauseMenu

@onready var backTimer: Timer = $BackTimer
@onready var optionsMenu: Control = $OptionsMenu

var subMenus: Array[Control]

signal close_menu
signal save_settings(saveSettings)
signal load_settings
signal apply_settings

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.subMenus = [self.optionsMenu]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed(CONSTANTS.USER_INPUT.PAUSE) and self.visible and self.backTimer.is_stopped():
		close_menu.emit()

func _on_close_menu() -> void:
	close_menu.emit()
	self.process_mode = Node.PROCESS_MODE_WHEN_PAUSED

func _on_submenu_close_menu() -> void:
	self._on_submenu_back()
	self._on_close_menu()

func _on_quit() -> void:
	get_tree().quit()

func _on_options_menu() -> void:
	self.process_mode = Node.PROCESS_MODE_DISABLED
	optionsMenu.visible = true

func _on_submenu_back() -> void:
	for subMenu in subMenus:
		subMenu.visible = false
	self.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	backTimer.start()

func _on_save_menu(saveSettings: Dictionary) -> void:
	save_settings.emit(saveSettings)

func _load_settings() -> void:
	load_settings.emit()

func _on_apply_menu() -> void:
	apply_settings.emit()
