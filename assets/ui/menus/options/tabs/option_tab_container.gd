extends OptionTab
class_name OptionTabContainer

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
@export var viewport_columns: HBoxContainer
@export var tab_viewport_container: SubViewportContainer
@export var tab_viewport: SubViewport

var tab_array: Array[OptionTab]
@export var process_delay_frame_count: int
var frame_count: int

# TODO OOOOO
# TODO Make method comparing sizes to figure out if tab clipping viewport
# TODO Make delay_process call to method just created to check for clipping
# TODO Update clipping method to create scrollbar when clipping
# TODO Determine how to add filter when scrolling is enabled for darker view
#		Or let tab know so it changes its look accordingly

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	tab_array = [
		general,
		controls,
		graphics
	]
	font_update_list = [
		option_tabs
	]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if visible:
		# Losing decimals here doesn't matter and int is needed for % usage
		@warning_ignore("narrowing_conversion")
		frame_count += max(delta, 1)
		frame_count = min(process_delay_frame_count, frame_count)
		if frame_count % process_delay_frame_count == 0:
			frame_count = 0
			var clipping_results: Array[bool] = _detect_clipping_tab()
			if clipping_results.find(true):
				_handle_clipping_tabs(clipping_results)

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
	super()
	if display_size != DisplaySize.SIZE.UNKNOWN:
		for existing_tab in tab_array:
			existing_tab._handle_resize(display_size)

func _save_controls() -> void:
	controls._save_controls()

func reload_ui() -> void:
	for existing_tab in tab_array:
		existing_tab.initialize_ui()

# TODO OOOOO
# TRY TO FIGURE OUT WHEN CHILD IS CLIPPING PARENT
#		Fix is to start with clipping children off
#			Detect when child gets bigger than parent
#				Turn on clipping to hide what overlaps
#				Create scrollbar for that tab
#				Darken background for that tab
#		Once child can fit inside parent without clipping
#			Turn clipping off
#			Remove scrollbar
#			Remove darkening from background
## Detects if any of the tabs are clipping the viewport
## Returns an array of the results, result index corresponding to tab index
func _detect_clipping_tab() -> Array[bool]:
	var clipping_results: Array[bool] = []
	var viewport_height: float = tab_viewport.size.y
	for existing_tab in tab_array:
		var tab_height: float = existing_tab.get_height()
		var tab_index: int = tab_array.find(existing_tab)
		clipping_results.append(tab_height > viewport_height)
	return clipping_results

## TODO Creates scrollbars and darkens background of scrollable tabs
func _handle_clipping_tabs(clipping_results: Array[bool]) -> void:
	# TODO Iterate through each clipping result
	#		If true
	#			Check if it has a scrollbar
	#				If not create one within the ViewportColumns
	#					Ensure it is only visible for that tab
	#						Ensure its scroll progress/setting is persistent when switching off tab
	#			Alert the tab its scrollable or set tinting for the tab so its darker
	for i in range(clipping_results.size()):
		if clipping_results[i]:
			Logger.debug("Tab index %d is clipping", [i], self)
