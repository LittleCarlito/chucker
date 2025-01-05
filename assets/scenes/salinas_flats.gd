extends Node3D

@onready var control_node: ControlNode = $ControlNode
@export var item_data: AssetData
@export var kickoff_timer: Timer

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
# TODO Switch this to loading assets from file for the map
# TODO Condense the spawn call to a single call with arrays or dictionary
func _ready() -> void:
	# Spawn in Character
	var chuck_data: AssetData = AssetData.create_item_data(AssetData.TYPE.PLAYER, AssetData.ITEM_STATE.ACTIVATED, AssetData.CAMERA_STATE.ACTIVE)
	var chuck_location: Vector3 = Vector3(0, 1, 0)
	AssetDelivery.spawn_asset(chuck_data, self, chuck_location)
	# Spawn Path disk
	var path_data: AssetData = AssetData.create_item_data(AssetData.TYPE.PATH, AssetData.ITEM_STATE.DEACTIVATED)
	var path_location: Vector3 = Vector3(2, 4, -2)
	AssetDelivery.spawn_asset(path_data, self, path_location)
	# Spawn in ForceDisk
	var force_data: AssetData = AssetData.create_item_data(AssetData.TYPE.FORCE, AssetData.ITEM_STATE.DEACTIVATED, AssetData.CAMERA_STATE.EXISTS, AssetData.TYPE.CHARGE)
	var force_location: Vector3 = Vector3(-2, 4, -2)
	AssetDelivery.spawn_asset(force_data, self, force_location)
	# Spawn in TeeBox
	var tee_box_data: AssetData = AssetData.create_item_data(AssetData.TYPE.TEE)
	var tee_location: Vector3 = Vector3(0, 0, 0)
	AssetDelivery.spawn_asset(tee_box_data, self, tee_location)
	# Spawn in Hole Node
	var hole_node_data: AssetData = AssetData.create_item_data(AssetData.TYPE.HOLE_NODE)
	var hole_node_location: Vector3 = Vector3(0, 5, -80)
	AssetDelivery.spawn_asset(hole_node_data, self, hole_node_location)
	# Spawn in Hole
	var hole_data: AssetData = AssetData.create_item_data(AssetData.TYPE.HOLE)
	var hole_location: Vector3 = Vector3(0, 5, -80)
	AssetDelivery.spawn_asset(hole_data, self, hole_location)
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
	update_course_data()
	_apply_settings()
