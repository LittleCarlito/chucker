extends Node

class_name ControlSetting

var keycode: int
var inputType: InputEventLibrary.INPUT_TYPE
var inputDescription: String

func _init(incomingKeycode: int, incomingInputType:  InputEventLibrary.INPUT_TYPE, incomingDescription: String) -> void:
	self.keycode = incomingKeycode
	self.inputType = incomingInputType
	self.inputDescription = incomingDescription

func _to_string() -> String:
	var formatString = "Keycode: \"%s\"; Input type: \"%s\"; Description: \"%s\""
	var inputTypeString = InputEventLibrary.get_type_string(inputType)
	return formatString % [str(keycode), inputTypeString, inputDescription]
