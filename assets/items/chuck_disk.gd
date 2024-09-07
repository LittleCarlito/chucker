extends RigidBody3D
class_name ChuckDisk

const thrownDisk: PackedScene = preload(ASSET_MANAGEMENT.DISK.SCENE)

@onready var cameraContainer: Node3D = $CameraContainer
@onready var cameraControl: Node3D = $CameraContainer/CameraControl
@onready var diskCamera: Camera3D = $CameraContainer/CameraControl/DiskCamera
@onready var cameraTimer: Timer = $CameraContainer/CameraTimer

var thrower: ChuckChucker
var fallbackCamera: Camera3D
var rootPosition: Vector3 = Vector3.INF
var collided: bool

func _ready() -> void:
	cameraControl.look_at(self.global_position)
	var parentObject: Object
	if self.get_parent() != null:
		parentObject = self.get_parent()
	if parentObject is ChuckTee:
		fallbackCamera = null

func _process(delta: float) -> void:
	# Maintain minimum height for the camera
	cameraControl.global_position.y = max(GLOBAL_SETTINGS.CAMERA.MIN_HEIGHT, cameraControl.global_position.y)
	# Freeze the camera control when rigid body detects collision
	if self.get_contact_count() > 0 and diskCamera.current:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		if !collided:
			# Initial collision so start timers
			cameraTimer.start(GLOBAL_SETTINGS.CAMERA.SHOT_WATCH_TIME)
			# Hold points where collision occured as a variable
			collided = true
		# Move camera control to where collision occured
		self._idle_rotate(delta)
	# Otherwise handle camera controls if camera is active
	else:
		if diskCamera.current:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent) -> void:
	# Looking controls
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED and diskCamera.current:
		if event is InputEventMouseMotion:
			# TODO Add inversion stuff
			var horizontalRotateAmount: float = GLOBAL_SETTINGS.CONTROLS.INVERSION * (deg_to_rad(event.relative.x) * GLOBAL_SETTINGS.CONTROLS.HORIZONTAL_SENSITIVITY)
			cameraContainer.global_rotation_degrees.y += horizontalRotateAmount
			cameraControl.look_at(self.global_position)

func toggle_camera() -> void:
	diskCamera.current = not diskCamera.current

func _on_camera_timer_timeout() -> void:
	diskCamera.current = false
	if thrower != null:
		thrower.disableMovement = false
	if fallbackCamera != null:
		fallbackCamera.current = true
	rootPosition = Vector3.INF
	cameraContainer.top_level = false

static func new_disk(newdiskCamera: Camera3D, newThrower: ChuckChucker) -> ChuckDisk:
	var newDisk: ChuckDisk = thrownDisk.instantiate()
	newDisk.fallbackCamera = newdiskCamera
	newDisk.thrower = newThrower
	return newDisk

# TODO Rework now that CameraContainer exists to rotate with
func _idle_rotate(delta: float) -> void:
	cameraContainer.top_level = true
	# Calculate the rotation angle in radians
	var rotationAmount: float = deg_to_rad(GLOBAL_SETTINGS.CAMERA.IDLE_ROTATE_SPEED * delta)
	# Get the current global position of the Root object
	if rootPosition == Vector3.INF:
		rootPosition = self.global_position
	# Get current position of CameraControl
	var currentPosition: Vector3 = cameraControl.global_position
	# Compute the vector from Root to CameraControl
	var offset: Vector3 = currentPosition - rootPosition
	# Rotate the offset around the Y-axis
	offset = offset.rotated(Vector3.DOWN, rotationAmount)
	# Update the position of CameraControl relative to the moving Root
	cameraControl.global_position = rootPosition + offset
	# Make the CameraControl node face towards the Root
	cameraControl.rotation_degrees.x = 0
	cameraControl.look_at(rootPosition)
