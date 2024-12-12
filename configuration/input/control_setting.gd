extends Node

class_name ControlSetting

var keycode: int
var input_type: InputEventLibrary.INPUT_TYPE
var input_description: String

func _init(incomingKeycode: int, incoming_type:  InputEventLibrary.INPUT_TYPE, incoming_description: String) -> void:
	keycode = incomingKeycode
	input_type = incoming_type
	input_description = incoming_description

func _to_string() -> String:
	var format_string = "Keycode: \"%s\"; Input type: \"%s\"; Description: \"%s\""
	var input_type_string = InputEventLibrary.get_type_string(input_type)
	return format_string % [str(keycode), input_type_string, input_description]
