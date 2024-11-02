extends Node3D

@onready var chuckChucker: ChuckChucker = $ChuckChucker

# TODO Add settings to esc menu
#		With ability to define used controls
# TODO Make FOV configurable between a certain range
# TODO Fix chucking a disk over the edge
#		Make Environment asset that is "CourseFloor"
#			Add a signal for body exit
#			Code to queue_free to start with
#				Eventually will want to respawn people and disks at certain points
#					People probably right where they fell in
#					Disks spawn near where they fell in but perpindicular to hole playing or something like that
# TODO Give chuck a bag he carries
#		Allow the bag to have 6 x 6 inventory where disks are stored and can be chosen/equipped

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _disable_character_movement() -> void:
	chuckChucker.disableMovement = true	

func _enable_character_movement() -> void:
	chuckChucker.disableMovement = false
