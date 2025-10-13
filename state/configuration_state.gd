# Game instance settings including physics parameters, player count, and environmental modifiers
class_name ConfigurationState

var _configuration_state: Dictionary

func get_state_data() -> Dictionary:
	return _configuration_state.duplicate(true)

func duplicate(deep_clone: bool = false) -> ConfigurationState:
	var new_state = ConfigurationState.new()
	new_state._configuration_state = _configuration_state.duplicate(deep_clone)
	return new_state