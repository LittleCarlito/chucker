extends EquipableItem
class_name ThrowableItem

var ownerVar: ChuckChucker
var fallbackCamera: Camera3D
var aimNode: Node3D = Node3D.new()
var aimControlNode: Node3D = Node3D.new()
var launchControlNode: Node3D = Node3D.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ownerVar = self.owner
	if ownerVar != null:
		fallbackCamera = ownerVar.get_camera()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func hold_action(_delta: float) -> void:
	push_error("UNIMPLEMENTED METHOD; All ThrowableItem Objects must implement hold_action method")

func release_action() -> void:
	push_error("UNIMPLEMENTED METHOD; All ThrowableItem Objects must implement release_action method")

func handle_aiming() -> void:
	push_error("UNIMPLEMENTED METHOD; All ThrowableItem Objects must implement handle_aiming method")

func set_just_launched(value: bool) -> void:
	push_error("UNIMPLEMENTED METHOD; All ThrowableItem Objects must implement set_just_launched method")

func draw_aim_line(multiplier: float) -> void:
	var gravity: float = abs(NodeUtil.get_gravity(self).y)
	var parentRotation: float = NodeUtil.get_parent_x_rotation(self)
	var height: float = self.global_position.y
	#var height: float = NodeUtil.get_parent_heights(self)
	var throwSpeed: float = GLOBAL_SETTINGS.DISK.LAUNCH_SPEED * multiplier
	# move_and_slide() is a liar so this will always be an approximation
	var zDistance: float = NodeUtil.calculate_range(height, gravity, parentRotation, throwSpeed)
	var gravityAdjust: float = gravity * GLOBAL_SETTINGS.DISK.GRAVITY_MULTIPLIER
	# Handle aimNode
	aimNode.position = self.global_position
	aimNode.basis = self.global_basis
	aimNode.rotation_degrees.x = 0
	aimNode.translate(Vector3(0, -height, -zDistance))
	DrawUtil.point(aimNode.position)
	# Handle launchControlNode
	launchControlNode.position = self.global_position
	launchControlNode.basis = self.global_basis
	launchControlNode.translate(Vector3(0, 0, -zDistance / 3))
	DrawUtil.point(launchControlNode.position, .05, Color.BLUE)
	# Handle aimControlNode
	aimControlNode.position = self.global_position
	aimControlNode.basis = aimNode.basis
	# Apply negative translate to flatten the curve
	var controlPointHeight: float = (zDistance / 2.0) * tan(deg_to_rad(parentRotation)) * gravityAdjust
	aimControlNode.translate(Vector3(0, controlPointHeight, -zDistance / 2))
	DrawUtil.point(aimControlNode.position, .05, Color.DEEP_PINK)
	# Draw the curve
	DrawUtil.curve(self.global_position, launchControlNode.position, aimControlNode.position, aimNode.position)

# TODO Eventually take in enum for launch type of disk so when it is picked up character equips correct type
func launch_disk(multiplier: float) -> void:
	var newDisk = ChuckDisk.new_disk(fallbackCamera, ownerVar)
	newDisk.top_level = true
	get_tree().get_root().add_child(newDisk)
	newDisk.global_transform = self.global_transform
	newDisk.linear_velocity = -newDisk.global_transform.basis.z * (GLOBAL_SETTINGS.DISK.LAUNCH_SPEED * multiplier)
	self.rotation.x = 0
	if newDisk is ChuckDisk:
		newDisk.toggle_camera()
		ownerVar.disableMovement = true
		self.justLaunched = true
	ownerVar.toggle_equiped(false)
