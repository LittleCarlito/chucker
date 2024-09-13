extends ThrowableItem
class_name PullDisk

@onready var chargeControl: ChargeBar = $ChargeView/ChargeControl
@onready var chargeSprite: Sprite3D = $ChargeSprite
var originPullPoint: Vector2
var pullPoint: Vector2
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
	chargeControl.chargeAmount.text = str(-1)
	ownerVar = self.owner
	## IF YOU FAILED LAUNCHING ON THIS LINE ITS BECAUSE YOU LAUNCHED THE DISK AS A SCENE
	fallbackCamera = ownerVar.get_camera()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	self.handle_aiming()
	if float(chargeControl.chargeAmount.text) >= 0:
		chargeSprite.visible = true
	else:
		chargeSprite.visible = false

func hold_action(_delta: float) -> void:
	push_error("UNIMPLEMENTED METHOD; All ThrowableItem Objects must implement hold_action method")
	# TODO Detect mouse input and if it is positive move zDirection along the -z axis at a constant global velocity
	#			do the opposite for movements detected in the negative direction

func release_action() -> void:
	push_error("UNIMPLEMENTED METHOD; All ThrowableItem Objects must implement release_action method")

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
		# When right click isn't held
		else:
			if event is InputEventMouse:
				# Get location where left click is starting to be held
				if Input.is_action_just_pressed(USER_INPUT.ACTION.PRIMARY):
					originPullPoint = event.global_position
					chargeControl.chargeAmount.text = str(0)
				# Determine throw power based off distance between origin of pull and mouse location
				elif Input.is_action_pressed(USER_INPUT.ACTION.PRIMARY):
					get_viewport().get_mouse_position()
					pullPoint = event.global_position
					#pullDraw.draw_pull_line(Vector2.ZERO, pullPoint, Color.RED)
					# TODO Might just be easier to draw on the viewport with a sprite and canvas thing somehow?
					# TODO Convert Vector2 to Vector3 so you can use DrawUtil
					#		Have x and y, z should be 0 as it doesn't need depth
					#		These measurements have to be local and then converted to global
					# TODO Make 2 more points for drawing on the screen
					# NOTE Y going positive means down; Negative means up
					# NOTE X going positive means right; Negative means left
					# NOTE Measured in pixels; Convert pixels to meters (standard is .01 px/meter)
					#print("Origin pull point is " + str(originPullPoint.position) + "; Pull point now is " + str(pullPoint.position))
					
					# TODO Code up update the charge bar to be a ratio of movedDistance to configured max allowed charge
					# TODO Implement
					pass
				# Determine where left click is released to calculate launch power
				elif Input.is_action_just_released(USER_INPUT.ACTION.PRIMARY):
					# TODO Code for launching disk into the main scene
					originPullPoint = Vector2.INF
					pullPoint = Vector2.INF
					chargeControl.chargeAmount.text = str(-1)
					ownerVar.toggle_equiped(false)

func _reset_zoom() -> void:
	fallbackCamera.fov = GLOBAL_SETTINGS.CAMERA.FOV

func _zoom_in() -> void:
	fallbackCamera.fov = GLOBAL_SETTINGS.CAMERA.FOV - GLOBAL_SETTINGS.CAMERA.IN_ADJUST

func _zoom_out() -> void:
	fallbackCamera.fov = GLOBAL_SETTINGS.CAMERA.FOV + GLOBAL_SETTINGS.CAMERA.OUT_ADJUST

func set_just_launched(value: bool) -> void:
	push_error("UNIMPLEMENTED METHOD; All ThrowableItem Objects must implement is_just_launched method")
