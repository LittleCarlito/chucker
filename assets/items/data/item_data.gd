extends LocalResource
class_name ItemData

# Used for storing type property in Groups
const TYPE_PROPERTY: String = "Type"
enum TYPE{FORCE = 0, PATH = 1, LAUNCHER = 2, PLAYER = 3, LEVEL = 4, UNKNOWN = 99}
# Used for tracking items in Groups
enum CAMERA_STATE{EXISTS = 0, TRACKABLE = 1, VIEWABLE = 2, ACTIVE = 3, UNKNOWN = 99}
enum ITEM_STATE{DISABLED = 0, DEACTIVATED = 1, ACTIVATED = 2, UNKNOWN = 99}

@export var internal_type: ItemData.TYPE
@export var group_name: String
@export var creation_type: ItemData.TYPE
@export var item_state: ItemData.ITEM_STATE
@export var camera_state: ItemData.CAMERA_STATE

const ITEM_COLOR: Dictionary = {
	ItemData.TYPE.FORCE: GlobalSettings.COLOR.FORCE,
	ItemData.TYPE.PATH: GlobalSettings.COLOR.PATH,
	ItemData.TYPE.UNKNOWN: GlobalSettings.DEFAULTS.COLOR
}

## Creates an ItemData rescource based off given parameters
## Defaults creation type to incoming_internal type if none or UNKNOWN given for creation_type
static func create_item_data(incoming_internal: ItemData.TYPE, incoming_state: ItemData.ITEM_STATE = ItemData.ITEM_STATE.DISABLED, incoming_camera_state: ItemData.CAMERA_STATE = ItemData.CAMERA_STATE.EXISTS, incoming_create: ItemData.TYPE = ItemData.TYPE.UNKNOWN, incoming_group: String = GlobalSettings.DEFAULTS.GROUP) -> ItemData:
	var new_data: ItemData = ItemData.new()
	new_data.internal_type = incoming_internal
	new_data.item_state = incoming_state
	new_data.camera_state = incoming_camera_state
	new_data.group_name = incoming_group
	new_data.creation_type = incoming_create
	new_data._setup_local_to_scene()
	return new_data

## Takes in type and returns corresponding color
## Returns UNKNOWN COLOR_DEFAULT from GlobalSettings if type is not known
static func get_item_color(incoming_type: ItemData.TYPE) -> Color:
	return ITEM_COLOR.get(incoming_type, GlobalSettings.DEFAULTS.COLOR)

static func get_camera_state(camera_container: CameraContainer = null) -> ItemData.CAMERA_STATE:
	var updated_state: ItemData.CAMERA_STATE = ItemData.CAMERA_STATE.EXISTS
	if camera_container != null:
		updated_state = ItemData.CAMERA_STATE.TRACKABLE
		if camera_container.has_camera():
			updated_state = ItemData.CAMERA_STATE.VIEWABLE
			if camera_container.is_current():
				updated_state = ItemData.CAMERA_STATE.ACTIVE
	return updated_state
