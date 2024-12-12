extends Node3D

class_name Stopwatch

var _held_time: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

## Sets isHeld timer to true to begin accumulating time
func isHeld(delta: float) -> float:
	_held_time += delta
	return _held_time

## Returns how long isHeld was enabled
func getTime() -> float:
	return _held_time

## Resets held_time to 0
func reset() -> float:
	var final_time: float = _held_time
	_held_time = 0.0
	return final_time
