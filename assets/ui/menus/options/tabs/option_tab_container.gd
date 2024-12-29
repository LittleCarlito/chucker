extends Control
class_name OptionTabContainer

signal value_updated(data_type: UIData.TYPE, new_entry: Dictionary)
signal value_selected(selected_item: String)

enum TAB {
	GENERAL,
	CONTROLS,
	GRAPHICS,
	UNKNOWN
}

@export var option_tabs: TabBar
@export var general: OptionTab
@export var controls: ControlsTab
@export var graphics: OptionTab

var tab_array: Array[OptionTab]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	tab_array = [
		general,
		controls,
		graphics
	]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

## Resets existing variables and sets requested tab if given
func _reset_variables(tab_name: OptionTabContainer.TAB = OptionTabContainer.TAB.UNKNOWN) -> void:
	reload_ui()
	if tab_name != OptionTabContainer.TAB.UNKNOWN:
		_handle_tab_change(tab_name)

func _open_control_select_menu(selected_item: String) -> void:
		value_selected.emit(selected_item)

func _handle_value_selected(data_type: UIData.TYPE, new_entry: Dictionary) -> void:
	value_updated.emit(data_type, new_entry)

func _control_select_set(control_to_update, selected_input) -> void:
	controls._control_select_set(control_to_update, selected_input)

## Handles tab changing signal to make the requested tab visible
func _handle_tab_change(tab_index: int) -> void:
	option_tabs.set_current_tab(tab_index)
	match tab_index:
		0:
			general.visible = true
			controls.visible = false
			graphics.visible = false
		1:
			general.visible = false
			controls.visible = true
			graphics.visible = false
		2:
			general.visible = false
			controls.visible = false
			graphics.visible = true
		_:
			general.visible = false
			controls.visible = false
			graphics.visible = false

func _handle_resize(display_size: DisplaySize.SIZE = DisplaySize.SIZE.UNKNOWN) -> void:
	if display_size != DisplaySize.SIZE.UNKNOWN:
		for existing_tab in tab_array:
			existing_tab._handle_resize(display_size)

func _save_controls() -> void:
	controls._save_controls()

func reload_ui() -> void:
	for existing_tab in tab_array:
		existing_tab.initialize_ui()
