extends ThrowableItem
class_name ChargeDisk

const _FLIGHT_DATA_NOT_SET: String = "FlightData not set; Cannot set flight global basis"

var stopwatch: Stopwatch

# BUG Camera on path disk spins with disk
# OUTLINE
# 	Will need to create new camera type
#		Rework existing system while at it as well
#		Need a camera that exists in a container and scene
#			Then uses RemoteTransform with transforms on matching object to keep up
#				Would do transforms like mvoement but not rotation to avoid the spin
# FIRST
#	Need to determine how the camera(s) are being made in the scene currently
#	Create a new flow where one is made in the scene file with the other assets
#		This will be the new camera type that operates like written notes from notebook
# SECOND
#	Come up with way to toggle of current camera setup
#	The toggle for disabling current camera setup should enable the new setup
# THIRD
#	Come up with actual design for new camera system
#
# RESEARCH RESULTS
#	FIRST
# 		.populate_camera_control() on camera container is how cameras are created and activated
#			Both ChuckChucker and ChuckTee rely on this to create their cameras
#				Both set to active when createc
#			ChuckTee then detects any ChuckChucker in it and deactivates its camera
#	SECOND
#		Create boolean variable in Application Config
#			Used to set value between current and new camera setup
#		If new variable true populate cameras in containers with current calls
#			If false use new way of camera handling
#	THIRD
#		New camera created in scene _ready() function with asset spawn data
#			See if you can get the factory/delivery to handle it as well just for consistency
#		Camera Structure
#			Same as Camera container
#			Camera, inside a camera rig inside the camera controller
#			New part is a Node3D which is at 0 0 0 which is what the camera focuses on
#				Could move node in local space and camera should track it
#					But the idea would be to just keep it at origin locally
#			Camera sits an 000 locally in its rig which sits and orients looking at the new Node3D point at origin
#			CameraContainer is then just the scturcture that holds all this
#				Will want to keep that name as I think the other way will just be deleted
#				But for transition will need a temporary name
#		Asset Structure
#			Assets no longer have camera containers in new structure
#				Will keep them for this transition though but once new type works it is getting renamed and old is deleted
#			New part is
#				A Node3D that is part of the character referencing where on the body it would want the camera to focus
#				The Node should be returnable so the camera can have a reference to it
#			Characters and items you would want to be able to follow with a camera would need this new structure for proper "docking"
#				Could just have the camera track the RID or something but this seems more fun/customizable with focal point
#		Camera & Asset Logic
#			Assets need to have new signals made for remotely controlling the camera based off events/detected input
#				Need to be able to tell from source of truth for equiped/input what to do with camera
#					Could be item or character
#				Will have fallback logic on camera container if what it is connected to has nothing
#			New camera setup needs logic to handle new signals
#				Will need to have these functions hooked up in its docking functions
#			New camera needs its own input handling
#				When docked/focusing need to ensure to respect that Assets functions
#					If nothing found or nothing there have its own logic handle it
#			When not connected to anything (or no overriding function in connected object)  should be
#				WASD controls based off Node3D focal point
#				Space is go up
#				C is go down
#				Mouse movements move the camera around the focal point just like rotation stuff currently works

# TODO Create InputController
#			Have it post input events to actual game events in an event bus
#			Things that then should be responding to those actions are then looking for them in the bus
#				i.e. things that have movement enabled are looking for movement events in the bus and would move together
# TODO Refactor menu system
#			Get it on GlobalInputController
#			No more nested menus
#			Each menu screen is its own top level thing
#			Each one just opens a different one
#			ESC from options menu closes it and opens pause menu
#			ESC in pause menu closes all menus and resume
#			Clicking options from pause menu closes pause menu and opens options menu
# TODO Refactor state to be singular
#		Don't want multiple state objects
#		Right now Force disk has _update_state and it isn't part of ItemStateConfig
# TODO Refactor configuration directory stuff
#			Most can be @export options on objects in scenes
#			Those that can't should fit into game_config.gd
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
