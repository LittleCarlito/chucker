extends EquipableItem
class_name ThrowableItem

var aimNode: Node3D = Node3D.new()
var aimControlNode: Node3D = Node3D.new()
var launchControlNode: Node3D = Node3D.new()
var justLaunched: bool = false

enum TYPE {CHARGE, PATH}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func hold_action(_delta: float) -> void:
	push_error("UNIMPLEMENTED METHOD; All ThrowableItem Objects must implement hold_action method")

func release_action() -> void:
	push_error("UNIMPLEMENTED METHOD; All ThrowableItem Objects must implement release_action method")

func handle_aiming() -> void:
	# Right click aiming
	if Input.is_action_pressed(CONSTANTS.USER_INPUT.SECONDARY):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		if ownerVar != null:
			ownerVar.disableMovement = true
		if fallbackCamera != null and fallbackCamera.current:
			self._zoom_in()
	if Input.is_action_just_released(CONSTANTS.USER_INPUT.SECONDARY):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		self._reset_zoom()
		if ownerVar != null:
			ownerVar.cameraController.basis = ownerVar.global_basis
			ownerVar.disableMovement = false

func _input(event: InputEvent) -> void:
	# Looking controls
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED and not justLaunched:
		if ownerVar != null and event is InputEventMouseMotion:
			# TODO Now that this h as inversion added it needs to be added to the disk as it flys
			var hInversionValue: int = 1
			if GLOBAL_SETTINGS.CONTROLS.get(CONSTANTS.INVERT_HORIZONTAL, GLOBAL_SETTINGS.CONTROLS_DEFAULTS.INVERT_HORIZONTAL):
				hInversionValue = -1
			var vInversionValue: int = -1
			if GLOBAL_SETTINGS.CONTROLS.get(CONSTANTS.INVERT_VERTICAL, GLOBAL_SETTINGS.CONTROLS_DEFAULTS.INVERT_VERTICAL):
				vInversionValue = 1
			ownerVar.rotation.y -= hInversionValue * (event.relative.x / 1000 * GLOBAL_SETTINGS.CONTROLS.get(CONSTANTS.HORIZONTAL_AIM_SENSITIVITY, GLOBAL_SETTINGS.CONTROLS_DEFAULTS.HORIZONTAL_AIM_SENSITIVITY))
			var rotationAmount = vInversionValue * (GLOBAL_SETTINGS.CONTROLS.get(CONSTANTS.VERTICAL_AIM_SENSITIVITY, GLOBAL_SETTINGS.CONTROLS.VERTICAL_AIM_SENSITIVITY) * (event.relative.y / 1000 * GLOBAL_SETTINGS.CONTROLS.get(CONSTANTS.VERTICAL_AIM_SENSITIVITY, GLOBAL_SETTINGS.CONTROLS_DEFAULTS.VERTICAL_AIM_SENSITIVITY)))
			if rotationAmount > 0 and self.get_parent().rotation_degrees.x < GLOBAL_SETTINGS.PLAYER.MAX_LAUNCH_ROTATION:
				# TODO Redo all self.get_parent() type calls with signaling something up instead
				self.get_parent().rotate_x(rotationAmount)
			elif rotationAmount < 0 and self.get_parent().rotation_degrees.x > GLOBAL_SETTINGS.PLAYER.MIN_LAUNCH_ROTATION:
				self.get_parent().rotate_x(rotationAmount)

func set_just_launched(value: bool) -> void:
	self.justLaunched = value

func draw_aim_line(multiplier: float, xOffset: float = 0) -> Array[Vector3]:
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
	launchControlNode.translate(Vector3(xOffset, 0, -zDistance / 3))
	DrawUtil.point(launchControlNode.position, .05, Color.BLUE)
	# Handle aimControlNode
	aimControlNode.position = self.global_position
	aimControlNode.basis = aimNode.basis
	# Apply negative translate to flatten the curve
	var controlPointHeight: float = (zDistance / 2.0) * tan(deg_to_rad(parentRotation)) * gravityAdjust
	aimControlNode.translate(Vector3(xOffset, controlPointHeight, -zDistance / 2))
	DrawUtil.point(aimControlNode.position, .05, Color.DEEP_PINK)
	# Draw the curve
	return DrawUtil.curve(self.global_position, launchControlNode.position, aimControlNode.position, aimNode.position)


func launch_disk(multiplier: float, diskType: TYPE, throwCurve: Array[Vector3] = []) -> void:
	var newDisk = ChuckDisk.new_disk(fallbackCamera, ownerVar)
	if throwCurve.is_empty():
		get_tree().get_root().add_child(newDisk)
		newDisk.top_level = true
		newDisk.global_transform = self.global_transform
		newDisk.linear_velocity = -newDisk.global_transform.basis.z * (GLOBAL_SETTINGS.DISK.LAUNCH_SPEED * multiplier)
		newDisk.diskType = ThrowableItem.TYPE.CHARGE
	else:
		var newPathDisk = PathDisk.new_disk()
		get_tree().get_root().add_child(newPathDisk)
		newPathDisk.prepare(throwCurve, multiplier, fallbackCamera, ownerVar)
		newPathDisk.top_level = true
		newDisk = newPathDisk.chuckDisk
		newDisk.diskType = ThrowableItem.TYPE.PATH
	self.rotation.x = 0
	var diskMaterial: StandardMaterial3D = newDisk.get_mesh().get_active_material(0)
	if diskType == TYPE.CHARGE:
		diskMaterial.albedo_color = GLOBAL_SETTINGS.COLOR.CHARGE
	elif diskType == TYPE.PATH:
		diskMaterial.albedo_color = GLOBAL_SETTINGS.COLOR.PATH
	newDisk.toggle_camera()
	ownerVar.disableMovement = true
	self.justLaunched = true
	ownerVar.unequip_item()
