extends Camera3D

@export_range(0, 10, 0.01) var sensitivity : float = 3
@onready var _velocity = GLOBAL_SETTINGS.PLAYER.RUN_SPEED

var main_cam : Camera3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	main_cam = get_viewport().get_camera_3d()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Forward, backward, left, right controls
	var direction = Vector3(
		float(Input.is_physical_key_pressed(KEY_D)) - float(Input.is_physical_key_pressed(KEY_A)),
		float(Input.is_physical_key_pressed(KEY_E)) - float(Input.is_physical_key_pressed(KEY_Q)), 
		float(Input.is_physical_key_pressed(KEY_S)) - float(Input.is_physical_key_pressed(KEY_W))
	).normalized()
	translate(direction * _velocity * delta)


func _unhandled_input(event: InputEvent) -> void:
	# Looking controls
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			rotation.y -= event.relative.x / 1000 * sensitivity
			rotation.x -= event.relative.y / 1000 * sensitivity
			rotation.x = clamp(rotation.x, PI/-2, PI/2)
	# Toggle cameras
		if event is InputEventKey && event.is_pressed():
			if event.keycode == KEY_MINUS:
				var cam := main_cam
				cam.current = !cam.current
				current = !cam.current
