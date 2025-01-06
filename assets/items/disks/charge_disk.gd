extends ThrowableItem
class_name ChargeDisk

const _FLIGHT_DATA_NOT_SET: String = "FlightData not set; Cannot set flight global basis"

@export var charge_view: ChargeView
@export var aim_line: AimLine
@export var disk_mesh: DiskMesh

var asset_data: AssetData
var flight_data: FlightData = FlightData.new()
var stopwatch: Stopwatch = Stopwatch.new()

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

# TODO Refactor to take in global_basis and set it in flight data as well
# TODO Figure out default value for Basis
func hold_action(delta: float, incoming_basis: Basis) -> void:
	# If right click is pressed while holding left reset throw
	if Input.is_action_just_pressed(InputConfig.USER_INPUT.SECONDARY):
		stopwatch.reset()
		charge_view.set_progress(-1)
		reset_launch_parameters()
	# If right click isn't held while holding left click calculate throw distance
	elif not Input.is_action_pressed(InputConfig.USER_INPUT.SECONDARY):
		var held_time: float = stopwatch.isHeld(delta)
		charge_view.set_progress((held_time / GameConfig.DEFAULTS.max_hold) * 100)
		var speed_multiplier: float = min(GameConfig.DEFAULTS.max_hold, held_time) * GameConfig.DEFAULTS.hold_multiplier
		var drawn_line: Array[Vector3] = aim_line.draw_aim_line(speed_multiplier)
		if drawn_line != null:
			flight_data.flight_path = drawn_line
		flight_data.flight_global_basis = incoming_basis

# TODO Refactor to take in global_basis and set it in flight data as well
# TODO Figure out default value for Basis
## Launch disk and reset objects
func release_action(incoming_basis: Basis) -> void:
	if not Input.is_action_pressed(InputConfig.USER_INPUT.SECONDARY):
		charge_view.set_progress(-1)
		var final_time: float = stopwatch.reset()
		var speed_multiplier: float = min(GameConfig.DEFAULTS.max_hold, final_time) * GameConfig.DEFAULTS.hold_multiplier
		flight_data.flight_path = aim_line.draw_aim_line(speed_multiplier)
		# TODO Added this last multiplier bit in from force disks method (should be done by caller) don't know if its necessary though
		#		If it is should be simplified into the calculation above instead of 2 separate lines
		var final_speed: float = GameConfig.DEFAULTS.launch_speed * speed_multiplier
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
	flight_data = FlightData.new()

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
