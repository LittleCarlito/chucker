class_name StateUpdate

var _update_type: STATE.UPDATE_TYPE
var _update_details: Dictionary

func _init(incoming_type: STATE.UPDATE_TYPE, incoming_details: Dictionary) -> void:
	self._update_type = incoming_type
	self._update_details = incoming_details

func get_update_type() -> STATE.UPDATE_TYPE:
	return self._update_type

func get_update_details() -> Dictionary:
	return self._update_details

func set_update_details(incoming_dictionary: Dictionary) -> void:
	self._update_details = incoming_dictionary
