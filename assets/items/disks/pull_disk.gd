extends ThrowableItem
class_name PullDisk

# TODO OOOOO
# TODO Get this working again

# TODO Allow for holding space or something to set power but still pull for offset
# TODO Make a maximum pull time like charge disk
#		Probably make that part of ThrowableItem and not have it in both
#		Make it shake the disk as timer gets closer until it finally just inaccurately launches

@export var aim_line: AimLine
@export var pull_draw: PullDraw
@export var charge_view: ChargeView
var asset_data: AssetData
var flight_data: FlightData = FlightData.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	charge_view.set_progress(-1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _input(_event: InputEvent) -> void:
	#handle_input(event)
	pass

func hold_action(_delta: float, incoming_basis: Basis, incoming_focus: bool) -> void:
	flight_data.focus_flight = incoming_focus
	# TODO This is being refactored from _process to here because it doesn't need to be there
	# Perform pull disk calls
	var only_primary_held: bool = Input.is_action_pressed(InputConfig.USER_INPUT.PRIMARY) and not Input.is_action_pressed(InputConfig.USER_INPUT.SECONDARY)
	if only_primary_held:
		pull_draw.begin_pull()
	elif Input.is_action_just_released(InputConfig.USER_INPUT.PRIMARY):
		pull_draw.reset_pull()
	## If right click is pressed while holding left reset throw
	if Input.is_action_just_pressed(InputConfig.USER_INPUT.SECONDARY):
		pull_draw.reset_pull()
		charge_view.set_progress(-1)
		reset_launch_parameters()
	## If right click isn't held while holding left click calculate throw distance (we know primary is held because this method is being called)
	elif not Input.is_action_pressed(InputConfig.USER_INPUT.SECONDARY):
		charge_view.set_progress((pull_draw.last_length / GameConfig.DEFAULTS.max_pull) * 100)
		var multiplier: float = (pull_draw.last_length / 100) * GameConfig.DEFAULTS.hold_multiplier
		flight_data.flight_path = aim_line.draw_aim_line(multiplier, pull_draw.last_offset * .01)
		flight_data.flight_global_basis = incoming_basis

# TODO Need to refactor to use FlightData and DiskFactory
func release_action(incoming_basis: Basis) -> void:
	## If right click is not held launch the disk
	if not Input.is_action_pressed(InputConfig.USER_INPUT.SECONDARY) and pull_draw.last_length > GameConfig.DEFAULTS.min_pull:
		var multiplier: float = min(GameConfig.DEFAULTS.max_hold, (pull_draw.last_length / 100)) * GameConfig.DEFAULTS.hold_multiplier
		var final_speed: float = GameConfig.DEFAULTS.launch_speed * multiplier
		flight_data = FlightData.create_flight_data(final_speed, incoming_basis, flight_data.flight_path, flight_data.focus_flight)
		# TODO create path_disk_data and pass it into the launch method
		AssetDelivery.create_and_launch(flight_data, asset_data)
		launched.emit()
		pick_up()
		self.rotation.x = 0
		charge_view.set_progress(-1)

func reset_launch_parameters() -> void:
	flight_data = FlightData.new()

func pick_up() -> void:
	queue_free()

func _set_asset_data(incoming_data: AssetData) -> void:
	asset_data = incoming_data
	if asset_data != null and !asset_data.group_name.is_empty() and !is_in_group(asset_data.group_name):
		add_to_group(asset_data.group_name)
