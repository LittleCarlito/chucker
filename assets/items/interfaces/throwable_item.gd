extends EquipableItem
class_name ThrowableItem

# TODO Make the disks spin with passed in speed when launched
#			Should be able to make it spin counter/clockwise depending on sign

const _HOLD_ACTION: String = "hold_action"
const _RELEASE_ACTION: String = "release_action"
const _NOT_LAUNCH_READY_LOG: String = "ThrowableItem has not had its launch parameters set and could not be thrown"

var aim_node: Node3D = Node3D.new()
var aim_control_node: Node3D = Node3D.new()
var launch_control_node: Node3D = Node3D.new()
var launch_path: Array[Vector3] = []
var launch_speed: float = 0.0
var launch_angle: float = 0.0
var launch_ready: bool = false
var focus_on_launch = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func hold_action(_delta: float) -> void:
	Logger.error(CONSTANTS.UNIMPLEMENTED_LOG, [self.name, _HOLD_ACTION], self)

func release_action() -> void:
	Logger.error(CONSTANTS.UNIMPLEMENTED_LOG, [self.name, _RELEASE_ACTION], self)

func set_launch_parameters(incoming_path: Array[Vector3], incoming_speed: float, incoming_angle: float, is_focused:bool = false) -> void:
	launch_path = incoming_path
	launch_speed = incoming_speed
	launch_angle = incoming_angle
	launch_ready = true
	focus_on_launch = is_focused

func reset_launch_parameters() -> void:
	launch_path = []
	launch_speed = 0
	launch_angle = 0
	launch_ready = false

func launch_disk() -> void:
	if launch_ready:
		DiskFactory.create_and_launch(self)
	else:
		Logger.error(_NOT_LAUNCH_READY_LOG, [], self)
	self.rotation.x = 0
	aim_disabled = true
	item_owner.disable_movement()
	item_owner.unequip_item()

func draw_aim_line(multiplier: float, x_offset: float = 0) -> Array[Vector3]:
	var gravity: float = abs(NodeUtil.get_gravity(self).y)
	var parent_rotation: float = NodeUtil.get_parent_x_rotation(self)
	var height: float = self.global_position.y
	#var height: float = NodeUtil.get_parent_heights(self)
	var throw_speed: float = GlobalSettings.DISK.LAUNCH_SPEED * multiplier
	# move_and_slide() is a liar so this will always be an approximation
	var z_distance: float = NodeUtil.calculate_range(height, gravity, parent_rotation, throw_speed)
	var gravity_adjust: float = gravity * GlobalSettings.DISK.GRAVITY_MULTIPLIER
	# Handle aimNode
	aim_node.position = self.global_position
	aim_node.basis = self.global_basis
	aim_node.rotation_degrees.x = 0
	aim_node.translate(Vector3(0, -height, -z_distance))
	DrawUtil.point(aim_node.position)
	# Handle launchControlNode
	launch_control_node.position = self.global_position
	launch_control_node.basis = self.global_basis
	launch_control_node.translate(Vector3(x_offset, 0, -z_distance / 3))
	DrawUtil.point(launch_control_node.position, .05, Color.BLUE)
	# Handle aimControlNode
	aim_control_node.position = self.global_position
	aim_control_node.basis = aim_node.basis
	# Apply negative translate to flatten the curve
	var control_point_height: float = (z_distance / 2.0) * tan(deg_to_rad(parent_rotation)) * gravity_adjust
	aim_control_node.translate(Vector3(x_offset, control_point_height, -z_distance / 2))
	DrawUtil.point(aim_control_node.position, .05, Color.DEEP_PINK)
	# Draw the curve
	return DrawUtil.curve(self.global_position, launch_control_node.position, aim_control_node.position, aim_node.position)

func get_launch_path() -> Array[Vector3]:
	return launch_path

func get_launch_speed() -> float:
	return launch_speed

func get_launch_angle() -> float:
	return launch_angle
