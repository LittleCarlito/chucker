# TODO As more item types are created make a base class and have these all extend it instead of MeshInstance3D
extends MeshInstance3D
# TODO Might have bugs because of incomplete refactor before claiming this name from ThrowableDiskMesh
class_name DiskMesh

const thrownDisk: PackedScene = preload(SceneLibrary.MESH.DISK_MESH)

signal lose_focus()

@onready var cameraTimer: Timer = $CameraContainer/CameraTimer
@onready var diskCamera: Camera3D = $CameraContainer/CameraControl/DiskCamera
@onready var cameraControl: Node3D = $CameraContainer/CameraControl
@onready var cameraContainer: Node3D = $CameraContainer

var focused: bool = false
var collisionLocation: Vector3 = Vector3.INF

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# Maintain minimum height for the camera
	cameraControl.global_position.y = max(GlobalSettings.CAMERA.MIN_HEIGHT, cameraControl.global_position.y)
	cameraControl.look_at(self.global_position)

func _input(event: InputEvent) -> void:
	# Looking controls
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED and diskCamera.current:
		if event is InputEventMouseMotion:
			# Doesn't have inversion multiplcation on it because it seems to have it through computation
			var horizontalRotateAmount: float = deg_to_rad(event.relative.x) * GlobalSettings.CAMERA.get(CONSTANTS.HORIZONTAL_LOOK_SENSITIVITY, GlobalSettings.CAMERA_DEFAULTS.HORIZONTAL_LOOK_SENSITIVITY)
			cameraContainer.global_rotation_degrees.y += horizontalRotateAmount
			cameraControl.look_at(self.global_position)

static func new_disk() -> DiskMesh:
	var newMesh: DiskMesh = thrownDisk.instantiate()
	return newMesh

func _set_type(newType: CONSTANTS.DISK_TYPE) -> void:
	var diskMaterial: StandardMaterial3D = self.get_active_material(0)
	match newType:
		CONSTANTS.DISK_TYPE.FORCE:
			diskMaterial.albedo_color = GlobalSettings.COLOR.FORCE
		CONSTANTS.DISK_TYPE.PATH:
			diskMaterial.albedo_color = GlobalSettings.COLOR.PATH
		_:
			# TODO Log that type wasn't supported; Load a weird color
			diskMaterial.albedo_color = GlobalSettings.COLOR.FORCE

func start_focus() -> void:
	cameraTimer.start(GlobalSettings.CAMERA.SHOT_WATCH_TIME)
	focused = true

func _on_camera_timer_timeout() -> void:
	diskCamera.current = false
	cameraContainer.top_level = false
	collisionLocation = Vector3.INF
	lose_focus.emit()
	focused = false

func idle_rotate(delta: float) -> void:
	cameraContainer.top_level = true
	# Calculate the rotation angle in radians
	var rotationAmount: float = (GlobalSettings.CAMERA.IDLE_ROTATE_SPEED * delta)
	# Get the current global position of the Root object
	if collisionLocation == Vector3.INF:
		collisionLocation = self.global_position
	cameraContainer.global_rotation_degrees.y += rotationAmount
	cameraControl.look_at(collisionLocation)
