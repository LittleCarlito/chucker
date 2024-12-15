extends Resource
class_name ItemType

enum TYPE{FORCE, PATH, LAUNCHER, UNKNOWN}

@export var internal_type: TYPE
@export var creation_type: TYPE

## Creates an ItemType rescource based off given parameters
## Defaults creation type to incoming_internal type if none or UNKNOWN given for creation_type
static func create_item_type(incoming_internal: ItemType.TYPE, incoming_create: ItemType.TYPE = ItemType.TYPE.UNKNOWN) -> ItemType:
	var new_type: ItemType = ItemType.new()
	new_type.internal_type = incoming_internal
	if incoming_create != ItemType.TYPE.UNKNOWN:
		new_type.creation_type = incoming_create
	else:
		new_type.creation_type = incoming_internal
	return new_type
