extends ThrowableItem
class_name MathDisk

@export var thrownDisk: PackedScene = load(ASSET_MANAGEMENT.DISK.SCENE)

@onready var aimNode: Node3D = Node3D.new()
@onready var aimControlNode: Node3D = Node3D.new()
@onready var launchControlNode: Node3D = Node3D.new()
var stopWatch: StopWatch = StopWatch.new()

# TODO Add charge meter
# TODO Add charge effects
# TODO Add "perfect" release window
# TODO Give "perfect" release different effects

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Logger.set_log_level(Logger.LEVEL.DEBUG)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func hold_action(delta: float) -> void:
	var heldTime: float = stopWatch.isHeld(delta)
	var multiplier: float = min(GLOBAL_SETTINGS.DISK.MAX_HOLD, heldTime) * GLOBAL_SETTINGS.DISK.HOLD_MULTIPLIER
	var gravity: float = abs(NodeUtil.get_gravity(self).y)
	var parentRotation: float = NodeUtil.get_parent_x_rotation(self)
	var height: float = NodeUtil.get_parent_heights(self)
	var throwSpeed: float = GLOBAL_SETTINGS.DISK.LAUNCH_SPEED * multiplier
	var zDistance: float = NodeUtil.calculate_range(height, gravity, parentRotation, throwSpeed)
	# Handle aiming node
	aimNode.position = self.global_position
	aimNode.basis = self.global_basis
	aimNode.rotation_degrees.x = 0
	var aimTranslate: Vector3 = Vector3(0, -height, -zDistance)
	aimNode.translate(aimTranslate)
	DrawUtil.point(aimNode.position)
	# Handle launch control node
	launchControlNode.position = self.global_position
	launchControlNode.basis = self.global_basis
	var launchControlTranslate: Vector3 = Vector3(0, 0, -(zDistance/3))
	launchControlNode.translate(launchControlTranslate)
	DrawUtil.point(launchControlNode.position, .05, Color.BLUE)
	# Handle aim control node
	aimControlNode.position = aimNode.position
	aimControlNode.position.y = launchControlNode.position.y
	var rotationAdjust: float = deg_to_rad(parentRotation) * 2.25
	aimControlNode.basis = self.global_basis
	var aimControlTranslate: Vector3 = Vector3(0, rotationAdjust, zDistance/4 + -rotationAdjust)
	aimControlNode.translate(aimControlTranslate)
	DrawUtil.point(aimControlNode.position, .05, Color.DEEP_PINK)
	# Draw the curve
	DrawUtil.curve(self.global_position, launchControlNode.position, aimControlNode.position, aimNode.position)

## Launch disk and reset objects
func release_action() -> void:
	var finalTime: float = stopWatch.reset()
	var multiplier: float = min(GLOBAL_SETTINGS.DISK.MAX_HOLD, finalTime) * GLOBAL_SETTINGS.DISK.HOLD_MULTIPLIER
	var newDisk = thrownDisk.instantiate()
	get_tree().get_root().add_child(newDisk)
	newDisk.global_transform = self.global_transform
	newDisk.linear_velocity = -newDisk.global_transform.basis.z * (GLOBAL_SETTINGS.DISK.LAUNCH_SPEED * multiplier)
	self.rotation.x = 0
