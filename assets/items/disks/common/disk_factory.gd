extends Node

const _CREATE_AND_LAUNCH: String = "create_and_launch"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
# TODO In ECS formatting this will (hopefully) become a resource that is added as a disk_launcher or something to objects that need the ability to spawn
# TODO Maybe make ThrowableData the combination of ItemData and LaunchData as internal Resources that can then be passed in here
func create_and_launch(incoming_item: ThrowableItem) -> void:
	var item_type: ItemData.TYPE = incoming_item.get_type()
	var item_owner: ChuckChucker = incoming_item.get_item_owner()
	var fallback_camera: Camera3D = incoming_item.get_fallback_camera()
	var launch_path: Array[Vector3] = incoming_item.get_launch_path()
	var launch_speed: float = incoming_item.get_launch_speed()
	var launch_angle: float = incoming_item.get_launch_angle()
	match item_type:
		ItemData.TYPE.FORCE:
			var force_disk: ForceDisk = ForceDisk.new_object()
			if item_owner != null:
				item_owner.add_child(force_disk)
				force_disk.connect("lose_focus", item_owner.regain_focus)
				force_disk.top_level = true
			else:
				get_tree().get_root().add_child(force_disk)
			force_disk.prepare_item(item_type)
			force_disk.global_position = incoming_item.global_position
			force_disk.set_launch_parameters(launch_path, launch_speed, launch_angle, true)
			force_disk.launch_disk()
		ItemData.TYPE.PATH:
			var path_disk: PathDisk = PathDisk.new_object()
			if item_owner != null:
				item_owner.add_child(path_disk)
				path_disk.top_level = true
			else:
				get_tree().get_root().add_child(path_disk)
			path_disk.prepare_item(item_type, item_owner, fallback_camera)
			path_disk.global_position = incoming_item.global_position
			path_disk.set_launch_parameters(launch_path, launch_speed, launch_angle, true)
		_:
			var formattedString: String = CONSTANTS.UNSUPPORTED_TYPE_LOG + CONSTANTS.LOG_SEPARATOR + CONSTANTS.RETURNING_NULL_LOG
			Logger.warn(formattedString, [_CREATE_AND_LAUNCH, str(item_type)], self)
