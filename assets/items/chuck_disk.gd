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
var collisionBasis: Basis
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
		print("Fallback camera for disk is " + fallbackName)

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
	if self.get_contact_count() > 0:
		# Continuously start a collision timer while in contact with objects'
		# When times out resets collided bool
		collisionTimer.start(GLOBAL_SETTINGS.CAMERA.SHOT_WATCH_TIME)
		if !collided:
			# If it hasn't collided in a while, assume a shot and start camera countdown
			cameraTimer.start(GLOBAL_SETTINGS.CAMERA.SHOT_WATCH_TIME)
			# Hold points where collision occured as a variable
			collisionPoint = cameraControl.global_position
			collided = true
		# Move camera control to where collision occured
		cameraControl.global_position = collisionPoint

func toggle_camera() -> void:
	diskCamera.current = not diskCamera.current

func _on_camera_timer_timeout() -> void:
	diskCamera.current = false
	fallbackCamera.current = true

func _on_collision_timer_timeout() -> void:
	print("in timeout")
	collided = false

static func new_disk(fallbackCamera: Camera3D) -> ChuckDisk:
	var newDisk: ChuckDisk = thrownDisk.instantiate()
	newDisk.fallbackCamera = fallbackCamera
	return newDisk
