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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func hold_action(_delta: float) -> void:
	Logger.error(CONSTANTS._UNIMPLEMENTED_LOG, [self.name, _HOLD_ACTION], self)

func release_action() -> void:
	Logger.error(CONSTANTS._UNIMPLEMENTED_LOG, [self.name, _RELEASE_ACTION], self)

func set_launch_parameters(incoming_path: Array[Vector3], incoming_speed: float, incoming_angle: float) -> void:
	launch_path = incoming_path
	launch_speed = incoming_speed
	launch_angle = incoming_angle
	launch_ready = true

func reset_launch_parameters() -> void:
	launch_path = []
	launch_speed = 0
	launch_angle = 0
	launch_ready = false

func launch_disk() -> void:
	if launch_ready:
		# TODO This is what the DiskFactory's main method should do; Take in a ThrowableItem and spawn something from it
		match item_type:
			# BUG Physics of disk seem off compared to previous working commit
			# TODO Seems a bit repetitive; Should be simplified in the factory refactor
			CONSTANTS.DISK_TYPE.FORCE:
				var force_disk: ForceDisk = ForceDisk.new_object()
				if item_owner != null:
					item_owner.add_child(force_disk)
				else:
					get_tree().get_root().add_child(force_disk)
				force_disk.prepare_item(item_type, item_owner, fallback_camera)
				force_disk.global_position = self.global_position
				force_disk.focus_on_launch = true
				force_disk.set_rigid_launch_parameters(launch_path, launch_speed, launch_angle)
			CONSTANTS.DISK_TYPE.PATH:
				var new_disk = PathDisk.new_object()
				if item_owner != null:
					item_owner.add_child(new_disk)
				else:
					get_tree().get_root().add_child(new_disk)
				new_disk.prepare_item(item_type, item_owner, fallback_camera)
				new_disk.set_launch_parameters(launch_path, launch_speed, self.global_basis.get_euler().x)
			_:
				pass
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
