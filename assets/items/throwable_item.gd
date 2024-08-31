extends EquipableItem
class_name ThrowableItem

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func hold_action(_delta: float) -> void:
	push_error("UNIMPLEMENTED METHOD; All ThrowableItem Objects must implement hold_action method")

func release_action() -> void:
	push_error("UNIMPLEMENTED METHOD; All ThrowableItem Objects must implement release_action method")
