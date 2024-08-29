extends ThrowableItem

@export var thrownDisk: PackedScene = load(ASSET_MANAGEMENT.DISK.SCENE)

@onready var stopwatch: StopWatch = StopWatch.new()
@onready var aimNode: Node3D = Node3D.new()
@onready var aimControl: Node3D = Node3D.new()
@onready var launchControl: Node3D = Node3D.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

## Power up launch and create aim line
func hold_action(delta: float) -> void:
	# TODO WHAT IF THE REAL SOLUTION IS JUST TO CHUCK AN INVISIBLE NODE LIKE YOU WOULD A DISK, GET ITS PATH AND DRAW THE CURVE UP TO WHERE IT COLLIDES WITH THE GROUND
	#		Man that seems a lot easier than all this math shit
	var heldTime: float = stopwatch.isHeld(delta)
	# Handle launch control node
	launchControl.position = self.global_position
	launchControl.position.y = MeasureUtil.get_parent_heights(0, self) + .2
	launchControl.basis = self.global_basis
	var launchControlTranslate: Vector3 = Vector3(0, 0, -1)
	launchControl.translate(launchControlTranslate)
	DrawUtil.point(launchControl.position, .05, Color.DEEP_PINK)
	# Handle aiming node
	aimNode.position = self.global_position
	aimNode.basis = self.global_basis
	# TODO Try to figure out how to have aim point move to point around where disk ends up
	var multiplier = min(stopwatch.getTime(), GLOBAL_SETTINGS.DISK.MAX_HOLD)
	# TODO MeasureUtil thing doesn't actually get proper height because of rotation up of disk or angling down of ground
	#		Could add taking angle of y into account for heigh calculation as good math exercise
	#		Another solution is to add ray cast down from aim point to find collision distance and move height down
	#		Best soltuion is to have both and default to calculated ground level when no collision is found
	# TODO Could add zDistance to get_parent_heights to allow for y angle to be included in height measurement
	#			Do the zDistance as an optional parameter
	var aimTranslate: Vector3 = Vector3(0, -MeasureUtil.get_parent_heights(0, self), -(GLOBAL_SETTINGS.DISK.LAUNCH_SPEED * multiplier))
	aimNode.translate(aimTranslate)
	DrawUtil.point(aimNode.position)
	# Handle aiming control node
	aimControl.position = aimNode.position
	aimControl.position.y = launchControl.position.y *.45
	aimControl.basis = aimNode.basis
	var aimControlTranslate: Vector3 = Vector3(0, 0, -(aimNode.position.z/2))
	aimControl.translate(aimControlTranslate)
	# TODO Confirmed to be fucky when aiming backwards
	DrawUtil.point(aimControl.position, .05, Color.ORANGE_RED)
	# Draw curve
	DrawUtil.curve(self.global_position, launchControl.position, aimControl.position, aimNode.position)
	var zDistance: float = self.position.distance_to(aimControl.position)
	var formatString: String = "zDistance: \"%s\", heldTime: \"%s\""
	Logger.debug(formatString, [str(zDistance), str(heldTime)])

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
