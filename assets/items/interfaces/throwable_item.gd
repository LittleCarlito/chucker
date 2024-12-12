extends EquipableItem
class_name ThrowableItem

signal rotate_parent(rotationAmount)

# TODO Make the disks spin with passed in speed when launched
#			Should be able to make it spin counter/clockwise depending on sign

const _UNIMPLEMENTED_LOG: String = "UNIMPLEMENTED METHOD; All ThrowableItem Objects must implement \"%s\""
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
var just_launched: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func hold_action(_delta: float) -> void:
	Logger.error(_UNIMPLEMENTED_LOG, [_HOLD_ACTION], self)

func release_action() -> void:
	Logger.error(_UNIMPLEMENTED_LOG, [_RELEASE_ACTION], self)

func handle_aiming() -> void:
	# Right click aiming
	if Input.is_action_pressed(CONSTANTS.USER_INPUT.SECONDARY):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		if item_owner != null:
			item_owner.disableMovement = true
		if fallback_camera != null and fallback_camera.current:
			_zoom_in()
	if Input.is_action_just_released(CONSTANTS.USER_INPUT.SECONDARY):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		_reset_zoom()
		if item_owner != null:
			item_owner.cameraController.basis = item_owner.global_basis
			item_owner.disableMovement = false

func _input(event: InputEvent) -> void:
	# Look/Aim controls
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED and not just_launched:
		if item_owner != null and event is InputEventMouseMotion:
			# Inversion values are stored as booleans for UI purposes; Below is conversion to 1/-1
			var h_inversion: int = 1
			if GlobalSettings.CAMERA.get(CONSTANTS.INVERT_HORIZONTAL, GlobalSettings.CAMERA_DEFAULTS.INVERT_HORIZONTAL):
				h_inversion = -1
			var v_inversion: int = -1
			if GlobalSettings.CAMERA.get(CONSTANTS.INVERT_VERTICAL, GlobalSettings.CAMERA_DEFAULTS.INVERT_VERTICAL):
				v_inversion = 1
			var v_sense: float = GlobalSettings.CAMERA.get(CONSTANTS.VERTICAL_AIM_SENSITIVITY, GlobalSettings.CAMERA_DEFAULTS.VERTICAL_AIM_SENSITIVITY)
			item_owner.rotation.y -= h_inversion * (event.relative.x / 1000 * v_sense)
			var rotation_amount: float = v_inversion * (event.relative.y / 1000 * v_sense)
			rotate_parent.emit(rotation_amount)
	# Rotate input control
	if event.is_action_pressed(CONSTANTS.USER_INPUT.ROTATE_UP) || event.is_action_pressed(CONSTANTS.USER_INPUT.ROTATE_DOWN):
		var rotation_adjust: float = GlobalSettings.DISK.ROTATE_ADJUST
		if event.is_action_pressed(CONSTANTS.USER_INPUT.ROTATE_DOWN):
			rotation_adjust *= -1
		rotate_parent.emit(rotation_adjust)

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
	just_launched = true
	item_owner.disable_movement()
	item_owner.unequip_item()

func set_just_launched(value: bool) -> void:
	just_launched = value

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
