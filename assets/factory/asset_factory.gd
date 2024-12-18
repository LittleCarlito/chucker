extends Node

const _camera_container_scene: PackedScene = preload("res://assets/items/camera/camera_container.tscn")
const _camera_scene: PackedScene = preload("res://assets/items/camera/standard_camera.tscn")
const _force_scene: PackedScene = preload("res://assets/items/disks/ForceDisk.tscn")
const _path_scene: PackedScene = preload("res://assets/items/disks/PathDisk.tscn")
const _charge_scene: PackedScene = preload("res://assets/items/disks/ChargeDisk.tscn")
const _pull_scene: PackedScene = preload("res://assets/items/disks/PullDisk.tscn")
const _player_scene: PackedScene = preload("res://assets/characters/chuck_chucker.tscn")
const _item_container_scene: PackedScene = preload("res://assets/items/common/item_container.tscn")

var scene_library: Dictionary = {
	AssetData.TYPE.CAMERA_CONTAINER: _camera_container_scene,
	AssetData.TYPE.CAMERA: _camera_scene,
	AssetData.TYPE.FORCE: _force_scene,
	AssetData.TYPE.PATH: _path_scene,
	AssetData.TYPE.CHARGE: _charge_scene,
	AssetData.TYPE.PULL: _pull_scene,
	AssetData.TYPE.PLAYER: _player_scene,
	AssetData.TYPE.ITEM_CONTAINER: _item_container_scene
}

const _NO_MATCH_LOG: String = "No match for incoming creation type \"%s\" could be found in the scene library; Nothing will be spawned"
const _CREATE_AND_LAUNCH: String = "create_and_launch"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
# TODO Make a DiskFactory
#		AssetFactory still recieves the calls it just routes it to the correct subfactory
# TODO Need to use group_name from AssetData and put the disk in that group as the correct type in the correct states
func create_and_launch(flight_data: FlightData, item_data: AssetData) -> void:
	var item_type: AssetData.TYPE = item_data.creation_type
	if item_type == AssetData.TYPE.UNKNOWN:
		item_type = item_data.internal_type
	# TODO item_owner and fallback things are going to be handled by throwers via group methods or signal bus
	#var item_owner: ChuckChucker = incoming_item.get_item_owner()
	#var fallback_camera: Camera3D = incoming_item.get_fallback_camera()
	# TODO Continuing from here
	match item_type:
		AssetData.TYPE.FORCE:
			# TODO For now making them all viewable; Need to make it so that isn't always the case
			var force_disk: ForceDisk = new_force_disk()
			force_disk._create_camera_container()
			# TODO here use group id to have it added to the owner of that group as a child and set as top level
			#groupCaller.methodname(true for setting top leve)
			get_tree().get_root().add_child(force_disk)
			force_disk.prepare_item(item_type)
			# TODO I think here when facing not forward disks will still launch forward
			force_disk.global_position = flight_data.flight_path[0]
			force_disk.set_launch_parameters(flight_data)
			force_disk.launch_disk()
		AssetData.TYPE.PATH:
			var path_disk: PathDisk = AssetFactory.new_path_disk()
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
	# TODO Should create the ChargeDisk and add it to the group for the passed in Chuck
	#		Should add the new disk as a child to ChuckChucker
	#			Should have method in ChuckChucker to set holdItem or something
		#var rigid_disk: ForceDisk = colliding_object as ForceDisk
		#match rigid_disk.get_item_type():
			#AssetData.TYPE.FORCE:
				#player_item = ChargeDisk.new_object()
			#AssetData.TYPE.PATH:
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

func spawn_asset(item_data: AssetData, spawn_parent: Node3D, spawn_location: Vector3 = Vector3(0, 1, 0)) -> void:
	var created_node: Node3D = create_asset(item_data)
	spawn_parent.add_child(created_node)
	created_node.global_position = spawn_location

func create_asset(item_data: AssetData) -> Node3D:
	var internal_type: AssetData.TYPE = item_data.internal_type
	var new_packed_scene: PackedScene = scene_library.get(internal_type, null)
	return _instantiate_packed_scene(new_packed_scene)

static func _instantiate_packed_scene(incoming_scene: PackedScene) -> Node3D:
	var new_node: Node3D = incoming_scene.instantiate()
	_brand(new_node)
	return new_node

# TODO Make sure the classes that need it have their local scene/global group creation in their ready methods
static func new_camera_container() -> CameraContainer:
	var new_container: CameraContainer = _camera_container_scene.instantiate()
	_brand(new_container)
	return new_container

static func new_camera() -> Camera3D:
	var new_camera_instance: Camera3D = _camera_scene.instantiate()
	_brand(new_camera_instance)
	return new_camera_instance

static func new_force_disk() -> ForceDisk:
	var new_disk: ForceDisk = _force_scene.instantiate()
	_brand(new_disk)
	return new_disk

static func new_path_disk() -> PathDisk:
	var new_disk: PathDisk = _path_scene.instantiate()
	_brand(new_disk)
	return new_disk

static func new_charge_disk() -> ChargeDisk:
	var new_disk: ChargeDisk = _charge_scene.instantiate()
	_brand(new_disk)
	return new_disk

static func new_pull_disk() -> PullDisk:
	var new_disk: PullDisk = _pull_scene.instantiate()
	_brand(new_disk)
	return new_disk

static func new_player() -> ChuckChucker:
	var new_player: ChuckChucker = _player_scene.instantiate()
	_brand(new_player)
	return new_player

static func new_item_controller() -> ItemContainer:
	var new_controller: ItemContainer = _item_container_scene.instantiate()
	_brand(new_controller)
	return new_controller

static func _brand(incoming_node: Node) -> void:
	incoming_node.name = incoming_node.name + "-" + str(incoming_node.get_instance_id())
