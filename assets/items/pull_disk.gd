extends ThrowableItem
class_name PullDisk

@onready var pullDraw: PullDraw = $PullDraw
@onready var chargeControl: ChargeBar = $ChargeView/ChargeControl
@onready var chargeSprite: Sprite3D = $ChargeSprite
var aimNode: Node3D = Node3D.new()
var aimControlNode: Node3D = Node3D.new()
var launchControlNode: Node3D = Node3D.new()
var stopWatch: StopWatch = StopWatch.new()
var fallbackCamera: Camera3D
var ownerVar: ChuckChucker
var justLaunched: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Logger.set_log_level(Logger.LEVEL.DEBUG)
	chargeControl.set_progress(-1)
	ownerVar = self.owner
	if ownerVar != null:
		fallbackCamera = ownerVar.get_camera()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	self.handle_aiming()
	if Input.is_action_pressed(USER_INPUT.ACTION.PRIMARY):
		self.hold_action(delta)
	elif Input.is_action_just_released(USER_INPUT.ACTION.PRIMARY):
		self.release_action()
	# TODO This should probably be handled in one of the above methods
	if float(chargeControl.chargeAmount.text) >= 0:
		chargeSprite.visible = true
	else:
		chargeSprite.visible = false

func hold_action(delta: float) -> void:
	var pullLength: float = pullDraw.lastLength
	chargeControl.set_progress((pullLength / GLOBAL_SETTINGS.DISK.MAX_PULL) * 100)
	# TODO Get last pull length from pull draw to get how much charge should be applied
	# TODO Display in the chargeControl the ratio of last length to max pull length
	# TODO Display aim nodes based off charge amount
	# TODO Eventually get side pull of line and add offset to control nodes to add "curve"
	pass

func release_action() -> void:
	# TODO Get last pull length from pull draw to determine charge power
	# TODO Stuff to launch the disk into the main scene
	# TODO Eventually make this disk follow the path laid out by the aim nodes
	chargeControl.set_progress(-1)
	ownerVar.toggle_equiped(false)

# TODO Right click should aim and rotate disk (no showing any aim line)
# TODO Left click needs to be held down and pulled back give power to the shot
#		Start with power but eventually angle of pullback results in different curve to angle/spin on disk
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
		fallbackCamera.get_parent().basis = self.global_basis
		ownerVar.disableMovement = false

func _input(event: InputEvent) -> void:
	# Looking controls
	if not justLaunched:
		# Mouse is captured if right click is held
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			if event is InputEventMouseMotion:
				# Rotate character left and right
				ownerVar.rotation.y -= event.relative.x / 1000 * GLOBAL_SETTINGS.CONTROLS.HORIZONTAL_SENSITIVITY
				# Rotate disk up and down (within allowed limits)
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
	push_error("UNIMPLEMENTED METHOD; All ThrowableItem Objects must implement is_just_launched method")
