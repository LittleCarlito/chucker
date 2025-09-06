extends StateData
class_name PlayerState

var _player_state: Dictionary

func _init(incoming_state: Dictionary = {}) -> void:
	self._player_state = incoming_state

func get_state_data() -> Dictionary:
	return self._player_state.duplicate(true)

func duplicate() -> PlayerState:
	var new_state = PlayerState.new()
	new_state._player_state = self._player_state.duplicate(true)
	return new_state
