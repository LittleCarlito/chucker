extends StaticBody3D
class_name ChuckTee

@onready var teeCamera: Camera3D = $CameraController/CameraTarget/TeeboxCamera

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_tee_box_area_body_entered(body: Node3D) -> void:
	if body is ChuckChucker:
		var bodyCamera: Camera3D = body.get_camera()
		bodyCamera.current = false
		teeCamera.current = true
		if(get_viewport().get_camera_3d() != null):
			var formatString: String = "Current camera is %s"
			Logger.debug(formatString, [get_viewport().get_camera_3d().name], self)

func _on_tee_box_area_body_exited(body: Node3D) -> void:
	if body is ChuckChucker:
		var bodyCamera: Camera3D = body.get_camera()
		bodyCamera.current = true
		teeCamera.current = false
		if(get_viewport().get_camera_3d() != null):
			var formatString: String = "Current camera is %s"
			Logger.debug(formatString, [get_viewport().get_camera_3d().name], self)

func get_camera() -> Camera3D:
	return $CameraController/CameraTarget/TeeboxCamera
