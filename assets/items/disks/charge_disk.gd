# TODO Refactor this to use ECS structure instead of inheritance
extends Node3D
class_name ChargeDisk

const _FLIGHT_DATA_NOT_SET: String = "FlightData not set; Cannot set flight global basis"

@onready var charge_view: ChargeView = $ChargeView
@onready var aim_line: AimLine = $AimLine

var stopwatch: Stopwatch = Stopwatch.new()
@export var flight_data: FlightData
@export var asset_data: AssetData

# TODO Have charge and line decrease after reaching max and increase after reaching min on long holds
# TODO Add charge effects
#		Wobble if held too long
#		Will just inaccurately launch after x amount of time
# TODO Add "perfect" release window
# TODO Give "perfect" release different effects
# TODO Ability to put spin on disk and curve it

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	charge_view.set_progress(-1)
	if asset_data != null and !asset_data.group_name.is_empty():
		add_to_group(asset_data.group_name)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

# TODO Refactor to take in global_basis and set it in flight data as well
# TODO Figure out default value for Basis
func hold_action(delta: float, incoming_basis: Basis) -> void:
	# If right click is pressed while holding left reset throw
	if Input.is_action_just_pressed(CONSTANTS.USER_INPUT.SECONDARY):
		stopwatch.reset()
		charge_view.set_progress(-1)
		reset_launch_parameters()
	# If right click isn't held while holding left click calculate throw distance
	elif not Input.is_action_pressed(CONSTANTS.USER_INPUT.SECONDARY):
		var held_time: float = stopwatch.isHeld(delta)
		charge_view.set_progress((held_time / GlobalSettings.DISK.MAX_HOLD) * 100)
		var speed_multiplier: float = min(GlobalSettings.DISK.MAX_HOLD, held_time) * GlobalSettings.DISK.HOLD_MULTIPLIER
		var drawn_line: Array[Vector3] = aim_line.draw_aim_line(speed_multiplier)
		if drawn_line != null:
			flight_data.flight_path 
		flight_data.flight_global_basis = incoming_basis

# TODO Refactor to take in global_basis and set it in flight data as well
# TODO Figure out default value for Basis
## Launch disk and reset objects
func release_action(incoming_basis: Basis) -> void:
	if not Input.is_action_pressed(CONSTANTS.USER_INPUT.SECONDARY):
		charge_view.set_progress(-1)
		var final_time: float = stopwatch.reset()
		var speed_multiplier: float = min(GlobalSettings.DISK.MAX_HOLD, final_time) * GlobalSettings.DISK.HOLD_MULTIPLIER
		flight_data.flight_path = aim_line.draw_aim_line(speed_multiplier)
		# TODO Added this last multiplier bit in from force disks method (should be done by caller) don't know if its necessary though
		#		If it is should be simplified into the calculation above instead of 2 separate lines
		var final_speed: float = GlobalSettings.DISK.LAUNCH_SPEED * speed_multiplier
		flight_data = FlightData.create_flight_data(final_speed, incoming_basis, flight_data.flight_path, flight_data.focus_flight)
		# TODO Launcd disk needs to be refactored into this class
		if flight_data != null:
			# TODO Make sure that item_data contains the group_name of the entity throwing it
			AssetDelivery.create_and_launch(flight_data, asset_data)
			pick_up()
		else:
			Logger.error(FlightData.LAUNCH_NOT_READY_LOG, [], self)
		self.rotation.x = 0
		# TODO this should be calling something within a group instead
		#item_owner.disable_movement()
		#item_owner.disable_rotation()
		#item_owner.unequip_item()


func reset_launch_parameters() -> void:
	flight_data = null

func _set_asset_data(incoming_data: AssetData) -> void:
	asset_data = incoming_data
	if asset_data != null and !asset_data.group_name.is_empty() and !is_in_group(asset_data.group_name):
		add_to_group(asset_data.group_name)

func _set_flight_global_basis(incoming_basis: Basis) -> void:
	if flight_data != null:
		flight_data.flight_global_basis = incoming_basis
	else:
		Logger.debug(_FLIGHT_DATA_NOT_SET, [], self)

func pick_up() -> void:
	self.queue_free()
