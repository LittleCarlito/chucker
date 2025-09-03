extends Node

# Action signals
signal rotate(rotation_axis: Vector3, rotation_amount:float)
signal primary_action
signal primary_release
signal primary_movement(v_motion: float, h_motion: float)
signal secondary_action
signal secondary_release
signal secondary_movement(v_motion: float, h_motion: float)
signal duo_action
signal duo_release
signal duo_movemnt(v_motion: float, h_motion: float)
signal freelook_movement(v_motion: float, h_motion: float)
# UI Signals
signal pause_action
signal pause_release
signal tab_action
signal tab_release

func _input(incoming_event: InputEvent) -> void:
	self._handle_action_events(incoming_event)
	self._handle_movement_events(incoming_event)
	self._handle_ui_events(incoming_event)

# Allows chuck to look around with right/left click combinations when not equipped
func _handle_action_events(incoming_event: InputEvent) -> void:
	var no_action_input: bool = not Input.is_action_pressed(InputConfig.USER_INPUT.SECONDARY) and not Input.is_action_pressed(InputConfig.USER_INPUT.PRIMARY)
	var only_secondary: bool = Input.is_action_pressed(InputConfig.USER_INPUT.SECONDARY) and not Input.is_action_pressed(InputConfig.USER_INPUT.PRIMARY)
	# Primary clicked
	if incoming_event.is_action_pressed(InputConfig.USER_INPUT.PRIMARY):
		self.primary_action.emit()
	# Secondary clicked
	elif incoming_event.is_action_pressed(InputConfig.USER_INPUT.SECONDARY):
		self.secondary_action.emit()
	# Primary released
	elif incoming_event.is_action_released(InputConfig.USER_INPUT.PRIMARY):
		self.primary_release.emit()
	# Secondary released
	elif incoming_event.is_action_released(InputConfig.USER_INPUT.SECONDARY):
		self.secondary_release.emit()
	# Secondary and primary pressed
	elif incoming_event.is_action_pressed(InputConfig.USER_INPUT.PRIMARY) and Input.is_action_pressed(InputConfig.USER_INPUT.SECONDARY):
		self.duo_action.emit()
	# When primary is pressed and there is mouse movement
	elif incoming_event is InputEventMouseMotion and (Input.is_action_pressed(InputConfig.USER_INPUT.PRIMARY)):
		var v_motion: float = NodeUtil.get_vertical_look_amount(incoming_event)
		var h_motion: float = NodeUtil.get_horizontal_look_amount(incoming_event)
		self.primary_movement.emit(v_motion, h_motion)
	# When secondary is pressed and there is mouse movement
	elif incoming_event is InputEventMouseMotion and only_secondary:
		var v_motion: float = NodeUtil.get_vertical_aim_amount(incoming_event)
		var h_motion: float = NodeUtil.get_horizontal_aim_amount(incoming_event)
		self.secondary_movement.emit(v_motion, h_motion)
	# No actions held but movement
	elif incoming_event is InputEventMouseMotion and no_action_input:
		var v_motion: float = NodeUtil.get_vertical_look_amount(incoming_event)
		var h_motion: float = NodeUtil.get_horizontal_look_amount(incoming_event)
		self.freelook_movement.emit(v_motion, h_motion)

func _handle_movement_events(incoming_event: InputEvent) -> void:
	if incoming_event.is_action_pressed(InputConfig.USER_INPUT.ROTATE_UP) || incoming_event.is_action_pressed(InputConfig.USER_INPUT.ROTATE_DOWN):
		var rotation_adjust: float = GameConfig.DEFAULTS.rotate_adjust
		if incoming_event.is_action_pressed(InputConfig.USER_INPUT.ROTATE_DOWN):
			rotation_adjust *= -1
		self.rotate.emit(Vector3(1, 0, 0), rotation_adjust)

func _handle_ui_events(inocming_event: InputEvent) -> void:
	if inocming_event.is_action_pressed(InputConfig.USER_INPUT.PAUSE):
		self.pause_action.emit()
	if inocming_event.is_action_pressed(InputConfig.USER_INPUT.SCORE):
		self.tab_action.emit()
	if inocming_event.is_action_released(InputConfig.USER_INPUT.SCORE):
		self.tab_release.emit()
