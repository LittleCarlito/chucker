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
	GlobalInputController.connect(SIGNAL_NAME.SECONDARY_ACTION, _handle_aim_action)
	GlobalInputController.connect(SIGNAL_NAME.SECONDARY_RELEASE, _handle_aim_release)
	GlobalInputController.connect(SIGNAL_NAME.SECONDARY_MOTION, _handle_aim_movement)

# TODO Figure out if someone is actually connecting to these "aim" signals
func _handle_aim_movement(v_motion: float, h_motion: float) -> void:
	if v_motion != -1:
		aim.emit(AIM_TYPE.VERTIAL_LOOK, v_motion)
	if h_motion != -1:
		aim.emit(AIM_TYPE.HORIZONTAL_LOOK, h_motion * 10)

func _handle_aim_action() -> void:
	aim.emit(AIM_TYPE.ZOOM_IN, 0)

func _handle_aim_release() -> void:
	aim.emit(AIM_TYPE.ZOOM_OUT, 0)

func hold_action(_delta: float, _incoming_basis: Basis, _incoming_focus: bool) -> void:
	Log.warn("No hold_action function implemented for this object", [], self)

func release_action(_incoming_basis: Basis) -> void:
	Log.error("All ThrowableItem objects must implement a release action function", [], self)
	self.queue_free()

func drop_item() -> void:
	Log.error("All ThrowableItem objects must implement a drop item function", [], self)
	self.queue_free()
