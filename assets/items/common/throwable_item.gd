extends Node3D
class_name ThrowableItem

# Abstract class
@warning_ignore("unused_signal")
signal aim(aim_type, adjustment_value)
@warning_ignore("unused_signal")
signal launched

enum AIM_TYPE {
	ZOOM_IN,
	ZOOM_OUT,
	HORIZONTAL_LOOK,
	VERTIAL_LOOK
}

@export var charge_view: ChargeView
@export var aim_line: AimLine
@export var disk_mesh: DiskMesh

const LAUNCHED: String = "launched"
const AIM: String = "aim"
var asset_data: AssetData
var flight_data: FlightData
var _primary_hold_time: float
var _secondary_hold_time :float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.flight_data = FlightData.new()
	self.charge_view.set_progress(-1)
	self._primary_hold_time = 0
	self._secondary_hold_time = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed(InputConfig.USER_INPUT.PRIMARY):
		self._primary_hold_time = 0
	elif Input.is_action_pressed(InputConfig.USER_INPUT.PRIMARY):
		self._primary_hold_time += delta
		Logger.debug("Primary hold updated to %03f", [self._primary_hold_time], self)
	if Input.is_action_just_pressed(InputConfig.USER_INPUT.SECONDARY):
		self._secondary_hold_time = 0
	elif Input.is_action_pressed(InputConfig.USER_INPUT.SECONDARY):
		self._secondary_hold_time += delta
		Logger.debug("Secondary hold updated to %03f", [self._secondary_hold_time], self)

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
