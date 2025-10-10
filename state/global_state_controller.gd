extends Node

## Autoloaded singleton
## Pretty much just forwarding calls to GameState
##		Acts as gatekeeper for what non-state users can do
##		Logs their interactions and status of their attempts with reasoning

const _UNSUPPORTED_HEADER: String = "Incoming header type \"%s\" was not supported; Incoming header enum value \"%d\""
const _UNSUPPORTED_TYPE: String = "Incoming type \"%s\" is not supported; %s"
const _NO_PRIMARY: String = "Items do not have a \"primary\" to retireve"
const _EMPTY_GUID: String = "GUID must be populated"
const _INVALID_HEAD_REQEUST: String = "Invalid header data request; %s"

signal state_updated(update_details: Dictionary)

var _game_state: GameState

func _ready() -> void:
	_game_state = GameState.new()
	# _game_state.connect(SIGNAL_NAME.STATE_UPDATED, _handle_game_state_change)

func register_node(incoming_node: Node3D) -> StateData:
	var return_data: StateData = null
	if incoming_node is CameraRig:
		return_data = _game_state.register_rig(incoming_node as CameraRig)
	elif incoming_node is BaseCharacter:
		return_data = _game_state.register_player(incoming_node)
	else:
		return_data = _game_state.register_asset(incoming_node)
	return return_data

func node_has_state(incoming_guid: String) -> bool:
	return _game_state.has_guid(incoming_guid)

# func get_current_status() -> GameState.STATUS:
# 	return _game_state.get_current_status()

func get_header_data(incoming_guid: String, header_type: StateHeaders.TYPE) -> Variant:
	if incoming_guid.is_empty():
		Log.error(_INVALID_HEAD_REQEUST, [_EMPTY_GUID], self)
		return null
	match header_type:
		StateHeaders.TYPE.DATA_STORAGE:
			return _game_state.duplicate(true)
		StateHeaders.TYPE.DATA:
			return _game_state.retrieve_state_data(incoming_guid)
		StateHeaders.TYPE.NODE:
			return _game_state.retrieve_node(incoming_guid)
		_:
			var string_type: String = StateHeaders.get_type_string(header_type)
			Log.error(_UNSUPPORTED_HEADER, [string_type, header_type], self)
			return null

func get_primary_guid(incoming_type: STATE.DATA_TYPE) -> String:
	return _game_state.get_primary_guid(incoming_type)

# func is_main_menu() -> bool:
# 	return _game_state.get_current_status() == GameState.STATUS.MAIN_MENU

# func is_pause_menu() -> bool:
# 	return _game_state.get_current_status() == GameState.STATUS.PAUSE_MENU

# func is_running_scene() -> bool:
# 	return _game_state.get_current_status() == GameState.STATUS.RUNNING_SCENE

# func is_unknown() -> bool:
# 	return _game_state.get_current_status() == GameState.STATUS.UNKNOWN

func print_details() -> void:
	_game_state.print_details()

func _handle_game_state_change(incoming_details: Dictionary) -> void:
	state_updated.emit(incoming_details)
