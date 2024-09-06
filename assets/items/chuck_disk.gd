extends RigidBody3D
class_name ChuckDisk

const thrownDisk: PackedScene = preload(ASSET_MANAGEMENT.DISK.SCENE)

@onready var diskCamera: Camera3D = $CameraControl/DiskCamera
@onready var cameraControl: Node3D = $CameraControl
@onready var cameraTimer: Timer = $CameraTimer
@onready var collisionTimer: Timer = $CollisionTimer

var fallbackCamera: Camera3D
var smoothedPosition: Vector3
var initialCameraOffset: Vector3
var initialCameraRotation: Vector3
var collisionPoint: Vector3
var collided: bool

func _ready() -> void:
	var parentObject: Object
	if self.get_parent() != null:
		parentObject = self.get_parent()
	if parentObject is ChuckTee:
		fallbackCamera = parentObject.get_camera()
	initialCameraOffset = cameraControl.global_transform.origin - self.global_transform.origin
	initialCameraRotation = cameraControl.rotation_degrees
	smoothedPosition = cameraControl.global_position
	var fallbackName: String
	if fallbackCamera != null:
		fallbackName = fallbackCamera.name

func _process(_delta: float) -> void:
	var target_position = self.global_transform.origin + initialCameraOffset
	# Check if the object is airborne
	# Object is in the air, directly follow without smoothing
	cameraControl.global_position = target_position
	# Maintain minimum height for the camera
	cameraControl.global_position.y = max(GLOBAL_SETTINGS.CAMERA.MIN_HEIGHT, cameraControl.global_position.y)
	# Rotate the x axis in the opposite direction
	cameraControl.rotation_degrees.x = initialCameraRotation.x - self.rotation_degrees.x
	# Hold y and z rotation constant
	cameraControl.rotation_degrees.y = initialCameraRotation.y
	cameraControl.rotation_degrees.z = initialCameraRotation.z
	# Freeze the camera control when rigid body detects collision
	# TODO Usure if collision timer does anything; When disk flips camera still flips
	if self.get_contact_count() > 0:
		if !collided:
			# Initial collision so start timers
			cameraTimer.start(GLOBAL_SETTINGS.CAMERA.SHOT_WATCH_TIME)
			collisionTimer.start(GLOBAL_SETTINGS.CAMERA.SHOT_WATCH_TIME)
			# Hold points where collision occured as a variable
			collisionPoint = cameraControl.global_position
			collided = true
		# Move camera control to where collision occured
		# TODO Is glitchy and weird on landing
		cameraControl.look_at_from_position(collisionPoint, self.global_position)

func toggle_camera() -> void:
	diskCamera.current = not diskCamera.current

func _on_camera_timer_timeout() -> void:
	diskCamera.current = false
	cameraControl.top_level = false
	if fallbackCamera != null:
		fallbackCamera.current = true

func _on_collision_timer_timeout() -> void:
	collided = false

static func new_disk(fallbackCamera: Camera3D) -> ChuckDisk:
	var newDisk: ChuckDisk = thrownDisk.instantiate()
	newDisk.fallbackCamera = fallbackCamera
	return newDisk
