extends Resource
class_name LocalResource

func _setup_local_to_scene() -> void:
	self.resource_name = self.resource_name + "-" + str(self.get_instance_id())
