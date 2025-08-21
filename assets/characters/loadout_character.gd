extends BaseCharacter
class_name LoadoutCharacter

@export var focusing_output: bool
@export var front_detection: ShapeCast3D
@export var item_container: ItemContainer
@export var freeze_on_equip: bool = true

var _just_output: bool

func _ready() -> void:
	super._ready()

func _physics_process(delta: float) -> void:
	super._physics_process(delta)

## Stores new_item internally and attempts to give it internal camera if possible
## Returns item that was equipped if one was previously
func equip_item(new_item: Node3D) -> Variant:
	if freeze_on_equip:
		self.disable_movement()
	if new_item.has_signal(ThrowableItem.AIM):
		new_item.connect(ThrowableItem.AIM, item_container._handle_aiming)
	# Returns the equipped item if there was one
	return item_container.equip_item(new_item)

func unequip_item(alter_movement: bool = false) -> void:
	if alter_movement and self.is_movement_disabled():
		self.enable_movement()
	item_container.unequip_item()

func is_equipped() -> bool:
	return item_container.is_equipped()

func is_unequipped() -> bool:
	return item_container.is_unequipped()

func equip_frontmost_object() -> void:
	# Detect obejects in front of the character
	if Input.is_action_just_pressed(InputConfig.USER_INPUT.INTERACT) and self.front_detection.is_colliding():
		var colliding_count = self.front_detection.get_collision_count()
		for n in colliding_count:
			var colliding_object = self.front_detection.get_collider(0)
			if colliding_object != null and colliding_object is ForceDisk:
				AssetDelivery.create_and_give_item(self, colliding_object)

func rotate_equipped_item(rotation_axis: Vector3, rotation_amount: float) -> void:
	if rotation_axis.x != 0.0:
		item_container._handle_x_rotation(rotation_amount)
	# TODO Add y and z functions to item container and call them here

func item_hold_action(delta: float, focus_output: bool = false) -> void:
	if self.is_equipped():
		self.item_container.hold_action(delta, focus_output)
	else:
		Logger.debug("Should really come up with an unarmed hold action...", [], self)

func item_hold_release() -> void:
	if self.is_equipped():
		self.item_container.release_action()
	else:
		Logger.debug("Should really come up with an unarmed hold release action...", [], self)
