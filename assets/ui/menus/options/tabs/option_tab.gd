extends Control
class_name OptionTab

# Abstract class; Implementers use signal
@warning_ignore("unused_signal")
signal value_updated(data_type: UIData.TYPE, updated_entry: Dictionary)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

## Reloads UI variables from global values
func initialize_ui() -> void:
	pass
