extends Node3D

@onready var control_node: ControlNode = $ControlNode
@export var item_data: ItemData

# TODO ChuckChucker and Disks need to be spawned in here programatically
#		This is important because they will then be generated (hopefully) with appended names and groups assigned to them
#		These groups are how everything is then controlled
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
# TODO Get DiskFactory refactored to ItemFactory
# TODO Get ItemFactory spawn_item method working
func _ready() -> void:
	# Spawn in Character
	var chuck_data: ItemData = ItemData.create_item_data(ItemData.TYPE.PLAYER, ItemData.ITEM_STATE.ACTIVATED, ItemData.CAMERA_STATE.ACTIVE)
	var chuck_location: Vector3 = Vector3(0, 1, 0)
	DiskFactory.spawn_item(chuck_data, chuck_location)
	# Spawn in PathDisk
	var path_data: ItemData = ItemData.create_item_data(ItemData.TYPE.PATH, ItemData.ITEM_STATE.DEACTIVATED)
	var path_location: Vector3 = Vector3(2, 4, -2)
	DiskFactory.spawn_item(path_data, path_location)
	# Spawn in ForceDisk
	var force_data: ItemData = ItemData.create_item_data(ItemData.TYPE.FORCE, ItemData.ITEM_STATE.DEACTIVATED)
	var force_location: Vector3 = Vector3(-2, 4, -2)
	get_tree().call_group(CONSTANTS.GENERAL, CONSTANTS.UPDATE_STATE)
	DiskFactory.spawn_item(force_data, force_location)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _disable_character_movement() -> void:
	get_tree().call_group(CONSTANTS.CHARACTER, CONSTANTS.DISABLE_MOVEMENT)

func _enable_character_movement() -> void:
	get_tree().call_group(CONSTANTS.CHARACTER, CONSTANTS.ENABLE_MOVEMENT)

func _disable_character_rotation() -> void:
	get_tree().call_group(CONSTANTS.CHARACTER, CONSTANTS.DISABLE_ROTATION)

func _enable_character_rotation() -> void:
	get_tree().call_group(CONSTANTS.CHARACTER, CONSTANTS.ENABLE_ROTATION)

func _apply_settings() -> void:
	get_tree().call_group(CONSTANTS.GENERAL, CONSTANTS.RELOAD_PROJECT_SETTINGS)
