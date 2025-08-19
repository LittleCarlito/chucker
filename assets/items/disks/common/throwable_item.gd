extends Node3D
class_name ThrowableItem

# Abstract class
@warning_ignore("unused_signal")
signal aim(aim_type, adjustment_value)
@warning_ignore("unused_signal")
signal launched

const LAUNCHED: String = "launched"
const AIM: String = "aim"

enum AIM_TYPE {
	ZOOM_IN,
	ZOOM_OUT,
	HORIZONTAL_LOOK,
	VERTIAL_LOOK
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func hold_action(_delta: float, _incoming_basis: Basis, _incoming_focus: bool) -> void:
	Logger.warn("No hold_action function implemented for this object", [], self)

func release_action(_incoming_basis: Basis) -> void:
	Logger.error("All ThrowableItem objects must implement a release action function", [], self)
	self.queue_free()

func drop_item() -> void:
	Logger.error("All ThrowableItem objects must implement a drop item function", [], self)
	self.queue_free()
