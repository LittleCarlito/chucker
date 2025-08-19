extends Node

const _NO_GROUP_PROVIDED: String = "No group_name provided with item_data; Launching item under \"%s\" Group"
const _ASSET_MISSING_METHOD: String = "New_asset \"%s\" doesn't have method %s: \"%s\""
const _FOCUSED_FLIGHT: String = "Focused flight: \"%s\""
const _LAUNCH_RESULT_STRING: String = "Launch for \"%s\" was %s"
const _LAUNCH_NOT_SET: String = "Launch parameters coulnd't be set on \"%s\"; Will not be launching"
const _EMPTY_FLIGHT_PATH: String = "Flight data had an empty flight path; Flight data: \"%s\""
const _INVALID_INCOMING_ITEM: String = "Incoming item \"%s\" is invalid for asset creation and could not be equipped"
const _REQUIRES_ONE_VECTOR: String = "Requires at least one Vector3"
const _FAILURE: String = "Failure"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

## Creates an AssetData rescource based off given parameters
## Defaults creation type to incoming_internal type if none or UNKNOWN given for creation_type
func create_asset_data(incoming_internal: AssetData.TYPE,
						incoming_state: AssetData.ITEM_STATE = AssetData.ITEM_STATE.DISABLED,
						incoming_camera_state: AssetData.CAMERA_STATE = AssetData.CAMERA_STATE.EXISTS,
						incoming_create: AssetData.TYPE = AssetData.TYPE.UNKNOWN,
						incoming_group: String = GameConfig.DEFAULTS.group,
						incoming_owner_rid: RID = RID()) -> AssetData:
	var new_data: AssetData = AssetData.new()
	new_data._setup_local_to_scene()
	new_data.internal_type = incoming_internal
	new_data.item_state = incoming_state
	new_data.camera_state = incoming_camera_state
	new_data.group_name = incoming_group
	new_data.creation_type = incoming_create
	new_data.owner_rid = incoming_owner_rid
	return new_data

## Creates new item based off incoming item data
## New item has its physical parameters set to follow the flight_data given
func create_and_launch(flight_data: FlightData, asset_data: AssetData) -> Node3D:
	if asset_data.creation_type == AssetData.TYPE.UNKNOWN:
		asset_data.creation_type = asset_data.internal_type
	if asset_data.group_name == null || asset_data.group_name.is_empty():
		asset_data.group_name = GameConfig.DEFAULTS.group
		Logger.debug(_NO_GROUP_PROVIDED, [asset_data.group_name], self)
	var new_asset: Node3D = AssetFactory.create_asset(asset_data.internal_type)
	if new_asset != null:
		_set_asset_data(new_asset, asset_data)
		if new_asset.has_method(GroupData.SYNC_ASSET):
			new_asset.call(GroupData.SYNC_ASSET)
		get_tree().get_current_scene().add_child(new_asset)
		# Might need a check to ensure flight_path is populated first
		if !flight_data.flight_path.is_empty():
			if(_set_launch_parameters(new_asset, flight_data)):
				if not _launch_asset(new_asset):
					Logger.debug(_LAUNCH_RESULT_STRING, [str(new_asset), _FAILURE], self)
				# Regardless of flight result have the items in th given data group update their status data
				if asset_data.group_name != null:
					get_tree().call_group(asset_data.group_name, GroupData.UPDATE_STATE)
			else:
				Logger.debug(_LAUNCH_NOT_SET, [str(new_asset)], self)
		else:
			var formatted_string: String = _EMPTY_FLIGHT_PATH + Logger.LOG_SEPARATOR + _REQUIRES_ONE_VECTOR
			Logger.debug(formatted_string, [str(flight_data)], self)
			pass
	else:
		Logger.debug(_INVALID_INCOMING_ITEM, [str(asset_data)], self)
	return new_asset

