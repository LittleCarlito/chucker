extends SubViewport


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# TODO Make below a Node3D so it can be one little object maybe
# TODO Make a scene with a camera viewport canvas and sprite
#		Figure out if having the sprite a certain distance makes it accurate for the standard window
#		Mess around and figure out what makes it accurate then make it consistent for changes to window size
#		Then bring it back to here

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if get_window().mode == Window.MODE_WINDOWED:
		self.size.x = get_window().size.x
		self.size.y = get_window().size.y
	pass
