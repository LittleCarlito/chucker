extends ThrowableItem
class_name ChargeDisk

const _FLIGHT_DATA_NOT_SET: String = "FlightData not set; Cannot set flight global basis"

var stopwatch: Stopwatch


# TODO Refactor state to be singular
#		Don't want multiple state objects
#		Right now Force disk has _update_state and it isn't part of ItemStateConfig

# OUTLINE: STATE
#		X 	Get it all cleaned out so itemconfig can be deleted and all non "real" state files can be purged
#			Look at how branding is working
#				Ensure UUIDs are made for uniqueness in multiplayer as well
#				Use UUIDs as keys in the dictionaries for getting states
#			TODO Create a camera_state like the others
#					For tracking the camera(s)
#					Probably will need a CameraStateData or something too
#			Work all properties and things like AssetData into state
#			Then have everythign working again from there
#				Includes spin
#				State setting on holds
#				Camera focusing
#				Zooming
#				Idle rotating

# TODO Hunt down the rest of Input. reads that aren't in GlobalInputController
# TODO After state is refactored
#		- Fix assets input handling to ensure moving when want
#			- Don't want chuck moving when camera isn't looking at him
#				- This logic then gets rid of things like disable movement as the camera determines enablement
#		- Fix idle rotate logic to work
#		- Fix allow zoom/looking based off equipment and or character with calls to GlobalCameraController restricted by objects state
#		Need state working for objects CAMERA_STATE to restrict Global calls for signals to things like idling
# TODO Refactor menu system
#			Get it on GlobalInputController
#			No more nested menus
#			Each menu screen is its own top level thing
#			Each one just opens a different one
#			ESC from options menu closes it and opens pause menu
#			ESC in pause menu closes all menus and resume
#			Clicking options from pause menu closes pause menu and opens options menu
# TODO Refactor configuration directory stuff
#			Most can be @export options on objects in scenes
#			Those that can't should fit into game_config.gd
# BUG Need mouse VISIBLE on disk collisions
#		Should give mouse back and then idle around for a few seconds
#		Users in this state shoudl be able to click and control camera as well
#			Clicking again then makes the mouse VISIBLE again
# TODO Do SIGNAL_NAME TODOs
# TODO Do Node Util TODOs
# TODO Do force disk TODOs
# TODO Do salinas flats TODOs

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	self.stopwatch = Stopwatch.new()
	if self.asset_data != null and !self.asset_data.group_name.is_empty():
		add_to_group(self.asset_data.group_name)

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
		self.asset_data.internal_type, 
		self.asset_data.group_name, 
		self.asset_data.owner_rid
		)

# TODO Fix this once state is workign again
# func _update_spin_value() -> void:
# 	var current_state: ItemState.STATE = self.get_current_state()
# 	var spin_amount: float = STATE_DEFAULTS.get_spin_amount(current_state) * GameConfig.DEFAULTS.spin_multiplier
# 	self.flight_data.set_flight_spin(spin_amount)
