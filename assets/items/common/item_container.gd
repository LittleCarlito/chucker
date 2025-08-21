extends Node3D
class_name ItemContainer

signal zoom_in
signal zoom_out
signal turn_horizontal(rotate_amount)

const _UNEQUIP_MESSAGE_LOG: String = "unequip_item() called but no item is equiped"
const _EQUIPPED_MISSING_METHOD: String = "Equipped item \"%s\" doesn't have %s method"
const _ITEM_CONTAINER_UNEQUIPPED: String = "ItemContainer is not equipped with an item; %s should not have been called"
const _TURN_HORIZONTAL: String = "turn_horizontal"

var equipped_item: Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
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

func hold_action(delta: float, incoming_focus: bool = false) -> void:
	if is_equipped():
		if equipped_item.has_method(GroupData.HOLD_ACTION):
			equipped_item.call(GroupData.HOLD_ACTION, delta, self.basis, incoming_focus)
		else:
			Logger.debug(_EQUIPPED_MISSING_METHOD, [str(equipped_item), GroupData.HOLD_ACTION], self)
	else:
		Logger.debug(_ITEM_CONTAINER_UNEQUIPPED, [GroupData.HOLD_ACTION], self)

func release_action() -> void:
	if is_equipped():
		if equipped_item.has_method(GroupData.RELEASE_ACTION):
			equipped_item.call(GroupData.RELEASE_ACTION, self.global_basis)
		else:
			Logger.debug(_EQUIPPED_MISSING_METHOD, [str(equipped_item), GroupData.RELEASE_ACTION], self)
	else:
		Logger.debug(_ITEM_CONTAINER_UNEQUIPPED, [GroupData.RELEASE_ACTION], self)

func is_equipped() -> bool:
	return equipped_item != null

func is_unequipped() -> bool:
	return equipped_item == null

## Handles different types of aiming
## Signals out to player adjustments they need to make
func _handle_aiming(aim_type: ThrowableItem.AIM_TYPE, adjustment_value: float) -> void:
	match aim_type:
		ThrowableItem.AIM_TYPE.ZOOM_IN:
			zoom_in.emit()
		ThrowableItem.AIM_TYPE.ZOOM_OUT:
			zoom_out.emit()
		ThrowableItem.AIM_TYPE.HORIZONTAL_LOOK:
			# TODO Make sure amount passed in is adjusted
			# 	var horizontal_rotate_amount: float = deg_to_rad(event.relative.x) * CameraConfig.get_horizontal_look_sens()
			turn_horizontal.emit(adjustment_value)
		ThrowableItem.AIM_TYPE.VERTIAL_LOOK:
			_handle_x_rotation(adjustment_value)

# TODO Redo this to use clamp() inseach of the checking logic
func _handle_x_rotation(rotation_amount: float) -> void:
	# Compute the new projected rotation in degrees
	var projected_rotation: float = rad_to_deg(rotation.x + rotation_amount)
	# Clamp it between allowed min and max
	projected_rotation = clamp(
		projected_rotation,
		GameConfig.DEFAULTS.min_launch_rotation,
		GameConfig.DEFAULTS.max_launch_rotation
	)
	# Directly set rotation_degrees.x
	rotation_degrees.x = projected_rotation