## Equips incoming owner with internal type found inside given item
func create_and_give_item(item_owner: ChuckChucker, incoming_item: ForceDisk) -> Node3D:
	var new_creation_type: AssetData.TYPE = AssetData.get_associated_creation_type(incoming_item.asset_data.creation_type, incoming_item.asset_data.internal_type)
	var new_item_data: AssetData = AssetDelivery.create_asset_data(incoming_item.asset_data.creation_type, AssetData.ITEM_STATE.ACTIVATED, AssetData.CAMERA_STATE.ACTIVE, new_creation_type, item_owner.asset_data.group_name, item_owner.get_rid())
	var new_asset: Node3D = AssetFactory.create_asset(incoming_item.asset_data.creation_type)
	if new_asset != null:
		_set_asset_data(new_asset, new_item_data)
		if new_asset.has_method(GroupData.SYNC_ASSET):
			new_asset.call(GroupData.SYNC_ASSET)
		item_owner.equip_item(new_asset)
		incoming_item.pick_up()
	else:
		Logger.info(_INVALID_INCOMING_ITEM, [str(incoming_item)], self)
	return new_asset

func drop_asset(drop_item: Node3D, drop_location: Vector3 = DEFAULTS.GIGA_LOCATION) -> void:
	# TODO OOOOO
	#			This isn't working because the Node3Ds being given from chuck are charge and pull disks so they dont' ahve gravity as they are meshes
	#				Need some form of determination to figure out what asset type is being dropped and if it is one of those drop the corresponding loaded rigid disk
	# Upnarent and move
	drop_item.reparent(get_tree().root)
	if(drop_location != DEFAULTS.GIGA_LOCATION):
		drop_item.global_position = drop_location
	# Spawn proper rigid object if only mesh
	if(drop_item is ThrowableItem):
		Logger.error("Shit gonna hover dog", [], self)
	elif(drop_item is RigidBody3D):
		Logger.error("BAZINGA", [], self)
	elif(drop_item is Node3D):
		Logger.error("BAZLORPA", [], self)
	else:
		Logger.error("Unexpected class \"%s\" has been picked up", [drop_item.get_class()], self)

func spawn_assets(incoming_spawns: Array[SpawnData]) -> Array:
	return incoming_spawns.map(spawn_asset)

## If using this function make sure that nodes check for AssetData in their _ready and add themselves to the group if one exists there
func spawn_asset(spawn_data: SpawnData) -> Node3D:
	var created_node: Node3D = AssetFactory.create_asset(spawn_data.asset_data.internal_type)
	if created_node.has_method(GroupData.SET_ASSET_DATA):
		created_node.call(GroupData.SET_ASSET_DATA, spawn_data.asset_data)
	if created_node.has_method(GroupData.SYNC_ASSET):
		created_node.call(GroupData.SYNC_ASSET)
	if spawn_data.spawn_parent != null:
		spawn_data.spawn_parent.add_child(created_node)
	else:
		get_tree().get_current_scene().add_child(created_node)
	created_node.global_position = spawn_data.spawn_location
	return created_node

static func _set_asset_data(incoming_asset: Node3D, incoming_data: AssetData) -> bool:
	var data_set: bool = false
	if incoming_asset.has_method(GroupData.SET_ASSET_DATA):
		incoming_asset.call(GroupData.SET_ASSET_DATA, incoming_data)
		data_set = true
	else:
		Logger.debug(Logger.NO_METHOD_FOUND, [GroupData.SET_ASSET_DATA, str(incoming_asset)], null)
	return data_set

static func _set_launch_parameters(incoming_asset: Node3D, incoming_data: FlightData) -> bool:
	var data_set: bool = false
	if incoming_asset.has_method(GroupData.SET_FLIGHT_DATA):
		incoming_asset.call(GroupData.SET_FLIGHT_DATA, incoming_data)
		data_set = true
	else:
		Logger.debug(Logger.NO_METHOD_FOUND, [GroupData.SET_FLIGHT_DATA, str(incoming_asset)], null)
	return data_set

static func _launch_asset(incoming_asset: Node3D) -> bool:
	var asset_launched: bool = false
	if incoming_asset.has_method(GroupData.LAUNCH):
		incoming_asset.call(GroupData.LAUNCH)
		asset_launched = true
	else:
		Logger.debug(Logger.NO_METHOD_FOUND, [Logger.LAUNCH, str(incoming_asset)], null)
	return asset_launched	
