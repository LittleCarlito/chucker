extends Node3D

@onready var control_node: ControlNode = $ControlNode
@export var item_data: AssetData
@export var kickoff_timer: Timer
var _spawned: bool = false
var asset_spawn_data: Array[SpawnData]

# TODO Get Course objects to integrate data with Global Hole Data
# TODO Make set controls work
#			Create sub menu
# TODO Add more button fuctionality to menus
#		Tab should change selected button
#			Or change what tab is displayed when a different tab is the next object
#		Arrow keys should navigate buttons
#			Configured movement keys should move selected buttons
# TODO Create "Reset" button for settings
#		Have this just delete the user settings file
# TODO Add more force when path disk lands
#			Disks shoudl travel along ground
# TODO make disks able to tilt in air (like pivot object) so they roll when landing
# TODO Add wind
# TODO Add different landing resistances
# TODO Add hazards
#		Water
#		Bunkers
# TODO Fix chucking a disk over the edge
#		Make Environment asset that is "CourseFloor"
#			Add a signal for body exit
#			Code to queue_free to start with
#				Eventually will want to respawn people and disks at certain points
#					People probably right where they fell in
#					Disks spawn near where they fell in but perpindicular to hole playing or something like that
# TODO Make dynamic scorecard
#		Make each part of the scorecard a node object
#		Make a script to create the scorecard based off how many holes the scene contains
#		Also adds the number of players dynamically
#		Creates scroll bars to allow for more than 18 holes and more than 4 players
# TODO Give chuck a bag he carries
#		Allow the bag to have 6 x 6 inventory where disks are stored and can be chosen/equipped

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Spawn in Camera
	var rig_data: AssetData = AssetData.new(AssetData.TYPE.CAMERA, AssetData.ITEM_STATE.ACTIVATED, AssetData.CAMERA_STATE.ACTIVE)
	var rig_location: Vector3 = Vector3(0, 1, 0)
	var rig_spawn_data: SpawnData = SpawnData.new(rig_data, rig_location)
	# TODO Will need to redo camera state shit below for all of them with new camera setup
	# Spawn in Character
	var chuck_data: AssetData = AssetData.new(AssetData.TYPE.PLAYER, AssetData.ITEM_STATE.ACTIVATED, AssetData.CAMERA_STATE.ACTIVE)
	const chuck_location: Vector3 = Vector3(0, 1, 0)
	var chuck_spawn_data: SpawnData = SpawnData.new(chuck_data, chuck_location, self)
	# Spawn Path disk
	var path_data: AssetData = AssetData.new(AssetData.TYPE.FORCE, AssetData.ITEM_STATE.DEACTIVATED, AssetData.CAMERA_STATE.TRACKABLE, AssetData.TYPE.PULL)
	const path_location: Vector3 = Vector3(2, 4, -2)
	var path_spawn_data: SpawnData = SpawnData.new(path_data, path_location, self)
	# Spawn in ForceDisk
	var force_data: AssetData = AssetData.new(AssetData.TYPE.FORCE, AssetData.ITEM_STATE.DEACTIVATED, AssetData.CAMERA_STATE.EXISTS, AssetData.TYPE.CHARGE)
	const force_location: Vector3 = Vector3(-2, 4, -2)
	var force_spawn_data: SpawnData = SpawnData.new(force_data, force_location, self)
	# Spawn in TeeBox
	var tee_box_data: AssetData = AssetData.new(AssetData.TYPE.TEE)
	const tee_location: Vector3 = Vector3(0, 0, 0)
	var tee_spawn_data: SpawnData = SpawnData.new(tee_box_data, tee_location, self)
	# Spawn in Hole Node
	var hole_node_data: AssetData = AssetData.new(AssetData.TYPE.HOLE_NODE)
	const hole_node_location: Vector3 = Vector3(0, 5, -80)
	var hole_node_spawn_data: SpawnData = SpawnData.new(hole_node_data, hole_node_location, self)
	# Spawn in Hole
	var hole_data: AssetData = AssetData.new(AssetData.TYPE.HOLE)
	const hole_location: Vector3 = Vector3(0, 5, -80)
	var hole_spawn_data: SpawnData = SpawnData.new(hole_data, hole_location, self)
	# Spawn in Environment hazards
	var tree_data: AssetData = AssetData.new(AssetData.TYPE.ENV_TREE)
	const tree_location: Vector3 = Vector3(15, 0, -40)
	var tree_spawn_data: SpawnData = SpawnData.new(tree_data, tree_location, self)
	# Create and spawn master asset list
	asset_spawn_data = [
						rig_spawn_data,
						chuck_spawn_data, 
						path_spawn_data, 
						force_spawn_data, 
						tee_spawn_data,
						hole_node_spawn_data, 
						hole_spawn_data, 
						tree_spawn_data
						]
	kickoff_timer.connect(SIGNAL_NAME.TIMEOUT, _kickoff_data_load)
	kickoff_timer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _disable_character_movement() -> void:
	get_tree().call_group(GroupData.PLAYER, GroupData.DISABLE_MOVEMENT)

func _enable_character_movement() -> void:
	get_tree().call_group(GroupData.PLAYER, GroupData.ENABLE_MOVEMENT)

func _disable_character_rotation() -> void:
	get_tree().call_group(GroupData.PLAYER, GroupData.DISABLE_ROTATION)

func _enable_character_rotation() -> void:
	get_tree().call_group(GroupData.PLAYER, GroupData.ENABLE_ROTATION)

# TODO Loading settings is broken because we were reworking this to group method calls and never tested
func _apply_settings() -> void:
	get_tree().call_group(GroupData.GENERAL, GroupData.RELOAD_PROJECT_SETTINGS)

func update_course_data() -> void:
	get_tree().call_group(GroupData.GENERAL, GroupData.UPDATE_STATE)
	# TODO Call to make all the hole numbers sequential
	# TODO Continuation point for COURSE work
	#GlobalHoleData._set_data_sequential()

func _kickoff_data_load() -> void:
	var spawned_assets: Dictionary = AssetDelivery.spawn_assets(asset_spawn_data)
	# TODO Get the rig and the character to variables
	#			insert the character object as teh focus point of the rig
	var player_characters: Array = spawned_assets[AssetData.TYPE.PLAYER]
	var camera_rigs: Array = spawned_assets[AssetData.TYPE.CAMERA]
	if player_characters.size() > 0 && camera_rigs.size() > 0:
		var main_character: ChuckChucker = player_characters[0]
		var main_rig: CameraRig = camera_rigs[0]
		main_rig.make_current()
		main_rig.set_integration_point(main_character, true)
	update_course_data()
	_apply_settings()
