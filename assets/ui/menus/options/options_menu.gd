extends Control
class_name OptionsMenu

# TODO Get everything back to working with TabContainer in here
# TODO ControlSetting menu thing can be moved to control tab
#			Where current work marker is
# TODO Should probably start with general cleanup/setup here	

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
signal save_settings(updated_settings)
signal load_settings
signal apply_settings

var tab_array: Array[OptionTab]
var display_size: DisplaySize.SIZE

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initialize_ui()
	tab_array = [
		general_tab,
		controls_tab,
		graphics_tab
	]

func initialize_ui() -> void:
	control_select_menu.visible = false
	load_settings.emit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if event.is_action_pressed(CONSTANTS.USER_INPUT.PAUSE) and self.visible:
		_on_back_menu()

func _on_close_menu() -> void:
	close_menu.emit()
	_reset_variables()
	initialize_ui()

func _on_back_menu() -> void:
	back_menu.emit()
	_reset_variables()
	initialize_ui()

func _on_save_menu() -> void:
	controls_tab._save_controls()
	if not control_settings.is_empty():
		save_settings_dictionary[CONSTANTS.Controls] = control_settings
	if not camera_settings.is_empty():
		save_settings_dictionary[CONSTANTS.Camera] = camera_settings
	if not display_settings.is_empty():
		save_settings_dictionary[CONSTANTS.Display] = display_settings
	# Always emit saveSettings even if empty; Returns to defaults then
	save_settings.emit(save_settings_dictionary)
	apply_settings.emit()
	_reset_variables()

func _reset_variables() -> void:
	save_settings_dictionary.clear()
	control_settings.clear()
	camera_settings.clear()
	display_settings.clear()
	if is_instance_valid(option_tab_container):
		option_tab_container.set_current_tab(0)

func _open_control_select_menu(selected_item: String) -> void:
		control_select_menu.open_menu(selected_item)
		process_mode = Node.PROCESS_MODE_DISABLED

func _control_select_closed() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED

## Handles update signals from menu components
func _handle_update_signal(update_type: UIData.TYPE, update_entry: Dictionary) -> void:
	if update_entry.size() == 1:
		var entry_key: String = update_entry.keys()[0]
		var entry_value = update_entry.get(entry_key)
		match update_type:
			UIData.TYPE.CAMERA:
				camera_settings[entry_key] = entry_value
			UIData.TYPE.DISPLAY:
				display_settings[entry_key] = entry_value
			UIData.TYPE.CONTROL:
				control_settings[entry_key] = entry_value
			_:
				Logger.error(_CATEGORY_NOT_FOUND, [str(update_type), entry_key, str(entry_value)], self)
	else:
		Logger.warn(_UNSUPPORTED_SIZE, [str(update_entry)], self)

func reload_ui() -> void:
	for existing_tab in tab_array:
		existing_tab.initialize_ui()

## Passes selectected controls from ControlSelectMenu to Controls tab
func _handle_control_selected(control_to_update: Variant, selected_input: Variant) -> void:
	controls_tab._control_select_set(control_to_update, selected_input)
