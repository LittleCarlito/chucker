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

func _input(event: InputEvent) -> void:
	_handle_aiming(event)

func _handle_aiming(event: InputEvent) -> void:
	# When secondary is pressed
	if event.is_action_pressed(InputConfig.USER_INPUT.SECONDARY):
		aim.emit(AIM_TYPE.ZOOM_IN, 0)
	# When secondary is released
	elif event.is_action_released(InputConfig.USER_INPUT.SECONDARY):
		aim.emit(AIM_TYPE.ZOOM_OUT, 0)
	elif event is InputEventMouseMotion and Input.is_action_pressed(InputConfig.USER_INPUT.SECONDARY):
		var v_rotation_amount: float = NodeUtil.get_vertical_rotation_amount(event)
		var h_rotation_amount: float = NodeUtil.get_horizontal_rotation_amount(event)
		if v_rotation_amount != -1:
			aim.emit(AIM_TYPE.VERTIAL_LOOK, v_rotation_amount)
		if h_rotation_amount != -1:
			aim.emit(AIM_TYPE.HORIZONTAL_LOOK, h_rotation_amount * 10)

func hold_action(_delta: float, _incoming_basis: Basis, _incoming_focus: bool) -> void:
	Logger.warn("No hold_action function implemented for this object", [], self)

func release_action(_incoming_basis: Basis) -> void:
	Logger.error("All ThrowableItem objects must implement a release action function", [], self)
	self.queue_free()

func drop_item() -> void:
	Logger.error("All ThrowableItem objects must implement a drop item function", [], self)
	self.queue_free()
