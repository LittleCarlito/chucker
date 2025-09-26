extends Node

const _NO_GROUP_PROVIDED: String = "No group_name provided with item_data; Launching item under \"%s\" Group"
const _ASSET_MISSING_METHOD: String = "New_asset \"%s\" doesn't have method %s: \"%s\""
const _FOCUSED_FLIGHT: String = "Focused flight: \"%s\""
const _LAUNCH_RESULT_STRING: String = "Launch for \"%s\" was %s"
const _LAUNCH_NOT_SET: String = "Launch parameters coulnd't be set on \"%s\"; Will not be launching"
const _EMPTY_FLIGHT_PATH: String = "Flight data had an empty flight path; Flight data: \"%s\""
const _INVALID_INCOMING_ITEM: String = "Incoming item \"%s\" is invalid for asset creation and could not be equipped"
const _REQUIRES_ONE_VECTOR: String = "Requires at least one Vector3"
const _BAD_ASSET: String = "Asset given to launch asset does not have GUID assigned; Ensure it was created through AssetFactory"
const _FAILURE: String = "Failure"

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
				if not _launch_asset(new_asset, flight_data.flight_details.focus_flight):
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
	var new_item_data: AssetData = AssetData.new(incoming_item.asset_data.creation_type, new_creation_type, item_owner.asset_data.group_name, item_owner.get_rid())
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

func drop_asset(drop_item: Node3D, drop_location: Vector3 = GameConfig.DEFAULTS.uknown_location) -> void:
	# Unparent and move
	drop_item.reparent(get_tree().current_scene)
	if(drop_location != GameConfig.DEFAULTS.uknown_location):
		drop_item.global_position = drop_location
	# Spawn proper rigid object if only mesh
	if(drop_item is ThrowableItem):
		drop_item.drop_item()
	else:
		Logger.warn("Class \"%s\" has been dropped without a function call; Item may be hovering", [drop_item.get_class()], self)

func spawn_assets(incoming_spawns: Array[SpawnData]) -> Dictionary:
	var spawned_assets: Dictionary = {}
	for spawn_data in incoming_spawns:
		var spawned_asset: Node3D = spawn_asset(spawn_data)
		var asset_type: AssetData.TYPE = spawn_data.asset_data.internal_type
		if not spawned_assets.has(asset_type):
			spawned_assets[asset_type] = []
		spawned_assets[asset_type].append(spawned_asset)
	return spawned_assets

## If using this function make sure that nodes check for AssetData in their _ready and add themselves to the group if one exists there
func spawn_asset(spawn_data: SpawnData) -> Node3D:
	var created_node: Node3D = AssetFactory.create_asset(spawn_data.asset_data.internal_type)
	if created_node.has_method(GroupData.SET_ASSET_DATA):
		created_node.call(GroupData.SET_ASSET_DATA, spawn_data.asset_data)
	if spawn_data.spawn_parent != null:
		spawn_data.spawn_parent.add_child(created_node)
	else:
		get_tree().get_current_scene().add_child(created_node)
	# BUG OOOOO
	# TODO NEED TO ALSO UPDATE THE STATE OBJECT THAT WAS JUST MADE FOR THIS IN .create_asset WITH SPAWN LOCATION
	created_node.global_position = spawn_data.spawn_location
	# TODO To fix bug above make sure all assets that will be spawned in with "positions" have this function
	#			Ensure that syncing of global position of asset is pushed up to state
	#			This is an interesting state change signal handling case
	#				Will want others to handle it
	#				Will not want the character to handle the state update signal
	#					Because it is the one making the state change
	#					So should first add some logging to confirm its detecting its own made state change
	#					Then make the logic so it handles all state changes but filters out ones itself intiiates
	#						By "initiates" I mean push UP to the state based off its CURRENT data
	# TODO Once the StatefulAsset base class has been finished we can get rid of this "has_method" call
	#			Will know that it has the method by doing created_node is StatefulAsset
	if created_node.has_method(GroupData.SYNC_ASSET):
		created_node.call(GroupData.SYNC_ASSET)
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

static func _launch_asset(incoming_asset: Node3D, focus_flight: bool = false) -> bool:
	var asset_launched: bool = false
	if incoming_asset.has_method(GroupData.LAUNCH):
		incoming_asset.call(GroupData.LAUNCH)
		asset_launched = true
		if focus_flight:

			# var focus_node: Node3D
			# TODO Make a global state controller request to have the rig integrate with the determined part based off asset type below
			#		Should be able to use existing logic for integrate shit in camera state
			#		Should be able to pass in the guid and the Node3D that we want to track as reference with that guid
			# if incoming_asset is PathDisk:
			# 	focus_node = incoming_asset.call(GroupData.GET_PATH_FOLLOW)
				# GlobalCameraController.focus_new_node(path_follow)
			# else:
			# 	focus_node = incoming_asset
				# GlobalCameraController.focus_new_node(incoming_asset)
			# TODO Create action to dispatch integrate camera with launched asset
			# TODO Need to get primary camera rig guid
			#			Create a new function in GlobalStateController for this

			# TODO Above pretty much boils down to "Create underlying StatefulObject class" for all things that can be associated to state data
			#			Then create a get integration node function in that new class
			#				Implmenters like path disk then return shit like their path_follow above from that function
			#					Thigns like force disk just return themselves
			#				Then when a camera tries to integrate based off GUID it gets the correct part of the asset
			
			if incoming_asset.has_meta(GroupData.GUID):
				var primary_camera_guid: String = GlobalStateController.get_primary_guid(GameState.DATA_TYPE.CAMERA)
				var state_string: String = StateConfiguration.get_state_string(StateConfiguration.STATE.TRACKING_FULL)
				var target_guid: String = incoming_asset.get_meta(GroupData.GUID)
				# TODO Refactor this to be a state setting action instead
				# TODO Then chase the state action handling logic through dispatch to ensure the state shit handles all data
				var set_state_dictionary: Dictionary = {
					GameAction.OWNER_GUID: primary_camera_guid,
					GameAction.STATE: state_string,
					GameAction.TARGET_GUID: target_guid
				}
				var state_action: GameAction = GameAction.new(GameAction.TYPE.SET_STATE, set_state_dictionary)
				GlobalStateController.dispatch(state_action)
			else:
				Logger.error(_BAD_ASSET, [], null)


	else:
		Logger.debug(Logger.NO_METHOD_FOUND, [Logger.LAUNCH, str(incoming_asset)], null)
	return asset_launched	
