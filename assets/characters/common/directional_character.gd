extends BaseCharacter
class_name DirectionalCharacter

func _ready() -> void:
	super._ready()
	# Movement
	GlobalInputController.connect(SIGNAL_NAME.JUMP_ACTION, _handle_jump_input)
	GlobalInputController.connect(SIGNAL_NAME.LEFT_HOLD, _handle_left_hold)
	GlobalInputController.connect(SIGNAL_NAME.RIGHT_HOLD, _handle_right_hold)
	GlobalInputController.connect(SIGNAL_NAME.WQSE_INPUT_DIRECTION, _handle_input_direction)
	GlobalInputController.connect(SIGNAL_NAME.SPRINT_ACTION, _handle_sprint_action)
	GlobalInputController.connect(SIGNAL_NAME.SPRINT_RELEASE, _handle_sprint_release)

func reload_project_settings() -> void:
	if not camera_container.reset_zoom():
		Log.debug(Log.NULL_CAMERA_LOG, [Log.RESET_ZOOM], self)

func _handle_input_direction(incoming_direction: Vector2) -> void:
	var final_direction: Vector3 = Vector3(0, 0, 0)
	if(is_on_floor()):
		final_direction = (transform.basis * Vector3(incoming_direction.x, 0, incoming_direction.y)).normalized()
	move(final_direction)

func _handle_sprint_action() -> void:
	start_sprint()

func _handle_sprint_release() ->void:
	stop_sprint()

func _handle_left_hold(_delta: float) -> void:
	if is_rotation_enabled():
		rotate_y_axis(deg_to_rad(CameraConfig.get_rotate_speed()))

func _handle_right_hold(_delta: float) -> void:
	if is_rotation_enabled():
		rotate_y_axis(deg_to_rad(-CameraConfig.get_rotate_speed()))

func _handle_jump_input() -> void:
	jump()
