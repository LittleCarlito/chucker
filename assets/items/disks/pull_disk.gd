extends ThrowableItem
class_name PullDisk

@export var aim_line: AimLine
@export var pull_draw: PullDraw
@export var charge_view: ChargeView
var asset_data: AssetData
var flight_data: FlightData

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	charge_view.set_progress(-1)
	flight_data = FlightData.new()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

# We know primary is held upon entering this function
func hold_action(_delta: float, incoming_basis: Basis, incoming_focus: bool) -> void:
	flight_data.set_is_focused(incoming_focus)
	# Perform pull disk calls
	var only_primary_held: bool = Input.is_action_pressed(InputConfig.USER_INPUT.PRIMARY) and not Input.is_action_pressed(InputConfig.USER_INPUT.SECONDARY)
	if only_primary_held:
		var pull_data: PullData = pull_draw.begin_pull()
		self.flight_data.set_flight_power(pull_data.primary_pull)
		self.flight_data.set_flight_aim(pull_data.secondary_pull)
	## If right click is pressed while holding left reset throw
	if Input.is_action_just_pressed(InputConfig.USER_INPUT.SECONDARY):
		pull_draw.reset_pull()
		charge_view.set_progress(-1)
		reset_launch_parameters()
	## If right click isn't held while holding left click calculate throw distance (we know primary is held because this method is being called)
	elif not Input.is_action_pressed(InputConfig.USER_INPUT.SECONDARY):
		charge_view.set_progress((pull_draw.last_length / GameConfig.DEFAULTS.max_pull) * 100)
		var multiplier: float = (pull_draw.last_length / 100) * GameConfig.DEFAULTS.hold_multiplier
		var new_path: FlightPath = FlightPath.convert(aim_line.draw_aim_line(multiplier, pull_draw.last_offset * .01))
		flight_data.set_flight_path(new_path)
		flight_data.set_flight_basis(incoming_basis)

# We know primary was released upon entering this function
func release_action(incoming_basis: Basis) -> void:
	## If right click is not held launch the disk
	if not Input.is_action_pressed(InputConfig.USER_INPUT.SECONDARY) and pull_draw.last_length > GameConfig.DEFAULTS.min_pull:
		var multiplier: float = min(GameConfig.DEFAULTS.max_hold, (pull_draw.last_length / 100)) * GameConfig.DEFAULTS.hold_multiplier
		var final_speed: float = GameConfig.DEFAULTS.launch_speed * multiplier
		flight_data.set_flight_speed(final_speed)
		flight_data.set_flight_basis(incoming_basis)
		# Create path_disk_data and pass it into the launch method
		var path_disk_data: AssetData = self._get_next_asset_data()
		AssetDelivery.create_and_launch(flight_data, path_disk_data)
		launched.emit()
		pick_up()
		self.rotation.x = 0
		charge_view.set_progress(-1)
	pull_draw.reset_pull()

func drop_item() -> void:
	var drop_path: FlightPath = FlightPath.convert([self.global_position])
	var drop_details: FlightDetails = FlightDetails.new(0, 0, self.global_basis, false, 0,)
	var drop_flight: FlightData = FlightData.new(drop_details, drop_path)
	var drop_asset: AssetData = self._get_next_asset_data(true)
	AssetDelivery.create_and_launch(drop_flight, drop_asset)
	self.queue_free()

func reset_launch_parameters() -> void:
	flight_data = FlightData.new()

func pick_up() -> void:
	self.queue_free()

func _set_asset_data(incoming_data: AssetData) -> void:
	self.asset_data = incoming_data
	if self.asset_data != null and !self.asset_data.group_name.is_empty() and !self.is_in_group(self.asset_data.group_name):
		self.add_to_group(asset_data.group_name)

func _get_next_asset_data(is_force_disk: bool = false) -> AssetData:
	if(is_force_disk):
		return AssetData.new(
			AssetData.TYPE.FORCE, 
			self.asset_data.item_state, 
			self.asset_data.camera_state, 
			AssetData.TYPE.PULL,
			self.asset_data.group_name, 
			self.asset_data.owner_rid
			)
	else:
		return AssetData.new(
			self.asset_data.creation_type, 
			self.asset_data.item_state, 
			self.asset_data.camera_state, 
			AssetData.TYPE.FORCE,
			self.asset_data.group_name, 
			self.asset_data.owner_rid
			)
