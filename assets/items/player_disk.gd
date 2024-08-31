extends ThrowableItem
class_name PlayerDisk

@export var thrownDisk: PackedScene = load(ASSET_MANAGEMENT.DISK.SCENE)

@onready var stopwatch: StopWatch = StopWatch.new()
@onready var aimNode: Node3D = Node3D.new()
@onready var aimControl: Node3D = Node3D.new()
@onready var launchControl: Node3D = Node3D.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Logger.set_log_level(Logger.LEVEL.DEBUG)
	NodeUtil.get_parent_heights(self)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed(USER_INPUT.ADMIN.DEBUG):
		NodeUtil.get_parent_heights(self)

# TODO Need to have default throwing distance with just click
#		Disable charging when programming this
#		Make it so that when rotating up aimNode initially goes further out (for 2 meter extension on z axis at 45 degrees, 1 degree is .04 meters)
#			But after 45 degrees it should start decreasing in distance
#			If aimed 90 degrees it should go up and come back down

## Power up launch and create aim line
func hold_action(delta: float) -> void:
	# TODO WHAT IF THE REAL SOLUTION IS JUST TO CHUCK AN INVISIBLE NODE LIKE YOU WOULD A DISK, GET ITS PATH AND DRAW THE CURVE UP TO WHERE IT COLLIDES WITH THE GROUND
	#		Even if this isn't easier could be something like a "TracerDisk" that gives a ghost disk path before you throw
	var heldTime: float = stopwatch.isHeld(delta)
	# Handle launch control node
	var rotationDistance: float = .065 * NodeUtil.get_parent_x_rotation(self)
	launchControl.position = self.global_position
	launchControl.basis = self.global_basis
	var launchControlTranslate: Vector3 = Vector3(0, 0, -rotationDistance)
	launchControl.translate(launchControlTranslate)
	DrawUtil.point(launchControl.position, .05, Color.DEEP_PINK)
	# Handle aiming node
	# TODO See if adding a raycast thing will solve jumping issue
	aimNode.position = self.global_position
	aimNode.basis = self.global_basis
	aimNode.rotation_degrees.x = 0
	# TODO Try to figure out how to have aim point move to point around where disk ends up
	# TODO Multiply the multiplier by some value to make it more intense as the stopwatch grows (z short at beginning long at end)
	var multiplier: float = min(stopwatch.getTime(), GLOBAL_SETTINGS.DISK.MAX_HOLD) * .5
	# TODO Make increases past 45 work in the opposite direction for z translation
	#		Will need to make it so the curve maxes out at a certain point
	#		Can then see how this affects distance on aim point at max distance
	#			Wont really be observable when curve is expanding
	var aimTranslate: Vector3 = Vector3(0, (-NodeUtil.get_parent_heights(self)), (-(GLOBAL_SETTINGS.DISK.LAUNCH_SPEED * multiplier) + (rotationDistance * .5)))
	aimNode.translate(aimTranslate)
	DrawUtil.point(aimNode.position)
	# Handle aiming control node
	aimControl.position = aimNode.position
	aimControl.position.y = launchControl.position.y
	aimControl.basis = aimNode.basis
	# TODO Need to tone down the rotation distance on this one a bit
	var aimControlTranslate: Vector3 = Vector3(0, 1, -(rotationDistance * .8))
	aimControl.translate(aimControlTranslate)
	# TODO Default position this needs to be further back and lower
	DrawUtil.point(aimControl.position, .05, Color.ORANGE_RED)
	# Draw curve
	DrawUtil.curve(self.global_position, launchControl.position, aimControl.position, aimNode.position)

## Launch disk and reset objects
func release_action() -> void:
	var multiplier = min(stopwatch.getTime(), GLOBAL_SETTINGS.DISK.MAX_HOLD)
	stopwatch.reset()
	var newDisk = thrownDisk.instantiate()
	get_tree().get_root().add_child(newDisk)
	newDisk.global_transform = self.global_transform
	newDisk.linear_velocity = -newDisk.global_transform.basis.z * (GLOBAL_SETTINGS.DISK.LAUNCH_SPEED * multiplier)
	self.rotation.x = 0
	Logger.debug("\n\n\n\n\n", [])
