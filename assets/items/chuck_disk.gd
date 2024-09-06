extends RigidBody3D
class_name ChuckDisk

const thrownDisk: PackedScene = preload(ASSET_MANAGEMENT.DISK.SCENE)

@onready var diskCamera: Camera3D = $CameraControl/DiskCamera
@onready var cameraControl: Node3D = $CameraControl
@onready var cameraTimer: Timer = $CameraTimer

var fallbackCamera: Camera3D
var initialCameraRotation: Vector3
var collisionPoint: Vector3
var collided: bool

func _ready() -> void:
	var parentObject: Object
	if self.get_parent() != null:
		parentObject = self.get_parent()
	if parentObject is ChuckTee:
		fallbackCamera = parentObject.get_camera()
	initialCameraRotation = cameraControl.rotation_degrees

func _process(_delta: float) -> void:
	# Maintain minimum height for the camera
	cameraControl.global_position.y = max(GLOBAL_SETTINGS.CAMERA.MIN_HEIGHT, cameraControl.global_position.y)
	# Have camera control track the disk
	cameraControl.look_at(self.global_position)
	# Freeze the camera control when rigid body detects collision
	if self.get_contact_count() > 0:
		if !collided:
			# Initial collision so start timers
			cameraTimer.start(GLOBAL_SETTINGS.CAMERA.SHOT_WATCH_TIME)
			# Hold points where collision occured as a variable
			collisionPoint = cameraControl.global_position
			collided = true
		# Move camera control to where collision occured
		cameraControl.look_at_from_position(collisionPoint, self.global_position)

func toggle_camera() -> void:
	diskCamera.current = not diskCamera.current

func _on_camera_timer_timeout() -> void:
	diskCamera.current = false
	cameraControl.top_level = false
	if fallbackCamera != null:
		fallbackCamera.current = true

static func new_disk(newdiskCamera: Camera3D) -> ChuckDisk:
	var newDisk: ChuckDisk = thrownDisk.instantiate()
	newDisk.fallbackCamera = newdiskCamera
	return newDisk
