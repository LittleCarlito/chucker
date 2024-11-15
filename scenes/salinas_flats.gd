extends Node3D

@onready var controlNode: ControlNode = $ControlNode
@onready var chuckChucker: ChuckChucker = $ChuckChucker

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
# TODO Give chuck a bag he carries
#		Allow the bag to have 6 x 6 inventory where disks are stored and can be chosen/equipped

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		Logger.error(str(event.button_index), [], self)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self._apply_settings()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _disable_character_movement() -> void:
	chuckChucker.disableMovement = true

func _enable_character_movement() -> void:
	chuckChucker.disableMovement = false

func _apply_settings() -> void:
	# TODO Was removing all user inputs improperly
	#controlNode.reload_project_settings()
	chuckChucker.load_settings()
