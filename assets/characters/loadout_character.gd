extends BaseCharacter
class_name LoadoutCharacter

@export var focusing_output: bool
@export var front_detection: ShapeCast3D
@export var item_container: ItemContainer
@export var freeze_on_equip: bool = true

var _just_output: bool

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
