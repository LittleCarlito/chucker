extends MeshInstance3D
class_name DiskMesh

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func set_type(new_type: AssetData.TYPE) -> void:
	var disk_material: StandardMaterial3D = self.get_active_material(0)
	disk_material.albedo_color = AssetData.get_item_color(new_type)
