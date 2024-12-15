extends Resource
class_name ItemData

enum TYPE{FORCE, PATH, LAUNCHER, UNKNOWN}

@export var internal_type: TYPE
@export var creation_type: TYPE

const ITEM_COLOR: Dictionary = {
	ItemData.TYPE.FORCE: GlobalSettings.COLOR.FORCE,
	ItemData.TYPE.PATH: GlobalSettings.COLOR.PATH,
	ItemData.TYPE.UNKNOWN: GlobalSettings.DEFAULTS.COLOR
}

## Creates an ItemData rescource based off given parameters
## Defaults creation type to incoming_internal type if none or UNKNOWN given for creation_type
static func create_item_type(incoming_internal: ItemData.TYPE, incoming_create: ItemData.TYPE = ItemData.TYPE.UNKNOWN) -> ItemData:
	var new_type: ItemData = ItemData.new()
	# Type handling
	new_type.internal_type = incoming_internal
	if incoming_create != ItemData.TYPE.UNKNOWN:
		new_type.creation_type = incoming_create
	else:
		new_type.creation_type = incoming_internal
	return new_type

## Takes in type and returns corresponding color
## Returns UNKNOWN COLOR_DEFAULT from GlobalSettings if type is not known
static func get_item_color(incoming_type: ItemData.TYPE) -> Color:
	return ITEM_COLOR.get(incoming_type, GlobalSettings.DEFAULTS.COLOR)
