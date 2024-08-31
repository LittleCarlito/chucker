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

## Power up launch and create aim line
func hold_action(delta: float) -> void:
	# TODO WHAT IF THE REAL SOLUTION IS JUST TO CHUCK AN INVISIBLE NODE LIKE YOU WOULD A DISK, GET ITS PATH AND DRAW THE CURVE UP TO WHERE IT COLLIDES WITH THE GROUND
	#		Even if this isn't easier could be something like a "TracerDisk" that gives a ghost disk path before you throw
	var heldTime: float = stopwatch.isHeld(delta)
	# Handle launch control node
	launchControl.position = self.global_position
	launchControl.basis = self.global_basis
	var launchControlTranslate: Vector3 = Vector3(0, 0, -1)
	launchControl.translate(launchControlTranslate)
	DrawUtil.point(launchControl.position, .05, Color.DEEP_PINK)
	# Handle aiming node
	# TODO See if adding a raycast thing will solve jumping issue
	aimNode.position = self.global_position
	aimNode.basis = self.global_basis
	aimNode.rotation_degrees.x = 0
	# TODO Try to figure out how to have aim point move to point around where disk ends up
	var multiplier = min(stopwatch.getTime(), GLOBAL_SETTINGS.DISK.MAX_HOLD)
	var zDistance: float = aimNode.position.z
	var aimTranslate: Vector3 = Vector3(0, -NodeUtil.get_parent_heights(self, zDistance), -(GLOBAL_SETTINGS.DISK.LAUNCH_SPEED * multiplier))
	aimNode.translate(aimTranslate)
	DrawUtil.point(aimNode.position)
	# Handle aiming control node
	aimControl.position = aimNode.position
	aimControl.basis = aimNode.basis
	var aimControlTranslate: Vector3 = Vector3(0, 1.2, 1 + (heldTime * 3))
	aimControl.translate(aimControlTranslate)
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
