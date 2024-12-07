extends EquipableItem
class_name ThrowableItem

signal rotate_parent(rotationAmount)

# TODO Make the disks spin with passed in speed when launched
#			Should be able to make it spin counter/clockwise depending on sign

const _UNIMPLEMENTED_LOG: String = "UNIMPLEMENTED METHOD; All ThrowableItem Objects must implement \"%s\""
const _HOLD_ACTION: String = "hold_action"
const _RELEASE_ACTION: String = "release_action"

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
	Logger.error(self._UNIMPLEMENTED_LOG, [self._HOLD_ACTION], self)

func release_action() -> void:
	Logger.error(self._UNIMPLEMENTED_LOG, [self._RELEASE_ACTION], self)

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
	# Look/Aim controls
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED and not justLaunched:
		if ownerVar != null and event is InputEventMouseMotion:
			# Inversion values are stored as booleans for UI purposes; Below is conversion to 1/-1
			var hInversionValue: int = 1
			if GlobalSettings.CAMERA.get(CONSTANTS.INVERT_HORIZONTAL, GlobalSettings.CAMERA_DEFAULTS.INVERT_HORIZONTAL):
				hInversionValue = -1
			var vInversionValue: int = -1
			if GlobalSettings.CAMERA.get(CONSTANTS.INVERT_VERTICAL, GlobalSettings.CAMERA_DEFAULTS.INVERT_VERTICAL):
				vInversionValue = 1
			var vSenseValue: float = GlobalSettings.CAMERA.get(CONSTANTS.VERTICAL_AIM_SENSITIVITY, GlobalSettings.CAMERA_DEFAULTS.VERTICAL_AIM_SENSITIVITY)
			ownerVar.rotation.y -= hInversionValue * (event.relative.x / 1000 * vSenseValue)
			var rotationAmount: float = vInversionValue * (event.relative.y / 1000 * vSenseValue)
			rotate_parent.emit(rotationAmount)
	# Rotate input control
	if event.is_action_pressed(CONSTANTS.USER_INPUT.ROTATE_UP) || event.is_action_pressed(CONSTANTS.USER_INPUT.ROTATE_DOWN):
		var rotationAdjust: float = GlobalSettings.DISK.ROTATE_ADJUST
		if event.is_action_pressed(CONSTANTS.USER_INPUT.ROTATE_DOWN):
			rotationAdjust *= -1
		rotate_parent.emit(rotationAdjust)

func set_just_launched(value: bool) -> void:
	self.justLaunched = value

func draw_aim_line(multiplier: float, xOffset: float = 0) -> Array[Vector3]:
	var gravity: float = abs(NodeUtil.get_gravity(self).y)
	var parentRotation: float = NodeUtil.get_parent_x_rotation(self)
	var height: float = self.global_position.y
	#var height: float = NodeUtil.get_parent_heights(self)
	var throwSpeed: float = GlobalSettings.DISK.LAUNCH_SPEED * multiplier
	# move_and_slide() is a liar so this will always be an approximation
	var zDistance: float = NodeUtil.calculate_range(height, gravity, parentRotation, throwSpeed)
	var gravityAdjust: float = gravity * GlobalSettings.DISK.GRAVITY_MULTIPLIER
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
		newDisk.linear_velocity = -newDisk.global_transform.basis.z * (GlobalSettings.DISK.LAUNCH_SPEED * multiplier)
		newDisk.diskType = ThrowableItem.TYPE.CHARGE
	else:
		var newPathDisk = PathDisk.new_disk()
		get_tree().get_root().add_child(newPathDisk)
		newPathDisk.prepare(throwCurve, multiplier, fallbackCamera, ownerVar)
		newPathDisk.top_level = true
		newDisk = newPathDisk.chuckDisk
		newDisk.diskType = ThrowableItem.TYPE.PATH
		# TODO Seems like messing with rotation of Rigid3D bodies is a nono
		#			Need to refactor path disk to be a mesh with area box for pre collision
		#			Pre collision detection then spawns in a RigidBody3D with same global basis as mesh and adds launching force
		newDisk.holdAngle = true
		newDisk.rotate_x(self.global_basis.get_euler().x)
	newDisk.launchAngle = self.global_basis
	self.rotation.x = 0
	var diskMaterial: StandardMaterial3D = newDisk.get_mesh().get_active_material(0)
	if diskType == TYPE.CHARGE:
		diskMaterial.albedo_color = GlobalSettings.COLOR.CHARGE
	elif diskType == TYPE.PATH:
		diskMaterial.albedo_color = GlobalSettings.COLOR.PATH
	newDisk.toggle_camera()
	ownerVar.disableMovement = true
	self.justLaunched = true
	ownerVar.unequip_item()
