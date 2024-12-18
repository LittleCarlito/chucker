extends Node3D
class_name ItemContainer

const _UNEQUIP_MESSAGE_LOG: String = "unequip_item() called but no item is equiped"

var equipped_item: Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func unequip_item() -> void:
	if equipped_item != null:
		equipped_item.queue_free()
	else:
		Logger.warn(_UNEQUIP_MESSAGE_LOG, [], self)
	# Reset item controller rotation
	self.rotation_degrees.x = 0

func is_equipped() -> bool:
	return equipped_item != null

func is_unequipped() -> bool:
	return equipped_item == null
