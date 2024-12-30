extends Control
class_name ScrollbarContainer

const _SCROLLBAR_ALREADY_EXISTS: String = "A scrollbar entry already exists for tab index \"%d\""
const _NO_SCROLLBAR: String = "No scrollbar entry exists for tab index \"%d\""
const _CHILD_NOT_FOUND: String = "Child node \"%s\" could not be found to be removed"

var scrollbar_library: Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

## Checks if the library contains a scrollbar for the incoming index
func has_scrollbar_for(tab_index: int) -> bool:
	return scrollbar_library.has(tab_index)

## Adds a scrollbar if possible to the library
func add_scrollbar(tab_index: int, new_scrollbar: VScrollBar) -> void:
	if !has_scrollbar_for(tab_index):
		scrollbar_library[tab_index] = new_scrollbar
		# TODO Set anchor points to fill the parent
		# TODO Expand is setting the minimum value (but the grayness of the node doesn't appear so I'm skeptical)
		#		new_scrollbar needs to have same logic applied to it as "full rect" does from the editor
		new_scrollbar.set_anchors_and_offsets_preset(LayoutPreset.PRESET_FULL_RECT)
		add_child(new_scrollbar)
	else:
		Logger.debug(_SCROLLBAR_ALREADY_EXISTS, [tab_index], self)

## Removes scrollbar associated with incoming index from the library if one exists
func remove_scrollbar(tab_index: int) -> void:
	if has_scrollbar_for(tab_index):
		var scrollbar_entry: VScrollBar = scrollbar_library.get(tab_index) as VScrollBar
		scrollbar_library.erase(tab_index)
		_remove_scrollbar_child(scrollbar_entry)
	else:
		Logger.debug(_NO_SCROLLBAR, [tab_index], self)

## Makes the tab associated with the incoming index visible and all others not
func visible_tab(tab_index: int) -> void:
	var existing_tab_indexes: Array = scrollbar_library.keys()
	for existing_tab_index in existing_tab_indexes:
		var tab_scrollbar: Control = scrollbar_library.get(existing_tab_index) as Control
		tab_scrollbar.visible = true if existing_tab_index == tab_index else false

## Removes associated library entry child node from the ScrollBarContainer
func _remove_scrollbar_child(scrollbar_entry: VScrollBar) -> void:
	var children_nodes: Array = get_children()
	if children_nodes.has(scrollbar_entry):
		remove_child(scrollbar_entry)
		scrollbar_entry.queue_free()
	else:
		Logger.debug(_CHILD_NOT_FOUND, [str(scrollbar_entry)], self)
