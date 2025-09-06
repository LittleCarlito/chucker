extends StateData
class_name ConfigurationState

var _configuration_state: Dictionary

func get_state_data() -> Dictionary:
	return self._configuration_state.duplicate(true)

func duplicate() -> ConfigurationState:
	var new_state = ConfigurationState.new()
	new_state._configuration_state = self._configuration_state.duplicate(true)
	return new_state