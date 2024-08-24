extends Node3D

class_name StopWatch

var heldTime: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

## Sets isHeld timer to true to begin accumulating time
func isHeld(delta: float) -> void:
	heldTime += delta

## Returns how long isHeld was enabled
func getTime() -> float:
	return heldTime

## Resets heldTime to 0
func reset() -> void:
	heldTime = 0.0
