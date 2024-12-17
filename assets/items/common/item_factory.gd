extends Node

# TODO Need to refactor this to Item_Factory

const _CREATE_AND_LAUNCH: String = "create_and_launch"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
# TODO In ECS formatting this will (hopefully) become a resource that is added as a disk_launcher or something to objects that need the ability to spawn
# TODO Need to use group_name from ItemData and put the disk in that group as the correct type in the correct states
func create_and_launch(flight_data: FlightData, item_data: ItemData) -> void:
	var item_type: ItemData.TYPE = item_data.creation_type
	if item_type == ItemData.TYPE.UNKNOWN:
		item_type = item_data.internal_type
	# TODO item_owner and fallback things are going to be handled by throwers via group methods or signal bus
	#var item_owner: ChuckChucker = incoming_item.get_item_owner()
	#var fallback_camera: Camera3D = incoming_item.get_fallback_camera()
	# TODO Continuing from here
	match item_type:
		ItemData.TYPE.FORCE:
			# TODO For now making them all viewable; Need to make it so that isn't always the case
			var force_disk: ForceDisk = ForceDisk.new_viewable_disk()
			# TODO here use group id to have it added to the owner of that group as a child and set as top level
			#groupCaller.methodname(true for setting top leve)
			get_tree().get_root().add_child(force_disk)
			force_disk.prepare_item(item_type)
			# TODO I think here when facing not forward disks will still launch forward
			force_disk.global_position = flight_data.flight_path[0]
			force_disk.set_launch_parameters(flight_data)
			force_disk.launch_disk()
		ItemData.TYPE.PATH:
			var path_disk: PathDisk = PathDisk.new_object()
			# TODO here use group id to have it added to the owner of that group as a child and set as top level
			#groupCaller.methodname(true for setting top leve)
			get_tree().get_root().add_child(path_disk)
			path_disk.global_position = flight_data.flight_path[0]
			path_disk.set_launch_parameters(flight_data)
		_:
			var formattedString: String = CONSTANTS.UNSUPPORTED_TYPE_LOG + CONSTANTS.LOG_SEPARATOR + CONSTANTS.RETURNING_NULL_LOG
			Logger.warn(formattedString, [_CREATE_AND_LAUNCH, str(item_type)], self)

func equip_item(item_owner: ChuckChucker, incoming_item: ForceDisk) -> void:
	pass
	# TODO ACTUAL CONTINUE: Move this logic to factory; Have it take in ChuckChucker and ForceDisk that was picked up
	#		Should create the ChargeDisk and add it to the group for the passed in Chuck
	#		Should add the new disk as a child to ChuckChucker
	#			Should have method in ChuckChucker to set holdItem or something
		#var rigid_disk: ForceDisk = colliding_object as ForceDisk
		#match rigid_disk.get_item_type():
			#ItemData.TYPE.FORCE:
				#player_item = ChargeDisk.new_object()
			#ItemData.TYPE.PATH:
				#player_item = PullDisk.new_object()
			#_:
				#Logger.error(_UKNOWN_OBJECT_LOG, [], self)
		## Connect the playerDisk rotation signal to chucker
		#if player_item != null:
			## TODO Need to update the methods taking the camera in to reparent it to the object receiving it
			#player_item.prepare_item(rigid_disk.get_item_type(), self, camera_container.get_camera())
			#player_item.rotate_parent.connect(_handle_rotation)
			#item_controller.add_child(player_item)
		#rigid_disk.pick_up()
	#else:
		## TODO Should really figure out something else to do here
		#colliding_object.queue_free()

# TODO Method to spawn given item data at given loction
# TODO Use Passed in state stuff to determine what should be created within the object and what it should be set to
func spawn_item(item_data: ItemData, global_location: Vector3 = Vector3(0, 1, 0)) -> void:
	pass
