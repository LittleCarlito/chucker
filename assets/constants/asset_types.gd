class_name AssetTypes

const FORCE: String = "force"
const PATH: String = "path"
const PULL: String = "pull"
const CHARGE: String = "charge"
const TEE: String = "tee"
const HOLE_NODE: String = "hole_node"
const HOLE: String = "hole"
const ENV_TREE: String = "env_tree"
const ITEM_CONTAINER: String = "item_container"
const CAMERA_CONTAINER: String = "camera_container"
const CAMERA: String = "camera"
const PLAYER: String = "player"
const LEVEL: String = "level"
const UNKOWN: String = "unkown"

enum TYPE {
		FORCE = 0, 
		PATH = 1, 
		PULL = 2, 
		CHARGE = 3, 
		TEE = 10, 
		HOLE_NODE = 11, 
		HOLE = 12, 
		ENV_TREE = 13, 
		ITEM_CONTAINER = 20, 
		CAMERA_CONTAINER = 21, 
		CAMERA = 22, 
		PLAYER = 100, 
		LEVEL = 200, 
		UNKNOWN = 999
}

const TYPE_TO_STRING: Dictionary = {
	TYPE.FORCE: FORCE,
	TYPE.PATH: PATH,
	TYPE.PULL: PULL,
	TYPE.CHARGE: CHARGE,
	TYPE.TEE: TEE,
	TYPE.HOLE_NODE: HOLE_NODE,
	TYPE.HOLE: HOLE,
	TYPE.ENV_TREE: ENV_TREE,
	TYPE.ITEM_CONTAINER: ITEM_CONTAINER,
	TYPE.CAMERA_CONTAINER: CAMERA_CONTAINER,
	TYPE.CAMERA: CAMERA,
	TYPE.PLAYER: PLAYER,
	TYPE.LEVEL: LEVEL,
	TYPE.UNKNOWN: UNKNOWN,
}

const STRING_TO_TYPE: Dictionary = {
	FORCE: TYPE.FORCE,
	PATH: TYPE.PATH,
	PULL: TYPE.PULL,
	CHARGE: TYPE.CHARGE,
	TEE: TYPE.TEE,
	HOLE_NODE: TYPE.HOLE_NODE,
	HOLE: TYPE.HOLE,
	ENV_TREE: TYPE.ENV_TREE,
	ITEM_CONTAINER: TYPE.ITEM_CONTAINER,
	CAMERA_CONTAINER: TYPE.CAMERA_CONTAINER,
	CAMERA: TYPE.CAMERA,
	PLAYER: TYPE.PLAYER,
	LEVEL: TYPE.LEVEL,
	UNKNOWN: TYPE.UNKNOWN,
}

static func to_string(type_value: TYPE) -> String:
	return TYPE_TO_STRING.get(type_value, UNKNOWN)

static func from_string(type_name: String) -> TYPE:
	return STRING_TO_TYPE.get(type_name, TYPE.UNKNOWN)
