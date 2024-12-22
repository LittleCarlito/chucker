extends Node3D
class_name ItemContainer

const _UNEQUIP_MESSAGE_LOG: String = "unequip_item() called but no item is equiped"
const _EQUIPPED_MISSING_METHOD: String = "Equipped item \"%s\" doesn't have %s method"
const _ITEM_CONTAINER_UNEQUIPPED: String = "ItemContainer is not equipped with an item; %s should not have been called"

var equipped_item: Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

## Equips given item as a child inside the item container
## If an item is already contained will return the contained item and replace it

func equip_item(new_item: Node3D) -> Node3D:
	var existing_item: Node3D = null
	if is_equipped():
		existing_item = equipped_item
		equipped_item = null
		existing_item.reparent(get_tree().root)
	add_child(new_item)
	equipped_item = new_item
	equipped_item.global_position = self.global_position
	equipped_item.global_transform = self.global_transform
	return existing_item

func unequip_item() -> void:
	if equipped_item != null:
		equipped_item.queue_free()
	else:
		Logger.warn(_UNEQUIP_MESSAGE_LOG, [], self)
	# Reset item controller rotation
	self.rotation_degrees.x = 0

# TODO Figure out a default 0ing, min, or max value for Basis to allow defaulting
func hold_action(delta: float) -> void:
	if is_equipped():
		if equipped_item.has_method(CONSTANTS.HOLD_ACTION):
			equipped_item.call(CONSTANTS.HOLD_ACTION, delta, self.global_basis)
		else:
			Logger.debug(_EQUIPPED_MISSING_METHOD, [str(equipped_item), CONSTANTS.HOLD_ACTION], self)
	else:
		Logger.debug(_ITEM_CONTAINER_UNEQUIPPED, [CONSTANTS.HOLD_ACTION], self)

# TODO Figure out a default 0ing, min, or max value for Basis to allow defaulting
func release_action() -> void:
	if is_equipped():
		if equipped_item.has_method(CONSTANTS.RELEASE_ACTION):
			equipped_item.call(CONSTANTS.RELEASE_ACTION, self.global_basis)
		else:
			Logger.debug(_EQUIPPED_MISSING_METHOD, [str(equipped_item), CONSTANTS.RELEASE_ACTION], self)
	else:
		Logger.debug(_ITEM_CONTAINER_UNEQUIPPED, [CONSTANTS.RELEASE_ACTION], self)

func is_equipped() -> bool:
	return equipped_item != null

func is_unequipped() -> bool:
	return equipped_item == null
