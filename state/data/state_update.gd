class_name StateUpdate

var _update_type: STATE.UPDATE_TYPE
var _update_details: Dictionary

func _init(incoming_type: STATE.UPDATE_TYPE, incoming_details: Dictionary) -> void:
	_update_type = incoming_type
	_update_details = incoming_details

func get_update_type() -> STATE.UPDATE_TYPE:
	return _update_type

func get_update_details() -> Dictionary:
	return _update_details

func set_update_details(incoming_dictionary: Dictionary) -> void:
	_update_details = incoming_dictionary
