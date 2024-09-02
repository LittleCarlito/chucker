extends ThrowableItem
class_name PlayerDisk

@export var thrownDisk: PackedScene = load(ASSET_MANAGEMENT.DISK.SCENE)

@onready var aimNode: Node3D = Node3D.new()
@onready var aimControlNode: Node3D = Node3D.new()
@onready var launchControlNode: Node3D = Node3D.new()
var stopWatch: StopWatch = StopWatch.new()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Logger.set_log_level(Logger.LEVEL.DEBUG)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func hold_action(delta: float) -> void:
	var gravity: float = abs(NodeUtil.get_gravity(self).y)
	var parentRotation: float = NodeUtil.get_parent_x_rotation(self)
	var height: float = NodeUtil.get_parent_heights(self)
	var throwSpeed: float = GLOBAL_SETTINGS.DISK.LAUNCH_SPEED
	var zDistance: float = NodeUtil.calculate_range(height, gravity, parentRotation, throwSpeed)
	# Handle aiming node
	stopWatch.isHeld(delta)
	aimNode.position = self.global_position
	aimNode.basis = self.global_basis
	aimNode.rotation_degrees.x = 0
	var aimTranslate: Vector3 = Vector3(0, -height, -zDistance)
	aimNode.translate(aimTranslate)
	DrawUtil.point(aimNode.position)
	# Handle aim control node
	aimControlNode.position = self.global_position
	aimControlNode.basis = self.global_basis
	var aimControlTranslate: Vector3 = Vector3(0, 0, -GLOBAL_SETTINGS.DISK.LAUNCH_SPEED)
	aimControlNode.translate(aimControlTranslate)
	DrawUtil.point(aimControlNode.position, .05, Color.DEEP_PINK)
	# Handle launch control node
	launchControlNode.position = self.global_position
	launchControlNode.basis = self.global_basis
	var launchControlTranslate: Vector3 = Vector3(0, 0, 0)
	launchControlNode.translate(launchControlTranslate)
	DrawUtil.point(launchControlNode.position, .05, Color.BLUE)
	# Draw the curve
	DrawUtil.curve(self.global_position, launchControlNode.position, aimControlNode.position, aimNode.position)

## Launch disk and reset objects
func release_action() -> void:
	stopWatch.reset()
	var newDisk = thrownDisk.instantiate()
	get_tree().get_root().add_child(newDisk)
	newDisk.global_transform = self.global_transform
	newDisk.linear_velocity = -newDisk.global_transform.basis.z * GLOBAL_SETTINGS.DISK.LAUNCH_SPEED
	self.rotation.x = 0
