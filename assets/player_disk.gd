extends MeshInstance3D
class_name PlayerDisk

@export var thrownDisk: PackedScene = load(ASSET_MANAGEMENT.DISK.SCENE)

@onready var stopwatch: StopWatch = StopWatch.new()
@onready var aimNode: Node3D = Node3D.new()
@onready var aimControl: Node3D = Node3D.new()
@onready var launchControl: Node3D = Node3D.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

## Power up launch and create aim line
func power_up_launch(delta: float) -> void:
	stopwatch.isHeld(delta)
	var heldTime: float = stopwatch.getTime()
	# TODO Need aiming nodes to follow chuck if he falls (they stay on current plane)
	# TODO Height of control nodes needs to be shorter to start with (beginning curve is huge)
	# TODO AimControl point should start closer on z access and get further as you charge
	# Handle aiming node
	aimNode.position = self.global_position
	aimNode.position.y = 0
	aimNode.basis = self.global_basis
	var aimTranslate: Vector3 = Vector3(0, 0, -(heldTime * 10))
	aimNode.translate(aimTranslate)
	DrawUtil.point(aimNode.position)
	# Handle aiming control node
	aimControl.position = aimNode.position
	aimControl.position.y += 1 + (.6 * heldTime)
	aimControl.basis = aimNode.basis
	# TODO Refactor to make this realtive to the disk instead of chuck stuff
	var zDistance: float = self.position.z - aimNode.position.z
	var aimControlTranslate: Vector3 = Vector3(0, 0, (zDistance/2))
	aimControl.translate(aimControlTranslate)
	DrawUtil.point(aimControl.position, .05, Color.ORANGE_RED)
	# Handle launch control node
	launchControl.position = self.global_position
	launchControl.position.y = min(aimControl.position.y, 2)
	launchControl.basis = self.global_basis
	var launchControlTranslate: Vector3 = Vector3(0, 0, -(zDistance/2))
	launchControl.translate(launchControlTranslate)
	DrawUtil.point(launchControl.position, .05, Color.DEEP_PINK)
	print("zDistance " + str(zDistance))
	# Draw curve
	DrawUtil.curve(self.global_position, launchControl.position, aimControl.position, aimNode.position)

## Launch disk and reset objects
func launch_disk() -> void:
	var multiplier = min(stopwatch.getTime(), GLOBAL_SETTINGS.DISK.MAX_HOLD)
	stopwatch.reset()
	var willWork = thrownDisk.can_instantiate();
	var newDisk = thrownDisk.instantiate()
	get_tree().get_root().add_child(newDisk)
	newDisk.global_transform = self.global_transform
	newDisk.linear_velocity = -newDisk.global_transform.basis.z * (GLOBAL_SETTINGS.DISK.LAUNCH_SPEED * multiplier)
	self.rotation.x = 0
