extends Node

const _CREATE_AND_LAUNCH: String = "create_and_launch"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
# TODO A method to take in an EquipableItem, dispose of it, and return a fresh one to the caller
func create_and_launch(incoming_item: ThrowableItem) -> ThrowableItem:
	var item_type: CONSTANTS.DISK_TYPE = incoming_item.get_type()
	var item_owner: ChuckChucker = incoming_item.get_item_owner()
	var fallback_camera: Camera3D = incoming_item.get_fallback_camera()
	var launch_path: Array[Vector3] = incoming_item.get_launch_path()
	var launch_speed: float = incoming_item.get_launch_speed()
	var launch_angle: float = incoming_item.get_launch_angle()
	var new_disk: ThrowableItem
	match item_type:
		CONSTANTS.DISK_TYPE.FORCE:
			new_disk = ForceDisk.new_object()
		CONSTANTS.DISK_TYPE.PATH:
			new_disk = PathDisk.new_object()
		_:
			var formattedString: String = CONSTANTS.UNSUPPORTED_TYPE_LOG + CONSTANTS.LOG_SEPARATOR + CONSTANTS.RETURNING_NULL_LOG
			Logger.warn(formattedString, [_CREATE_AND_LAUNCH, str(item_type)], self)
	if new_disk != null:
		if item_owner != null:
			item_owner.add_child(new_disk)
		else:
			get_tree().get_root().add_child(new_disk)
		new_disk.prepare_item(item_type, item_owner, fallback_camera)
		new_disk.global_position = incoming_item.global_position
		new_disk.top_level = true
		new_disk.set_launch_parameters(launch_path, launch_speed, launch_angle, true)
	return new_disk
