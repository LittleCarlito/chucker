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

## Creates new item based off incoming item data
## New item has its physical parameters set to follow the flight_data given
func create_and_launch(flight_data: FlightData, item_data: AssetData) -> void:
	var item_type: AssetData.TYPE = item_data.creation_type
	if item_type == AssetData.TYPE.UNKNOWN:
		item_type = item_data.internal_type
	var group_name: String = item_data.group_name
	if group_name == null || group_name.is_empty():
		group_name = GlobalSettings.DEFAULTS.GROUP
		Logger.debug(_NO_GROUP_PROVIDED, [group_name], self)
	var associated_creation_type: AssetData.TYPE = AssetData.get_associated_creation_type(item_data.creation_type, item_data.internal_type)
	var new_asset_data: AssetData = AssetData.create_item_data(item_data.creation_type, AssetData.ITEM_STATE.ACTIVATED, AssetData.CAMERA_STATE.ACTIVE, associated_creation_type, group_name)
	var new_asset: Node3D = AssetFactory.create_asset(new_asset_data.internal_type)
	if new_asset != null:
		_set_asset_data(new_asset, new_asset_data)
		get_tree().get_root().add_child(new_asset)
		# Might need a check to ensure flight_path is populated first
		if !flight_data.flight_path.is_empty():
			new_asset.global_position = flight_data.flight_path[0]
			if(_set_launch_parameters(new_asset, flight_data)):
				if not _launch_asset(new_asset):
					Logger.debug(_LAUNCH_RESULT_STRING, [str(new_asset), _FAILURE], self)
				# Regardless of flight result have the items in th given data group update their status data
				if item_data.group_name != null:
					get_tree().call_group(item_data.group_name, GroupData.UPDATE_STATE)
			else:
				Logger.debug(_LAUNCH_NOT_SET, [str(new_asset)], self)
		else:
			var formatted_string: String = _EMPTY_FLIGHT_PATH + Logger.LOG_SEPARATOR + _REQUIRES_ONE_VECTOR
			Logger.debug(formatted_string, [str(flight_data)], self)
			pass
	else:
		Logger.debug(_INVALID_INCOMING_ITEM, [str(item_data)], self)

## TODO Equips incoming owner with internal type found inside given item
# BUG Spawns at the foot of item_owner
func create_and_give_item(item_owner: ChuckChucker, incoming_item: ForceDisk) -> void:
	# TODO Should create the ChargeDisk and add it to the group for the passed in Chuck
	#		Should add the new disk as a child to ChuckChucker
	#			Should have method in ChuckChucker to set holdItem or something
	var new_creation_type: AssetData.TYPE = AssetData.get_associated_creation_type(incoming_item.asset_data.creation_type, incoming_item.asset_data.internal_type)
	var new_item_data: AssetData = AssetData.create_item_data(incoming_item.asset_data.creation_type, AssetData.ITEM_STATE.ACTIVATED, AssetData.CAMERA_STATE.ACTIVE, new_creation_type, item_owner.asset_data.group_name)
	var new_asset: Node3D = AssetFactory.create_asset(incoming_item.asset_data.creation_type)
	if new_asset != null:
		_set_asset_data(new_asset, new_item_data)
		item_owner.equip_item(new_asset)
		incoming_item.pick_up()
	else:
		Logger.info(_INVALID_INCOMING_ITEM, [str(incoming_item)], self)

# TODO Implement
func dump_asset(_overflow_item: Node3D) -> void:
	# TODO Spawn this into the Levels default spawn area
	# TODO Should eventually have it dump on top of whatever entity caused it to overflow
	pass

# TODO Make sure that nodes check for AssetData in their _ready and add themselves to the group if one exists there
func spawn_asset(asset_data: AssetData, spawn_parent: Node3D, spawn_location: Vector3 = Vector3(0, 1, 0)) -> void:
	var created_node: Node3D = AssetFactory.create_asset(asset_data.internal_type)
	if created_node.has_method(GroupData.SET_ASSET_DATA):
		created_node.call(GroupData.SET_ASSET_DATA, asset_data)
	spawn_parent.add_child(created_node)
	created_node.global_position = spawn_location

static func _set_asset_data(incoming_asset: Node3D, incoming_data: AssetData) -> bool:
	var data_set: bool = false
	if incoming_asset.has_method(GroupData.SET_ASSET_DATA):
		incoming_asset.call(GroupData.SET_ASSET_DATA, incoming_data)
		data_set = true
	else:
		Logger.debug(Logger.NO_METHOD_FOUND, [Logger.SET_ASSET_DATA, str(incoming_asset)], null)
	return data_set

static func _set_launch_parameters(incoming_asset: Node3D, incoming_data: FlightData) -> bool:
	var data_set: bool = false
	if incoming_asset.has_method(GroupData.SET_FLIGHT_DATA):
		incoming_asset.call(GroupData.SET_FLIGHT_DATA, incoming_data)
		data_set = true
	else:
		Logger.debug(Logger.NO_METHOD_FOUND, [Logger.SET_FLIGHT_DATA, str(incoming_asset)], null)
	return data_set

static func _launch_asset(incoming_asset: Node3D) -> bool:
	var asset_launched: bool = false
	if incoming_asset.has_method(GroupData.LAUNCH):
		incoming_asset.call(GroupData.LAUNCH)
		asset_launched = true
	else:
		Logger.debug(Logger.NO_METHOD_FOUND, [Logger.LAUNCH, str(incoming_asset)], null)
	return asset_launched	
