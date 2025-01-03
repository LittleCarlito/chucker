extends Control
class_name OptionTab

# TODO Refactor this class to get rid of initialize_ui and the value_updated signal

const _USER_SET_CHANGE: String = "User set change found for %s in intermediate change dictionary"
const _DISCARDING_DETECTED: String = "Discaring detected value \"%s\""

# Abstract class; Implementers use signal
@warning_ignore("unused_signal")
signal value_updated(data_type: UIData.TYPE, updated_entry: Dictionary)

var applied_changes: Dictionary = {}
var intermediate_changes: Dictionary = {}
var detected_changes: Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

## Applies intermediate and detected settings
func _apply_settings() -> void:
	# If there was a detected change and no conflicting set change save the detected change
	var detected_change_keys: Array = detected_changes.keys()
	for change_key in detected_change_keys:
		var change_key_value = detected_changes.get(change_key)
		if !intermediate_changes.has(change_key):
			intermediate_changes[change_key] = change_key_value
		else:
			var formatted_string: String = _USER_SET_CHANGE + CONSTANTS.LOG_SEPARATOR + _DISCARDING_DETECTED
			Logger.debug(formatted_string, [change_key, str(change_key_value)], self)
	# Apply all intermediate settings
	var intermediate_keys: Array = intermediate_changes.keys()
	for intermediate_key in intermediate_keys:
		var intermediate_change: Callable = intermediate_changes.get(intermediate_key) as Callable
		intermediate_change.call()

func reset_intermediate() -> void:
	intermediate_changes = {}
	detected_changes = {}

func reset_applied() -> void:
	applied_changes = {}

## Reloads UI variables from global values
func initialize_ui() -> void:
	pass
