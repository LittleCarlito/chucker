extends RigidBody3D
class_name ChuckDisk

@onready var diskCamera: Camera3D = $CameraControl/DiskCamera
@onready var cameraControl: Node3D = $CameraControl
@onready var cameraTimer: Timer = $CameraTimer
@onready var collisionTimer: Timer = $CollisionTimer

var smoothedPosition: Vector3

var initialCameraOffset: Vector3
var initialCameraRotation: Vector3
var collisionPoint: Vector3
var collisionBasis: Basis
var collided: bool

func _ready() -> void:
	initialCameraOffset = cameraControl.global_transform.origin - self.global_transform.origin
	initialCameraRotation = cameraControl.rotation_degrees
	smoothedPosition = cameraControl.global_position

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
	# TODO Need to add contact timer so tumbling, bouncing, flipping on gound doesn't make camera start following
	if self.get_contact_count() > 0:
		collisionTimer.start(GLOBAL_SETTINGS.CAMERA.SHOT_WATCH_TIME)
		if !collided:
			cameraTimer.start(GLOBAL_SETTINGS.CAMERA.SHOT_WATCH_TIME)
			collisionPoint = cameraControl.global_position
			collisionBasis = cameraControl.global_basis
			collided = true
		cameraControl.global_position = collisionPoint
		cameraControl.global_basis = collisionBasis

func toggle_camera() -> void:
	diskCamera.current = not diskCamera.current

func _on_camera_timer_timeout() -> void:
	diskCamera.current = false
	# TODO Get the holding nodes camera and set it to a variable at some stable time (something that won't be done over and over) then make it active here
	#			Add Method to ChuckChucker for getting its camera; Makes it easier, then you just have to do get parent till you hit ChuckChucker/PlayableCharacter or whatever


func _on_collision_timer_timeout() -> void:
	print("in timeout")
	collided = false
