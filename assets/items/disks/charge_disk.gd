extends ThrowableItem
class_name ChargeDisk

const _FLIGHT_DATA_NOT_SET: String = "FlightData not set; Cannot set flight global basis"

var stopwatch: Stopwatch

# BUG Camera on path disk spins with disk
# TODO Refactor state to be singular
#		Don't want multiple state objects
#		Right now Force disk has _update_state and it isn't part of ItemStateConfig

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	self.stopwatch = Stopwatch.new()
	if self.asset_data != null and !self.asset_data.group_name.is_empty():
		add_to_group(self.asset_data.group_name)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var current_state: ItemState.STATE = self.asset_data.get_current_state()
	super._process(delta)
	var new_state: ItemState.STATE = self.asset_data.get_current_state()
	if new_state != current_state:
		self._update_spin_value()

# TODO Refactor to take in global_basis and set it in flight data as well
# TODO Figure out default value for Basis
func hold_action(delta: float, incoming_basis: Basis, incoming_focus: bool) -> void:
	self.flight_data.set_is_focused(incoming_focus)
	# If right click is pressed while holding left reset throw
	if Input.is_action_just_pressed(InputConfig.USER_INPUT.SECONDARY):
		self.stopwatch.reset()
		self.charge_view.set_progress(-1)
		reset_launch_parameters()
	# If right click isn't held while holding left click calculate throw distance
	elif not Input.is_action_pressed(InputConfig.USER_INPUT.SECONDARY):
		var held_time: float = stopwatch.isHeld(delta)
		self.charge_view.set_progress((held_time / GameConfig.DEFAULTS.max_hold) * 100)
		var speed_multiplier: float = min(GameConfig.DEFAULTS.max_hold, held_time) * GameConfig.DEFAULTS.hold_multiplier
		var drawn_line: Array[Vector3] = self.aim_line.draw_aim_line(speed_multiplier)
		if drawn_line != null:
			var new_path: FlightPath = FlightPath.convert(drawn_line)
			self.flight_data.set_flight_path(new_path)
		self.flight_data.set_flight_basis(incoming_basis)

# TODO Refactor to take in global_basis and set it in flight data as well
# TODO Figure out default value for Basis
## Launch disk and reset objects
func release_action(incoming_basis: Basis) -> void:
	if not Input.is_action_pressed(InputConfig.USER_INPUT.SECONDARY):
		charge_view.set_progress(-1)
		var final_time: float = stopwatch.reset()
		var speed_multiplier: float = min(GameConfig.DEFAULTS.max_hold, final_time) * GameConfig.DEFAULTS.hold_multiplier
		var new_path: FlightPath = FlightPath.convert(self.aim_line.draw_aim_line(speed_multiplier))
		self.flight_data.set_flight_path(new_path)
		# TODO Added this last multiplier bit in from force disks method (should be done by caller) don't know if its necessary though
		#		If it is should be simplified into the calculation above instead of 2 separate lines
		var final_speed: float = GameConfig.DEFAULTS.launch_speed * speed_multiplier
		self.flight_data.set_flight_speed(final_speed)
		self.flight_data.set_flight_basis(incoming_basis)
		# self.flight_data.set_flight_spin()
		# TODO Make sure that item_data contains the group_name of the entity throwing it
		var force_disk_data: AssetData = self._get_next_asset_data()
		var launched_disk: ForceDisk = AssetDelivery.create_and_launch(self.flight_data, force_disk_data)
		# TODO Since moving this camera position is fucked; Check out setting focus in create and launch; probably needs to be done as separate call after
		launched_disk.global_position = self.flight_data.get_actual_path()[0].point_position
		launched.emit()
		self.pick_up()

func drop_item() -> void:
	var drop_path: FlightPath = FlightPath.convert([self.global_position])
	var drop_details: FlightDetails = FlightDetails.new(0, 0, self.global_basis, false, 0, 0)
	var drop_flight: FlightData = FlightData.new(drop_details, drop_path)
	var drop_asset: AssetData = self._get_next_asset_data()
	AssetDelivery.create_and_launch(drop_flight, drop_asset)
	self.queue_free()

func reset_launch_parameters() -> void:
	flight_data = FlightData.new()

func pick_up() -> void:
	self.queue_free()

func _set_flight_basis(incoming_basis: Basis) -> void:
	if self.flight_data != null:
		self.flight_data.set_flight_basis(incoming_basis)
	else:
		Logger.debug(_FLIGHT_DATA_NOT_SET, [], self)

func _set_asset_data(incoming_data: AssetData) -> void:
	self.asset_data = incoming_data
	if self.asset_data != null and !asset_data.group_name.is_empty() and !self.is_in_group(self.asset_data.group_name):
		self.add_to_group(asset_data.group_name)

func _get_next_asset_data() -> AssetData:
	return AssetData.new(
		self.asset_data.creation_type, 
		self.asset_data.item_state, 
		self.asset_data.camera_state, 
		self.asset_data.internal_type, 
		self.asset_data.group_name, 
		self.asset_data.owner_rid
		)

func _update_spin_value() -> void:
	var current_state: ItemState.STATE = self.get_current_state()
	var spin_amount: float = STATE_DEFAULTS.get_spin_amount(current_state) * GameConfig.DEFAULTS.spin_multiplier
	self.flight_data.set_flight_spin(spin_amount)
