extends PlayableCharacter
class_name FreelookCharacter

func _input(event: InputEvent) -> void:
	super._input(event)
	self._handle_action_input(event)

# Allows chuck to look around with right/left click combinations when not equipped
func _handle_action_input(event: InputEvent) -> void:
	var only_secondary: bool = Input.is_action_pressed(InputConfig.USER_INPUT.SECONDARY) and not Input.is_action_pressed(InputConfig.USER_INPUT.PRIMARY)
	if self.is_unequipped():
		# Primary clicked
		if event.is_action_pressed(InputConfig.USER_INPUT.PRIMARY):
			self.press_primary_action()
		# Secondary clicked
		elif event.is_action_pressed(InputConfig.USER_INPUT.SECONDARY):
			self.press_secondary_action()
		# Primary released
		elif event.is_action_released(InputConfig.USER_INPUT.PRIMARY):
			self.release_primary_action()
		# Secondary released
		elif event.is_action_released(InputConfig.USER_INPUT.SECONDARY):
			self.release_secondary_action()
		# Secondary and primary pressed
		elif event.is_action_pressed(InputConfig.USER_INPUT.PRIMARY) and Input.is_action_pressed(InputConfig.USER_INPUT.SECONDARY):
			self.press_primary_secondary_action()
		# When primary is pressed and there is mouse movement
		elif event is InputEventMouseMotion and (Input.is_action_pressed(InputConfig.USER_INPUT.PRIMARY)):
			self.hold_primary_action(event)
		# When secondary is pressed and there is mouse movement
		elif event is InputEventMouseMotion and only_secondary:
			self.hold_secondary_action(event)

func press_primary_secondary_action() -> void:
	self._reset_camera_control()

func press_primary_action() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func hold_primary_action(event: InputEvent) -> void:
	var horizontal_rotate_amount: float = deg_to_rad(event.relative.x) * CameraConfig.get_horizontal_look_sens()
	self.horizontal_pan(horizontal_rotate_amount, self.global_position)

func release_primary_action() -> void:
	self.snap_back(self.global_rotation.z)

func press_secondary_action() -> void:
	self._handle_zoom_in()

func hold_secondary_action(event: InputEvent) -> void:
	var v_rotation_amount: float = NodeUtil.get_vertical_rotation_amount(event)
	var h_rotation_amount: float = NodeUtil.get_horizontal_rotation_amount(event)
	self.rotate_camera(v_rotation_amount, h_rotation_amount)

func release_secondary_action() -> void:
	self._handle_zoom_out()