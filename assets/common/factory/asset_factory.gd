extends Node
class_name AssetFactory

const _camera_container_scene: PackedScene = preload("res://assets/common/camera/camera_container.tscn")
const _camera_scene: PackedScene = preload("res://assets/common/camera/standard_camera.tscn")
const _force_scene: PackedScene = preload("res://assets/items/disks/ForceDisk.tscn")
const _path_scene: PackedScene = preload("res://assets/items/disks/PathDisk.tscn")
const _charge_scene: PackedScene = preload("res://assets/items/disks/ChargeDisk.tscn")
const _pull_scene: PackedScene = preload("res://assets/items/disks/PullDisk.tscn")
const _player_scene: PackedScene = preload("res://assets/characters/chuck_chucker.tscn")
const _item_container_scene: PackedScene = preload("res://assets/items/common/item_container.tscn")
const _chuck_tee_scene: PackedScene = preload("res://assets/buildings/course/chuck_tee.tscn")
const _chuck_hole_scene: PackedScene = preload("res://assets/buildings/course/chuck_hole.tscn")
const _hole_node_scene: PackedScene = preload("res://assets/buildings/course/hole_node.tscn")

const scene_library: Dictionary = {
	AssetData.TYPE.CAMERA_CONTAINER: _camera_container_scene,
	AssetData.TYPE.CAMERA: _camera_scene,
	AssetData.TYPE.FORCE: _force_scene,
	AssetData.TYPE.PATH: _path_scene,
	AssetData.TYPE.CHARGE: _charge_scene,
	AssetData.TYPE.PULL: _pull_scene,
	AssetData.TYPE.PLAYER: _player_scene,
	AssetData.TYPE.ITEM_CONTAINER: _item_container_scene,
	AssetData.TYPE.TEE: _chuck_tee_scene,
	AssetData.TYPE.HOLE: _chuck_hole_scene,
	AssetData.TYPE.HOLE_NODE: _hole_node_scene
}

const _INSTANTIATE_PACKED_SCENE: String = "_instantiate_packed_scene"

static func create_asset(asset_type: AssetData.TYPE) -> Node3D:
	var new_packed_scene: PackedScene = scene_library.get(asset_type, null)
	return _instantiate_packed_scene(new_packed_scene)

static func _instantiate_packed_scene(incoming_scene: PackedScene) -> Node3D:
	var return_node: Node3D = null
	if incoming_scene != null:
		var new_node: Node3D = incoming_scene.instantiate()
		_brand(new_node)
		return_node = new_node
	else:
		var formatted_string: String = CONSTANTS.NULL_PARAMETER_STRING + CONSTANTS.LOG_SEPARATOR + CONSTANTS.CANNOT_ACTION_STRING + CONSTANTS.LOG_SEPARATOR + CONSTANTS.RETURNING_NULL_LOG
		Logger.debug(formatted_string, [_INSTANTIATE_PACKED_SCENE], null)
	return return_node

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
	var new_chuck: ChuckChucker = _player_scene.instantiate()
	_brand(new_chuck)
	return new_chuck

static func new_item_controller() -> ItemContainer:
	var new_controller: ItemContainer = _item_container_scene.instantiate()
	_brand(new_controller)
	return new_controller

static func new_course_tee() -> ChuckTee:
	var new_chuck_tee: ChuckTee = _chuck_tee_scene.instantiate()
	_brand(new_chuck_tee)
	return new_chuck_tee

static func new_course_hole() -> ChuckHole:
	var new_chuck_hole: ChuckHole = _chuck_hole_scene.instantiate()
	_brand(new_chuck_hole)
	return new_chuck_hole

static func new_course_node() -> HoleNode:
	var new_hole_node: HoleNode = _hole_node_scene.instantiate()
	_brand(new_hole_node)
	return new_hole_node
	
static func _brand(incoming_node: Node) -> void:
	incoming_node.name = incoming_node.name + "-" + str(incoming_node.get_instance_id())
