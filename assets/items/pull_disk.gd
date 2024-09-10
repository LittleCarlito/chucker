extends ThrowableItem
class_name PullDisk

@onready var chargeControl: ChargeBar = $ChargeView/ChargeControl
@onready var chargeSprite: Sprite3D = $ChargeSprite
@onready var aimNode: Node3D = Node3D.new()
@onready var aimControlNode: Node3D = Node3D.new()
@onready var launchControlNode: Node3D = Node3D.new()
var stopWatch: StopWatch = StopWatch.new()
var fallbackCamera: Camera3D
var ownerVar: ChuckChucker

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Logger.set_log_level(Logger.LEVEL.DEBUG)
	ownerVar = self.owner
	fallbackCamera = ownerVar.get_camera()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	self.handle_aiming()
	pass

func hold_action(_delta: float) -> void:
	push_error("UNIMPLEMENTED METHOD; All ThrowableItem Objects must implement hold_action method")
	# TODO Detect mouse input and if it is positive move zDirection along the -z axis at a constant global velocity
	#			do the opposite for movements detected in the negative direction

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
		fallbackCamera.get_parent().basis = self.global_basis
		ownerVar.disableMovement = false

func _reset_zoom() -> void:
	fallbackCamera.fov = GLOBAL_SETTINGS.CAMERA.FOV

func _zoom_in() -> void:
	fallbackCamera.fov = GLOBAL_SETTINGS.CAMERA.FOV - GLOBAL_SETTINGS.CAMERA.IN_ADJUST

func _zoom_out() -> void:
	fallbackCamera.fov = GLOBAL_SETTINGS.CAMERA.FOV + GLOBAL_SETTINGS.CAMERA.OUT_ADJUST

func set_just_launched(value: bool) -> void:
	push_error("UNIMPLEMENTED METHOD; All ThrowableItem Objects must implement is_just_launched method")
