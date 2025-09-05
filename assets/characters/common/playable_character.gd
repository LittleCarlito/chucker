extends LoadoutCharacter
class_name PlayableCharacter

func _ready() -> void:
	super._ready()
	# Input
	GlobalInputController.connect(SIGNAL_NAME.PRIMARY_HOLD, _handle_primary_hold)
	GlobalInputController.connect(SIGNAL_NAME.PRIMARY_RELEASE, _handle_primary_release)
	# Movement
	GlobalInputController.connect(SIGNAL_NAME.ROTATE, _handle_rotation_signal)
	GlobalInputController.connect(SIGNAL_NAME.JUMP_ACTION, _handle_jump_input)
	GlobalInputController.connect(SIGNAL_NAME.LEFT_HOLD, _handle_left_hold)
	GlobalInputController.connect(SIGNAL_NAME.RIGHT_HOLD, _handle_right_hold)
	GlobalInputController.connect(SIGNAL_NAME.WQSE_INPUT_DIRECTION, _handle_input_direction)
	GlobalInputController.connect(SIGNAL_NAME.SPRINT_ACTION, _handle_sprint_action)
	GlobalInputController.connect(SIGNAL_NAME.SPRINT_RELEASE, _handle_sprint_release)

func equip_item(new_item: Node3D) -> Variant:
	self._give_camera(new_item)
	# TODO Should have this based off state instead
	#			If it is a playable character that is focused by a rig and equips something then do the mouse shit
	#		But really should be state based so everything happens and at the end of the frame the state is checked and shit happens
	GlobalCursorController.request_visible(self, "Equipped an item")
	return super.equip_item(new_item)

func reload_project_settings() -> void:
	if not camera_container.reset_zoom():
		Logger.debug(Logger.NULL_CAMERA_LOG, [Logger.RESET_ZOOM], self)

func _transfer_and_enable(incoming_camera: Camera3D) -> void:
	if is_movement_disabled():
		enable_movement()
	if is_rotation_disabled():
		enable_rotation()
	self.just_output = false
	self.set_camera(incoming_camera)

func _handle_input_direction(incoming_direction: Vector2) -> void:
	var final_direction: Vector3 = Vector3(0, 0, 0)
	if(is_on_floor()):
		final_direction = (self.transform.basis * Vector3(incoming_direction.x, 0, incoming_direction.y)).normalized()
	self.move(final_direction)

func _handle_sprint_action() -> void:
	self.start_sprint()

func _handle_sprint_release() ->void:
	self.stop_sprint()

func _handle_primary_hold(delta: float) -> void:
	self.item_hold_action(delta, focusing_output)

func _handle_primary_release() -> void:
	self.item_hold_release()

func _handle_rotation_signal(incoming_axis: Vector3, incoming_amount: float) -> void:
	self.rotate_equipped_item(incoming_axis, incoming_amount)

func _handle_left_hold(_delta: float) -> void:
	if self.is_rotation_enabled():
		self.rotate_y_axis(deg_to_rad(CameraConfig.get_rotate_speed()))

func _handle_right_hold(_delta: float) -> void:
	if self.is_rotation_enabled():
		self.rotate_y_axis(deg_to_rad(-CameraConfig.get_rotate_speed()))

func _handle_jump_input() -> void:
	self.jump()
