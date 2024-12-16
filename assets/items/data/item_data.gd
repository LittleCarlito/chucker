extends LocalResource
class_name ItemData

enum TYPE{FORCE = 0, PATH = 1, LAUNCHER = 2, PLAYER = 3, UNKNOWN = 99}
enum STATE{EXISTS = 0, TRACKABLE = 1, VIEWABLE = 2, ACTIVE = 3, UNKNOWN = 99}

@export var internal_type: ItemData.TYPE
@export var creation_type: ItemData.TYPE
@export var item_state: ItemData.STATE

const ITEM_COLOR: Dictionary = {
	ItemData.TYPE.FORCE: GlobalSettings.COLOR.FORCE,
	ItemData.TYPE.PATH: GlobalSettings.COLOR.PATH,
	ItemData.TYPE.UNKNOWN: GlobalSettings.DEFAULTS.COLOR
}

## Creates an ItemData rescource based off given parameters
## Defaults creation type to incoming_internal type if none or UNKNOWN given for creation_type
static func create_item_type(incoming_internal: ItemData.TYPE, incoming_state: ItemData.STATE = ItemData.STATE.EXISTS, incoming_create: ItemData.TYPE = ItemData.TYPE.UNKNOWN) -> ItemData:
	var new_data: ItemData = ItemData.new()
	new_data.item_state = incoming_state
	new_data.internal_type = incoming_internal
	new_data.creation_type = incoming_create
	new_data._setup_local_to_scene()
	return new_data

## Takes in type and returns corresponding color
## Returns UNKNOWN COLOR_DEFAULT from GlobalSettings if type is not known
static func get_item_color(incoming_type: ItemData.TYPE) -> Color:
	return ITEM_COLOR.get(incoming_type, GlobalSettings.DEFAULTS.COLOR)

static func get_item_state(camera_container: CameraContainer = null) -> ItemData.STATE:
	var updated_state: ItemData.STATE = ItemData.STATE.EXISTS
	if camera_container != null:
		updated_state = ItemData.STATE.TRACKABLE
		if camera_container.has_camera():
			updated_state = ItemData.STATE.VIEWABLE
			if camera_container.is_current():
				updated_state = ItemData.STATE.ACTIVE
	return updated_state
