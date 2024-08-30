extends ThrowableItem
class_name TracerDisk

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# TODO Make this disk launch a Node3D at the same angle and speed and get its path to its collision; Then draw the path to get the curve
#			Launch it like a disk into the main scene
#			Have it persist like the draw util does to cleanup
## Power up launch and create aim line
func hold_action(delta: float) -> void:
	pass

## Launch disk and reset objects
func release_action() -> void:
	pass
