extends Node

class_name ControlSetting

var keycode: int
var inputType: InputEventLibrary.INPUT_TYPE
var inputDescription: String

func _init(incomingKeycode: int, incomingInputType:  InputEventLibrary.INPUT_TYPE, incomingDescription: String) -> void:
	self.keycode = incomingKeycode
	self.inputType = incomingInputType
	self.inputDescription = incomingDescription
