extends EquipableItem
class_name ThrowableItem

var aimNode: Node3D = Node3D.new()
var aimControlNode: Node3D = Node3D.new()
var launchControlNode: Node3D = Node3D.new()
var justLaunched: bool = false

enum TYPE {CHARGE, PULL}

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
	if Input.is_action_pressed(USER_INPUT.ACTION.SECONDARY):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		ownerVar.disableMovement = true
		if fallbackCamera.current:
			self._zoom_in()
	if Input.is_action_just_released(USER_INPUT.ACTION.SECONDARY):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		self._reset_zoom()
		ownerVar.cameraController.basis = ownerVar.global_basis
		ownerVar.disableMovement = false

func _input(event: InputEvent) -> void:
	# Looking controls
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED and not justLaunched:
		if event is InputEventMouseMotion:
			ownerVar.rotation.y -= event.relative.x / 1000 * GLOBAL_SETTINGS.CONTROLS.HORIZONTAL_SENSITIVITY
			var rotationAmount = GLOBAL_SETTINGS.CONTROLS.INVERT_VERTICAL * (GLOBAL_SETTINGS.CONTROLS.VERTICAL_SENSITIVITY * (event.relative.y / 1000 * GLOBAL_SETTINGS.CONTROLS.VERTICAL_SENSITIVITY))
			if rotationAmount > 0 and self.get_parent().rotation_degrees.x < GLOBAL_SETTINGS.PLAYER.MAX_LAUNCH_ROTATION:
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
	# TODO Offset on x axis by given parameter
	launchControlNode.translate(Vector3(xOffset, 0, -zDistance / 3))
	DrawUtil.point(launchControlNode.position, .05, Color.BLUE)
	# Handle aimControlNode
	aimControlNode.position = self.global_position
	aimControlNode.basis = aimNode.basis
	# Apply negative translate to flatten the curve
	var controlPointHeight: float = (zDistance / 2.0) * tan(deg_to_rad(parentRotation)) * gravityAdjust
	# TODO Offset on x axis by given parameter
	aimControlNode.translate(Vector3(xOffset, controlPointHeight, -zDistance / 2))
	DrawUtil.point(aimControlNode.position, .05, Color.DEEP_PINK)
	# Draw the curve
	return DrawUtil.curve(self.global_position, launchControlNode.position, aimControlNode.position, aimNode.position)

# TODO Enable forcing disk on curve
#		Add Array[Vector3] as optional parameter
#		Create Path3D and PathFollow3D from curve
#		Make PathFollow3D child of Path3D
#		Make newDisk child of PathFollow3D
#		Freeze newDisk and put newDisk to sleep
#		MakePathFollow3D move along the path at the same speed the disk would've flown
#		From tests, disk shouldn't have to be reparented, once its awake it'll just disregard the path
func launch_disk(multiplier: float, diskType: TYPE, throwCurve: Array[Vector3] = []) -> void:
	if throwCurve.is_empty():
		var newDisk = ChuckDisk.new_disk(fallbackCamera, ownerVar)
		get_tree().get_root().add_child(newDisk)
		var diskMaterial: StandardMaterial3D = newDisk.get_mesh().get_active_material(0)
		if diskType == TYPE.CHARGE:
			diskMaterial.albedo_color = Color.RED
		elif diskType == TYPE.PULL:
			diskMaterial.albedo_color = Color.BLUE
		newDisk.top_level = true
		newDisk.global_transform = self.global_transform
		newDisk.linear_velocity = -newDisk.global_transform.basis.z * (GLOBAL_SETTINGS.DISK.LAUNCH_SPEED * multiplier)
		self.rotation.x = 0
		newDisk.toggle_camera()
		ownerVar.disableMovement = true
		self.justLaunched = true
		ownerVar.toggle_equiped(false)
	else:
		# TODO Determine what above and below is repeated and combine them below if else
		#		I think an interface needs to be created for CollisionDisks to allow the code to be combined
		# TODO Make it so the Path disk doesn't keep repeating and collides/tumbles properly
		var newPathDisk = PathDisk.new_disk()
		get_tree().get_root().add_child(newPathDisk)
		newPathDisk.prepare(throwCurve, multiplier, fallbackCamera, ownerVar)
		newPathDisk.top_level = true
		var diskMaterial: StandardMaterial3D = newPathDisk.chuckDisk.get_mesh().get_active_material(0)
		if diskType == TYPE.CHARGE:
			diskMaterial.albedo_color = Color.RED
		elif diskType == TYPE.PULL:
			diskMaterial.albedo_color = Color.BLUE
		newPathDisk.engage()
		self.rotation.x = 0
		newPathDisk.toggle_camera()
		ownerVar.disableMovement = true
		self.justLaunched = true
		ownerVar.toggle_equiped(false)
