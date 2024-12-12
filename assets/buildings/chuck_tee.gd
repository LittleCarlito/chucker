extends StaticBody3D
class_name ChuckTee

@onready var tee_camera: Camera3D = $CameraController/CameraTarget/TeeboxCamera

const _CURRENT_CAMERA_LOG: String = "Current camera is %s"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_tee_box_area_body_entered(body: Node3D) -> void:
	_handle_body(body, false)

func _on_tee_box_area_body_exited(body: Node3D) -> void:
	_handle_body(body, true)

func _handle_body(body: Node3D, body_cam_current: bool) -> void:
	if body is ChuckChucker:
		var body_camera: Camera3D = body.get_camera()
		body_camera.current = body_cam_current
		tee_camera.current = !body_cam_current
		if(get_viewport().get_camera_3d() != null):
			Logger.debug(_CURRENT_CAMERA_LOG, [get_viewport().get_camera_3d().name], self)

func get_camera() -> Camera3D:
	return tee_camera
