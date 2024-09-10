extends ThrowableItem
class_name ChargeDisk

@onready var chargeControl: ChargeBar = $ChargeView/ChargeControl
@onready var chargeSprite: Sprite3D = $ChargeSprite
@onready var aimNode: Node3D = Node3D.new()
@onready var aimControlNode: Node3D = Node3D.new()
@onready var launchControlNode: Node3D = Node3D.new()
var stopWatch: StopWatch = StopWatch.new()
var fallbackCamera: Camera3D
var ownerVar: ChuckChucker
var justLaunched: bool = false

# TODO Get rid of scroll making disk tilt and make that how power is set instead
# TODO Make dynamic scorecard
#		Make each part of the scorecard a node object
#		Make a script to create the scorecard based off how many holes the scene contains
#		Also adds the number of players dynamically
#		Creates scroll bars to allow for more than 18 holes and more than 4 players
# TODO Add charge effects
#		Wobble if held too long
#		Will just inaccurately launch after x amount of time
# TODO Add "perfect" release window
# TODO Give "perfect" release different effects
# TODO Ability to put spin on disk and curve it
# TODO Make a disk that makes flight path based off physics (there is some method that can be called to get expected path)
#		This will take the flight time to simulate
#		Have a dot show where it is in calculating and a line follow behind it
#			Use draws ability to hold the line for a few seconds before disappearing
# TODO Make a disk that forces the flight of the released disk along the calculated path
#		Can be done with PathFolow node apparently

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Logger.set_log_level(Logger.LEVEL.DEBUG)
	ownerVar = self.owner
	fallbackCamera = ownerVar.get_camera()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	self.handle_aiming()
	if float(chargeControl.chargeAmount.text) > 0:
		chargeSprite.visible = true
	else:
		chargeSprite.visible = false

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

func hold_action(delta: float) -> void:
	var heldTime: float = stopWatch.isHeld(delta)
	chargeControl.set_progress((heldTime / GLOBAL_SETTINGS.DISK.MAX_HOLD) * 100)
	var multiplier: float = min(GLOBAL_SETTINGS.DISK.MAX_HOLD, heldTime) * GLOBAL_SETTINGS.DISK.HOLD_MULTIPLIER
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

## Launch disk and reset objects
func release_action() -> void:
	var finalTime: float = stopWatch.reset()
	var multiplier: float = min(GLOBAL_SETTINGS.DISK.MAX_HOLD, finalTime) * GLOBAL_SETTINGS.DISK.HOLD_MULTIPLIER
	var newDisk = ChuckDisk.new_disk(fallbackCamera, ownerVar)
	newDisk.top_level = true
	get_tree().get_root().add_child(newDisk)
	newDisk.global_transform = self.global_transform
	newDisk.linear_velocity = -newDisk.global_transform.basis.z * (GLOBAL_SETTINGS.DISK.LAUNCH_SPEED * multiplier)
	self.rotation.x = 0
	chargeControl.set_progress(0)
	if newDisk is ChuckDisk:
		newDisk.toggle_camera()
		ownerVar.disableMovement = true
		self.justLaunched = true

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

func _reset_zoom() -> void:
	fallbackCamera.fov = GLOBAL_SETTINGS.CAMERA.FOV

func _zoom_in() -> void:
	fallbackCamera.fov = GLOBAL_SETTINGS.CAMERA.FOV - GLOBAL_SETTINGS.CAMERA.IN_ADJUST

func _zoom_out() -> void:
	fallbackCamera.fov = GLOBAL_SETTINGS.CAMERA.FOV + GLOBAL_SETTINGS.CAMERA.OUT_ADJUST

func set_just_launched(value: bool) -> void:
	self.justLaunched = value
