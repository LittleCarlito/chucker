extends MeshInstance3D
class_name DiskMesh

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

# TODO Below should be moved to the holder or a resource in the holder
#func _input(event: InputEvent) -> void:
	## Looking controls
	#if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED and camera_container.is_current():
		#if event is InputEventMouseMotion:
			## Determine amount to rotate camera
			#var horizontal_rotate_amount: float = deg_to_rad(event.relative.x) * GlobalSettings.CAMERA.get(CONSTANTS.HORIZONTAL_LOOK_SENSITIVITY, GlobalSettings.CAMERA_DEFAULTS.HORIZONTAL_LOOK_SENSITIVITY)
			#camera_container.horizontal_rotate(horizontal_rotate_amount, self.global_position)

# TODO Move this to holders of the CameraContainer Resource
# TODO Make it CollisionData and make the holder @export an Array[CollisionData]
#func _on_lose_focus() -> void:
	#item_owner.enable_movement()
	#fallback_camera.current = true
	#collision_location = Vector3.INF

func set_type(new_type: AssetData.TYPE) -> void:
	var disk_material: StandardMaterial3D = self.get_active_material(0)
	disk_material.albedo_color = AssetData.get_item_color(new_type)
