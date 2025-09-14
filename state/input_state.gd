# Holds current input device states including keyboard, mouse, and controller inputs
class_name InputState

var input_state: Dictionary

func get_state_data() -> Dictionary:
	return self.input_state.duplicate(true)

func duplicate(deep_clone: bool = false) -> InputState:
	var new_state = InputState.new()
	new_state.input_state = self.input_state.duplicate(deep_clone)
	return new_state
