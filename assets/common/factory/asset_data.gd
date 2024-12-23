extends LocalResource
## Stores data about this instance of the associated asset
## Used in interaction, contruction, and deconstruction of assets in the world
class_name AssetData

const _NO_VALUE: String = "No value assicated in the creation matrix for \"%s\""

## Used for storing type property in engine Groups
const TYPE_PROPERTY: String = "Type"
## Describes the type and assumed functionality of the object
enum TYPE{FORCE = 0, PATH = 1, PULL = 2, CHARGE = 3, TEE = 10, HOLE_NODE = 11, HOLE = 12, ITEM_CONTAINER = 20, CAMERA_CONTAINER = 21, CAMERA = 22, PLAYER = 100, LEVEL = 200, UNKNOWN = 999}
## Describes the objects ability to see
enum CAMERA_STATE{EXISTS = 0, TRACKABLE = 1, VIEWABLE = 2, ACTIVE = 3, UNKNOWN = 999}
## Describes if the object is in a controlled state
enum ITEM_STATE{DISABLED = 0, DEACTIVATED = 1, ACTIVATED = 2, UNKNOWN = 999}

## The type of this instance of the asset
@export var internal_type: AssetData.TYPE
## The group_name set via code for this instance of the asset
@export var group_name: String
## The type of asset created by this instance of the asset
@export var creation_type: AssetData.TYPE
## The controllable state of this asset
@export var item_state: AssetData.ITEM_STATE
## The state of this asset's internal camera
@export var camera_state: AssetData.CAMERA_STATE

const CREATION_MATRIX: Dictionary = {
	TYPE.CHARGE: [TYPE.FORCE],
	TYPE.PULL: [TYPE.PATH],
	TYPE.PATH: [TYPE.FORCE],
	TYPE.FORCE: [TYPE.CHARGE, TYPE.PULL]
}

const ITEM_COLOR: Dictionary = {
	AssetData.TYPE.FORCE: GlobalSettings.COLOR.FORCE,
	AssetData.TYPE.PATH: GlobalSettings.COLOR.PATH,
	AssetData.TYPE.UNKNOWN: GlobalSettings.DEFAULTS.COLOR
}

## Creates an AssetData rescource based off given parameters
## Defaults creation type to incoming_internal type if none or UNKNOWN given for creation_type
static func create_item_data(incoming_internal: AssetData.TYPE, incoming_state: AssetData.ITEM_STATE = AssetData.ITEM_STATE.DISABLED, incoming_camera_state: AssetData.CAMERA_STATE = AssetData.CAMERA_STATE.EXISTS, incoming_create: AssetData.TYPE = AssetData.TYPE.UNKNOWN, incoming_group: String = GlobalSettings.DEFAULTS.GROUP) -> AssetData:
	var new_data: AssetData = AssetData.new()
	new_data.internal_type = incoming_internal
	new_data.item_state = incoming_state
	new_data.camera_state = incoming_camera_state
	new_data.group_name = incoming_group
	new_data.creation_type = incoming_create
	new_data._setup_local_to_scene()
	return new_data

## Takes in type and returns corresponding color
## Returns UNKNOWN COLOR_DEFAULT from GlobalSettings if type is not known
static func get_item_color(incoming_type: AssetData.TYPE) -> Color:
	return ITEM_COLOR.get(incoming_type, GlobalSettings.DEFAULTS.COLOR)

## Takes CameraController and determines the AssetData.CAMERA_STATE equivalent given that CameraContainers properties
static func get_camera_state(camera_container: CameraContainer = null) -> AssetData.CAMERA_STATE:
	var updated_state: AssetData.CAMERA_STATE = AssetData.CAMERA_STATE.EXISTS
	if camera_container != null:
		updated_state = AssetData.CAMERA_STATE.TRACKABLE
		if camera_container.has_camera():
			updated_state = AssetData.CAMERA_STATE.VIEWABLE
			if camera_container.is_current():
				updated_state = AssetData.CAMERA_STATE.ACTIVE
	return updated_state

## Retrieves the creation type associated with the given incoming_type
## Takes previous_internal_type into account if multiple creation values are possible
## Uses first value if previous_internal_type was needed to determine but not provided
static func get_associated_creation_type(incoming_type: AssetData.TYPE, previous_internal_type: AssetData.TYPE = AssetData.TYPE.UNKNOWN) -> AssetData.TYPE:
	var associated_type: AssetData.TYPE = AssetData.TYPE.UNKNOWN
	var possible_creation_types: Array = CREATION_MATRIX.get(incoming_type, []) as Array
	if possible_creation_types != null && !possible_creation_types.is_empty():
		if possible_creation_types.size() > 1:
			var previous_index: int = possible_creation_types.find(previous_internal_type)
			if previous_index > -1:
				associated_type = possible_creation_types[previous_index]
			else:
				associated_type = possible_creation_types[0]
		else:
			associated_type = possible_creation_types[0]
	else:
		var formatted_string: String = _NO_VALUE + CONSTANTS.LOG_SEPARATOR + CONSTANTS.RETURNING_UNKNOWN_LOG
		Logger.debug(formatted_string, [str(incoming_type)], null)
	return associated_type
