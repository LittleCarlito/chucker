extends Control
class_name OptionsMenu

const _CATEGORY_NOT_FOUND: String = "Category \"%s\" for save setting \"%s\" could not be found. Value \"%s\" will be discarded."
const _UNSUPPORTED_SIZE: String = "Currently only supporting update entries of size 1; Submit them one entry at a time; \"%s\""

@export var control_select_menu: ControlSelectMenu
@export var option_tab_container: TabContainer
@export var general_tab: GeneralTab
@export var controls_tab: ControlsTab
@export var graphics_tab: GraphicsTab

enum SETTING_TABS {GENERAL, CONTROLS, GRAPHICS}
var camera_settings: Dictionary
var control_settings: Dictionary
var display_settings: Dictionary
var save_settings_dictionary: Dictionary

signal close_menu
signal back_menu
signal apply_settings

var tab_array: Array[OptionTab]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	tab_array = [
		general_tab,
		controls_tab,
		graphics_tab
	]
	initialize_ui()

func initialize_ui() -> void:
	control_select_menu.visible = false
	reload_ui()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if event.is_action_pressed(CONSTANTS.USER_INPUT.PAUSE) and self.visible:
		_on_back_menu()

func _on_close_menu() -> void:
	_reset_variables()
	close_menu.emit()
	initialize_ui()

func _on_back_menu() -> void:
	back_menu.emit()
	_reset_variables()
	initialize_ui()

## Handles menu save signals
func _on_save_menu() -> void:
	# Save to configuration files
	# TODO Convert Controls settings to override.cfg
	# TODO Change the ConfigFileHandler calls to be combined to be passing in one Dictionary
	# BUG Applied changes coming in here after setting a control was empty
	controls_tab.save_controls()
	ConfigFileHandler.save_to_override(graphics_tab.applied_changes)
	ConfigFileHandler.delete_file_category(ConfigFileHandler.FILE_TYPE.USER_SETTING, InputConfig.NAME)
	ConfigFileHandler.save_to_user_settings(controls_tab.applied_changes)
	ConfigFileHandler.save_to_user_settings(general_tab.applied_changes)
	# Alert config handlers to refresh their data
	get_tree().call_group(CONSTANTS.CONFIG_HANDLER, CONSTANTS.RELOAD_PROJECT_SETTINGS)
	if not control_settings.is_empty():
		save_settings_dictionary[CONSTANTS.Controls] = control_settings
	if not camera_settings.is_empty():
		save_settings_dictionary[CONSTANTS.Camera] = camera_settings
	if not display_settings.is_empty():
		save_settings_dictionary[DisplayConfig.NAME] = display_settings
	# Always emit saveSettings even if empty; Returns to defaults then
	apply_settings.emit()
	_reset_variables(option_tab_container.current_tab)

func _reset_variables(selected_tab: int = 0) -> void:
	save_settings_dictionary.clear()
	control_settings.clear()
	camera_settings.clear()
	display_settings.clear()
	option_tab_container.set_current_tab(selected_tab)
	controls_tab.full_reset()
	general_tab.full_reset()
	graphics_tab.full_reset()	

func _open_control_select_menu(selected_item: String) -> void:
		control_select_menu.open_menu(selected_item)
		process_mode = Node.PROCESS_MODE_DISABLED

func _control_select_closed() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED

func reload_ui() -> void:
	for existing_tab in tab_array:
		existing_tab.initialize_ui()

## Passes selectected controls from ControlSelectMenu to Controls tab
func _handle_control_selected(control_to_update: Variant, selected_input: Variant) -> void:
	controls_tab._control_select_set(control_to_update, selected_input)
