extends StaticBody3D

const consideredBodies = ["ChuckChucker"]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_tee_box_area_body_entered(body: Node3D) -> void:
	# TODO Add refinement so only player entering causes this
	if body != null and body.name in consideredBodies:
		$CameraController/CameraTarget/TeeboxCamera.current = true
		if(get_viewport().get_camera_3d() != null):
			print("Current camera is " + get_viewport().get_camera_3d().name)



func _on_tee_box_area_body_exited(body: Node3D) -> void:
	# TODO Add refinement so only player exiting causes this
	if body != null and body.name in consideredBodies:
		$CameraController/CameraTarget/TeeboxCamera.current = false
		if(get_viewport().get_camera_3d() != null):
			print("Current camera is " + get_viewport().get_camera_3d().name)
