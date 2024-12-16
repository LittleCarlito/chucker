extends Node3D
class_name AimLine

var aim_node: Node3D = Node3D.new()
var aim_control_node: Node3D = Node3D.new()
var launch_control_node: Node3D = Node3D.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

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
