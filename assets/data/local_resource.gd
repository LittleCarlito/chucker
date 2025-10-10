extends Resource
class_name LocalResource

func _setup_local_to_scene() -> void:
	resource_name = resource_name + "-" + str(get_instance_id())
