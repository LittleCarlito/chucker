extends LoadoutCharacter
class_name PlayableCharacter

func _ready() -> void:
	super._ready()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	GlobalInputController.connect(SIGNAL_NAME.ROTATE, _handle_horizontal_rotation_signal)

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	_handle_rotation_input()
	_handle_player_action_input(delta)
	_handle_movement_input(delta)

func equip_item(new_item: Node3D) -> Variant:
	self._give_camera(new_item)
	return super.equip_item(new_item)

func _handle_player_action_input(delta: float) -> void:
	if Input.is_action_pressed(InputConfig.USER_INPUT.PRIMARY):
		self.item_hold_action(delta, focusing_output)
	if Input.is_action_just_released(InputConfig.USER_INPUT.PRIMARY):
		self.item_hold_release()

func _handle_rotation_input() -> void:
	if is_rotation_enabled():
		## Left and right rotation inputs
		if Input.is_action_pressed(InputConfig.USER_INPUT.ROTATE_LEFT):
			self.rotate_y_axis(deg_to_rad(CameraConfig.get_rotate_speed()))
		if Input.is_action_pressed(InputConfig.USER_INPUT.ROTATE_RIGHT):
			self.rotate_y_axis(deg_to_rad(-CameraConfig.get_rotate_speed()))

func _transfer_and_enable(incoming_camera: Camera3D) -> void:
	if is_movement_disabled():
		enable_movement()
	if is_rotation_disabled():
		enable_rotation()
	self.just_output = false
	self.set_camera(incoming_camera)

func _handle_movement_input(_delta: float) -> void:
	# Handle jump
	if Input.is_action_just_pressed(InputConfig.USER_INPUT.JUMP):
		self.jump()
	var input_dir = Input.get_vector(InputConfig.USER_INPUT.STRAFE_LEFT, InputConfig.USER_INPUT.STRAFE_RIGHT, InputConfig.USER_INPUT.FORWARD, InputConfig.USER_INPUT.BACKWARD)
	var final_direction: Vector3 = Vector3(0, 0, 0)
	var sprint_multiplier: float = 1
	if(is_on_floor()):
		final_direction = (self.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if Input.is_action_pressed(InputConfig.USER_INPUT.SPRINT):
			sprint_multiplier = GameConfig.DEFAULTS.sprint_multiplier
			self.zoom_out()
		elif Input.is_action_just_released(InputConfig.USER_INPUT.SPRINT):
			self.reset_zoom()
	self.move(final_direction, sprint_multiplier)

func reload_project_settings() -> void:
	if not camera_container.reset_zoom():
		Logger.debug(Logger.NULL_CAMERA_LOG, [Logger.RESET_ZOOM], self)

func _handle_horizontal_rotation_signal(incoming_axis: Vector3, incoming_amount: float) -> void:
	self.rotate_equipped_item(incoming_axis, incoming_amount)
