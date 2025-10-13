extends DirectionalCharacter
class_name LoadoutCharacter

const _PRIMARY_ASSET_STATE: String = "Primary Asset State"
const _HANDLE_X_ROTATION: String = "_handle_x_item_rotation"

# TODO Idealy this class doesn't need to exist
#			Or more precisely chuck chuckers logic should be brough down into here
#				And this logic should be shoved over to item_container reacting to signals from its AssetState 
@export var front_detection: ShapeCast3D
@export var item_container: ItemContainer

func _ready() -> void:
	super._ready()
	# Input

	# TODO All these need to be based off the state update signal instead of pulling from here
	GlobalInputController.connect(SIGNAL_NAME.PRIMARY_HOLD, _handle_primary_hold)
	GlobalInputController.connect(SIGNAL_NAME.PRIMARY_RELEASE, _handle_primary_release)
	GlobalInputController.connect(SIGNAL_NAME.ROTATE, _handle_rotation_signal)

## Stores new_item internally and attempts to give it internal camera if possible
## Returns item that was equipped if one was previously
func equip_item(new_item: Node3D) -> Variant:
	if asset_state.is_freeze_on_equip():
		disable_movement()
	if new_item.has_signal(ThrowableItem.AIM):
		new_item.connect(ThrowableItem.AIM, item_container._handle_aiming)
	# Returns the equipped item if there was one
	GlobalCursorController.request_visible(self, "Equipped an item")
	return item_container.equip_item(new_item)

func unequip_item(alter_movement: bool = false) -> void:
	if alter_movement and is_movement_disabled():
		enable_movement()
	item_container.unequip_item()

func is_equipped() -> bool:
	return item_container.is_equipped()

func is_unequipped() -> bool:
	return item_container.is_unequipped()

func equip_frontmost_object() -> void:
	# Detect obejects in front of the character
	if front_detection.is_colliding():
		var colliding_count = front_detection.get_collision_count()
		for n in colliding_count:
			var colliding_object = front_detection.get_collider(0)
			if colliding_object != null and colliding_object is ForceDisk:
				AssetDelivery.create_and_give_item(self, colliding_object)




# TODO This should then be removed to ItemContainer
func rotate_equipped_item(rotation_axis: Vector3, rotation_amount: float) -> void:
	if rotation_axis.x != 0.0:
		item_container._handle_x_rotation(rotation_amount)
	# TODO Add y and z functions to item container and call them here



func item_hold_action(delta: float, focus_output: bool = false) -> void:
	if is_equipped():
		item_container.hold_action(delta, focus_output)



func item_hold_release() -> void:
	if is_equipped():
		item_container.release_action()

func _handle_primary_hold(delta: float) -> void:
	item_hold_action(delta, asset_state.is_focus_output())

func _handle_primary_release() -> void:
	item_hold_release()

func _handle_x_item_rotation(rotation_amount: float) -> void:
	var primary_asset_state: AssetState = asset_state.get_primary_asset()
	if primary_asset_state != null:
		primary_asset_state.apply_rotation(Vector3(rotation_amount, 0, 0))
	else:
		Log.error(Log._CANT_PERFORM, [_PRIMARY_ASSET_STATE, _HANDLE_X_ROTATION], self)




# TODO This should then be removed to ItemContainer
func _handle_rotation_signal(incoming_axis: Vector3, incoming_amount: float) -> void:
	rotate_equipped_item(incoming_axis, incoming_amount)
