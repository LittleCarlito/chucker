extends RigidBody3D
class_name ChuckDisk

@onready var diskCamera: Camera3D = $CameraControl/DiskCamera
@onready var cameraControl: Node3D = $CameraControl

var smoothed_position: Vector3
var smoothing_factor: float = 0.3# Adjust this factor to change smoothing intensity

var initial_camera_offset: Vector3
var initial_camera_rotation: Vector3

func _ready() -> void:
	initial_camera_offset = cameraControl.global_transform.origin - self.global_transform.origin
	initial_camera_rotation = cameraControl.rotation_degrees
	smoothed_position = cameraControl.global_position

func _process(_delta: float) -> void:
	var target_position = self.global_transform.origin + initial_camera_offset
	# Check if the object is airborne
	if int(self.linear_velocity.z) != 0:
		# Object is in the air, directly follow without smoothing
		cameraControl.global_position = target_position
	else:
		# Object is on the ground, apply smoothing
		smoothed_position = smoothed_position.lerp(target_position, smoothing_factor)
		cameraControl.global_position = smoothed_position
	# Maintain minimum height for the camera
	cameraControl.global_position.y = max(GLOBAL_SETTINGS.CAMERA.MIN_HEIGHT, cameraControl.global_position.y)
	# Keep the camera control node's rotation unaffected by the x-axis rotation of the rigid body
	cameraControl.rotation_degrees.x = initial_camera_rotation.x
	cameraControl.rotation_degrees.y = self.rotation_degrees.y + initial_camera_rotation.y
	cameraControl.rotation_degrees.z = self.rotation_degrees.z + initial_camera_rotation.z
	# Handle camera toggle and mass change
	if int(self.linear_velocity.z) == 0:
		diskCamera.current = false

func toggle_camera() -> void:
	diskCamera.current = not diskCamera.current
