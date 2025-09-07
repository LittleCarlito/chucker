extends Node

## Autoloaded singleton
## Pretty much just forwarding calls to GameState
##		Acts as gatekeeper for what non-state users can do
##		Logs their interactions and status of their attempts with reasoning

signal state_game_change(new_state: GameState)
signal status_game_change(new_status: GameState.STATUS)
signal state_input_change(new_state: InputState)
signal state_configuration_change(new_state: ConfigurationState)

var _game_state: GameState

func _ready() -> void:
	self._game_state = GameState.new()
	self._game_state.connect(SIGNAL_NAME.STATUS_GAME_CHANGE, _handle_game_status_change)
	self._game_state.connect(SIGNAL_NAME.STATE_INPUT_CHANGE, _handle_input_state_change)
	self._game_state.connect(SIGNAL_NAME.STATE_CONFIGURATION_CHANGE, _handle_configuration_state_change)

func get_game_state() -> GameState:
	return self._game_state.duplicate(true)

func get_current_status() -> GameState.STATUS:
	return self._game_state.get_current_status()

func is_main_menu() -> bool:
	return self._game_state.get_current_status() == GameState.STATUS.MAIN_MENU

func is_pause_menu() -> bool:
	return self._game_state.get_current_status() == GameState.STATUS.PAUSE_MENU

func is_running_scene() -> bool:
	return self._game_state.get_current_status() == GameState.STATUS.RUNNING_SCENE

func is_unknown() -> bool:
	return self._game_state.get_current_status() == GameState.STATUS.UNKNOWN

func _handle_game_status_change(new_status: GameState.STATUS) -> void:
	pass

func _handle_input_state_change(new_state: InputState) -> void:
	pass

func _handle_configuration_state_change(new_state: ConfigurationState) -> void:
	pass

func _handle_state_change() -> void:
	pass
