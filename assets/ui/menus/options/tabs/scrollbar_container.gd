extends Control
class_name ScrollbarContainer

const _SCROLLBAR_ALREADY_EXISTS: String = "A scrollbar entry already exists for tab index \"%d\""
const _NO_SCROLLBAR: String = "No scrollbar entry exists for tab index \"%d\""

@export var expanded_thickness: int

var scrollbar_library: Dictionary = {}
var _expanded: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_check_contents()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

## Sets minmimum x value to expanded_thickness variable
func expand() -> void:
	set_custom_minimum_size(Vector2(expanded_thickness, 0))
	_expanded = true

## Removes custom minmimum
func constrict() -> void:
	set_custom_minimum_size(Vector2(0, 0))
	_expanded = false

## Checks if the library contains a scrollbar for the incoming index
func has_scrollbar_for(tab_index: int) -> bool:
	return scrollbar_library.has(tab_index)

## Adds a scrollbar if possible to the library
func add_scrollbar(tab_index: int, new_scrollbar: VScrollBar) -> void:
	if !has_scrollbar_for(tab_index):
		scrollbar_library[tab_index] = new_scrollbar
	else:
		Logger.debug(_SCROLLBAR_ALREADY_EXISTS, [tab_index], self)
	_check_contents()

## Removes scrollbar associated with incoming index from the library if one exists
func remove_scrollbar(tab_index: int) -> void:
	if has_scrollbar_for(tab_index):
		var scrollbar_entry: VScrollBar = scrollbar_library.get(tab_index) as VScrollBar
		scrollbar_library.erase(tab_index)
		scrollbar_entry.queue_free()
	else:
		Logger.debug(_NO_SCROLLBAR, [tab_index], self)
	_check_contents()

## Makes the tab associated with the incoming index visible and all others not
func visible_tab(tab_index: int) -> void:
	var existing_tab_indexes: Array = scrollbar_library.keys()
	for existing_tab_index in existing_tab_indexes:
		var tab_scrollbar: Control = scrollbar_library.get(existing_tab_index) as Control
		tab_scrollbar.visible = true if existing_tab_index == tab_index else false

## Checks if ScrollbarContainer has any children and expands/constricts accordingly
func _check_contents() -> void:
	var child_count: int = get_child_count()
	if child_count > 0 and not _expanded:
		expand()
	elif child_count == 0 and _expanded:
		constrict()
