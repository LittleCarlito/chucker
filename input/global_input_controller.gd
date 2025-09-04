extends Node

# Action signals
signal rotate(rotation_axis: Vector3, rotation_amount:float)
signal primary_action
signal primary_hold(delta: float)
signal primary_release
signal primary_movement(v_motion: float, h_motion: float)
signal secondary_action
signal secondary_hold(delta: float)
signal secondary_release
signal secondary_movement(v_motion: float, h_motion: float)
signal duo_action
signal duo_hold(delta:float)
signal duo_release
signal duo_movemnt(v_motion: float, h_motion: float)
signal freelook_movement(v_motion: float, h_motion: float)
# Movement signals
# Jump
signal jump_action
signal jump_hold(delta: float)
signal jump_release
# Crouch
signal crouch_action
signal crouch_hold(delta: float)
signal crouch_release
# Sprint
signal sprint_action
signal sprint_hold(delta: float)
signal sprint_release
# Left
signal left_action
signal left_hold(delta: float)
signal left_release
signal alt_left_action
signal alt_left_hold(delta: float)
signal alt_left_release
# Right
signal right_action
signal right_hold(delta: float)
signal right_release
signal alt_right_action
signal alt_right_hold(delta: float)
signal alt_right_release
# Up
signal up_action
signal up_hold(delta: float)
signal up_release
# Down
signal down_action
signal down_hold(delta: float)
signal down_release
# Directional
signal input_direction(incoming_direction: Vector2)
# UI Signals
signal pause_action
signal pause_hold
signal pause_release
signal tab_action
signal tab_hold
signal tab_release

# TODO Get to state
# Mouse state
var is_primary_press: bool = false
var is_primary_hold: bool = false
var is_primary_release: bool = false
var is_secondary_press: bool = false
var is_secondary_hold: bool = false
var is_secondary_release: bool = false
var is_duo_press: bool = false
var is_duo_hold: bool = false
var is_duo_release: bool = false
var is_no_action_input: bool = false
# Keyboard state
# UI
var is_pause_press: bool = false
var is_pause_hold: bool = false
var is_pause_release: bool = false
var is_tab_press: bool = false
var is_tab_hold: bool = false
var is_tab_release: bool = false
# Character
# Jump
var is_jump_press: bool = false
var is_jump_hold: bool = false
var is_jump_release: bool = false
# Crouch
var is_crouch_press: bool = false
var is_crouch_hold: bool = false
var is_crouch_release: bool = false
# Sprint
var is_sprint_press: bool = false
var is_sprint_hold: bool = false
var is_sprint_release: bool = false
# Left
var is_left_press: bool = false
var is_left_hold: bool = false
var is_left_release: bool = false
var is_alt_left_press: bool = false
var is_alt_left_hold: bool = false
var is_alt_left_release: bool = false
# Right
var is_right_press: bool = false
var is_right_hold: bool = false
var is_right_release: bool = false
var is_alt_right_press: bool = false
var is_alt_right_hold: bool = false
var is_alt_right_release: bool = false
# Up
var is_up_press: bool = false
var is_up_hold: bool = false
var is_up_release: bool = false
# Down
var is_down_press: bool = false
var is_down_hold: bool = false
var is_down_release: bool = false
# Directional
var detected_input_direction: Vector2

## For checking events like mouse movement and scroll
func _input(incoming_event: InputEvent) -> void:
	self._handle_mouse_input(incoming_event)
	self._handle_scroll_events(incoming_event)

## For checking continuous events like holds in the UI
## Applies for things in the scene; for scene use _physics_process
func _process(delta: float) -> void:
	self._handle_ui_events(delta)

## For checking continuous events like holds in the scene
## Applies for things in the scene; for UI use _process
func _physics_process(delta: float) -> void:
	self._update_mouse_state()
	self._update_keyboard_state()
	self._handle_mouse_state(delta)
	self._handle_movement_state(delta)

func _handle_mouse_input(incoming_event: InputEvent) -> void:
	# When primary is pressed and there is mouse movement
	if incoming_event is InputEventMouseMotion and self.is_primary_hold:
		var v_motion: float = NodeUtil.get_vertical_look_amount(incoming_event)
		var h_motion: float = NodeUtil.get_horizontal_look_amount(incoming_event)
		self.primary_movement.emit(v_motion, h_motion)
	# When secondary is pressed and there is mouse movement
	if incoming_event is InputEventMouseMotion and self.secondary_hold:
		var v_motion: float = NodeUtil.get_vertical_aim_amount(incoming_event)
		var h_motion: float = NodeUtil.get_horizontal_aim_amount(incoming_event)
		self.secondary_movement.emit(v_motion, h_motion)
	# No actions held but movement
	if incoming_event is InputEventMouseMotion and self.is_no_action_input:
		var v_motion: float = NodeUtil.get_vertical_look_amount(incoming_event)
		var h_motion: float = NodeUtil.get_horizontal_look_amount(incoming_event)
		self.freelook_movement.emit(v_motion, h_motion)

func _handle_mouse_state(delta: float) -> void:
	# Logic on bools
	if self.is_primary_press:
		self.primary_action.emit()
	if self.is_primary_hold:
		self.primary_hold.emit(delta)
	if self.is_primary_release:
		self.primary_release.emit()
	if self.is_secondary_press:
		self.secondary_action.emit()
	if self.is_secondary_hold:
		self.secondary_hold.emit(delta)
	if self.is_secondary_release:
		self.secondary_release.emit()
	if self.is_duo_press:
		self.duo_action.emit();
	if self.is_duo_hold:
		self.duo_hold.emit(delta)
	if self.is_duo_release:
		self.duo_release.emit()

func _handle_ui_events(delta: float) -> void:
	if is_pause_press:
		self.pause_action.emit()
	if is_pause_hold:
		self.pause_hold.emit(delta)
	if is_pause_release:
		self.pause_release.emit()
	if is_tab_press:
		self.tab_action.emit()
	if is_tab_hold:
		self.tab_hold.emit(delta)
	if is_tab_release:
		self.tab_release.emit()

# Keeping this called from _input instead of _physics_process in case we want scroll amount from event
func _handle_scroll_events(incoming_event: InputEvent) -> void:
	if incoming_event.is_action_pressed(InputConfig.USER_INPUT.ROTATE_UP) || incoming_event.is_action_pressed(InputConfig.USER_INPUT.ROTATE_DOWN):
		var rotation_adjust: float = GameConfig.DEFAULTS.rotate_adjust
		if incoming_event.is_action_pressed(InputConfig.USER_INPUT.ROTATE_DOWN):
			rotation_adjust *= -1
		self.rotate.emit(Vector3(1, 0, 0), rotation_adjust)

# TODO Forward backward crouch
# TODO Then do directional signal replacing Input.get_vector(InputConfig.USER_INPUT.STRAFE_LEFT, InputConfig.USER_INPUT.STRAFE_RIGHT, InputConfig.USER_INPUT.FORWARD, InputConfig.USER_INPUT.BACKWARD)
func _handle_movement_state(delta: float) -> void:
	# Jump
	if self.is_jump_press:
		self.jump_action.emit()
	if self.is_jump_hold:
		self.jump_hold.emit(delta)
	if self.is_jump_release:
		self.jump_release.emit()
	# Crouch
	if self.is_crouch_press:
		self.crouch_action.emit()
	if self.is_crouch_hold:
		self.crouch_hold.emit(delta)
	if self.is_crouch_release:
		self.crouch_release.emit()
	# Sprint
	if self.is_sprint_press:
		self.sprint_action.emit()
	if self.is_sprint_hold:
		self.sprint_hold.emit(delta)
	if self.is_sprint_release:
		self.sprint_release.emit()
	# Left
	if self.is_left_press:
		self.left_action.emit()
	if self.is_left_hold:
		self.left_hold.emit(delta)
	if self.is_left_release:
		self.left_release.emit()
	if self.is_alt_left_press:
		self.alt_left_action.emit()
	if self.is_alt_left_hold:
		self.alt_left_hold.emit(delta)
	if self.is_alt_left_release:
		self.alt_left_release.emit()
	# Right
	if self.is_right_press:
		self.right_action.emit()
	if self.is_right_hold:
		self.right_hold.emit(delta)
	if self.is_right_release:
		self.right_release.emit()
	if self.is_alt_right_press:
		self.alt_right_action.emit()
	if self.is_alt_right_hold:
		self.alt_right_hold.emit(delta)
	if self.is_alt_right_release:
		self.alt_right_release.emit()
	# Up
	if self.is_up_press:
		self.up_action.emit()
	if self.is_up_hold:
		self.up_hold.emit(delta)
	if self.is_up_release:
		self.up_release.emit()
	# Down
	if self.is_down_press:
		self.down_action.emit()
	if self.is_down_hold:
		self.down_hold.emit(delta)
	if self.is_down_release:
		self.down_release.emit()
	# Directional (always emit; Users want to also know when know direction is input)
	self.input_direction.emit(self.detected_input_direction)

func _update_mouse_state() -> void:
	# Figure out what is pressed (maybe could get this to a state object)
	self.is_primary_press = Input.is_action_just_pressed(InputConfig.USER_INPUT.PRIMARY) and not Input.is_action_pressed(InputConfig.USER_INPUT.SECONDARY)
	self.is_primary_hold = not Input.is_action_pressed(InputConfig.USER_INPUT.SECONDARY) and Input.is_action_pressed(InputConfig.USER_INPUT.PRIMARY)
	self.is_primary_release = Input.is_action_just_released(InputConfig.USER_INPUT.PRIMARY) and not Input.is_action_pressed(InputConfig.USER_INPUT.SECONDARY)
	self.is_secondary_press = Input.is_action_just_pressed(InputConfig.USER_INPUT.SECONDARY) and not Input.is_action_pressed(InputConfig.USER_INPUT.PRIMARY)
	self.is_secondary_hold = Input.is_action_pressed(InputConfig.USER_INPUT.SECONDARY) and not Input.is_action_pressed(InputConfig.USER_INPUT.PRIMARY)
	self.is_secondary_release = Input.is_action_just_released(InputConfig.USER_INPUT.SECONDARY) and not Input.is_action_pressed(InputConfig.USER_INPUT.PRIMARY)
	self.is_duo_press = (Input.is_action_just_pressed(InputConfig.USER_INPUT.PRIMARY) and Input.is_action_pressed(InputConfig.USER_INPUT.SECONDARY)) || (Input.is_action_just_pressed(InputConfig.USER_INPUT.SECONDARY) and Input.is_action_pressed(InputConfig.USER_INPUT.PRIMARY)) || (Input.is_action_just_pressed(InputConfig.USER_INPUT.PRIMARY) and Input.is_action_just_pressed(InputConfig.USER_INPUT.SECONDARY))
	self.is_duo_hold = Input.is_action_pressed(InputConfig.USER_INPUT.SECONDARY) and Input.is_action_pressed(InputConfig.USER_INPUT.PRIMARY)
	self.is_duo_release = (Input.is_action_just_released(InputConfig.USER_INPUT.PRIMARY) and Input.is_action_just_released(InputConfig.USER_INPUT.SECONDARY)) || (Input.is_action_just_released(InputConfig.USER_INPUT.PRIMARY) and Input.is_action_pressed(InputConfig.USER_INPUT.SECONDARY)) || (Input.is_action_just_released(InputConfig.USER_INPUT.SECONDARY) and Input.is_action_pressed(InputConfig.USER_INPUT.PRIMARY))
	self.is_no_action_input = not Input.is_action_pressed(InputConfig.USER_INPUT.SECONDARY) and not Input.is_action_pressed(InputConfig.USER_INPUT.PRIMARY)

func _update_keyboard_state() -> void:
	# UI
	self.is_pause_press = Input.is_action_just_pressed(InputConfig.USER_INPUT.PAUSE)
	self.is_pause_hold = Input.is_action_pressed(InputConfig.USER_INPUT.PAUSE)
	self.is_pause_release = Input.is_action_just_released(InputConfig.USER_INPUT.PAUSE)
	self.is_tab_press = Input.is_action_just_pressed(InputConfig.USER_INPUT.SCORE)
	self.is_tab_hold = Input.is_action_pressed(InputConfig.USER_INPUT.SCORE)
	self.is_tab_release = Input.is_action_just_released(InputConfig.USER_INPUT.SCORE)
	# Character
	# Jump
	self.is_jump_press = Input.is_action_just_pressed(InputConfig.USER_INPUT.JUMP)
	self.is_jump_hold = Input.is_action_pressed(InputConfig.USER_INPUT.JUMP)
	self.is_jump_release = Input.is_action_just_released(InputConfig.USER_INPUT.JUMP)
	# Crouch
	self.is_crouch_press = Input.is_action_just_pressed(InputConfig.USER_INPUT.CROUCH)
	self.is_crouch_hold = Input.is_action_pressed(InputConfig.USER_INPUT.CROUCH)
	self.is_crouch_release = Input.is_action_just_released(InputConfig.USER_INPUT.CROUCH)
	# Sprint
	self.is_sprint_press = Input.is_action_just_pressed(InputConfig.USER_INPUT.SPRINT)
	self.is_sprint_hold = Input.is_action_pressed(InputConfig.USER_INPUT.SPRINT)
	self.is_sprint_release = Input.is_action_just_released(InputConfig.USER_INPUT.SPRINT)
	# Left
	self.is_left_press = Input.is_action_just_pressed(InputConfig.USER_INPUT.ROTATE_LEFT)
	self.is_left_hold = Input.is_action_pressed(InputConfig.USER_INPUT.ROTATE_LEFT)
	self.is_left_release = Input.is_action_just_released(InputConfig.USER_INPUT.ROTATE_LEFT)
	self.is_alt_left_press = Input.is_action_just_pressed(InputConfig.USER_INPUT.STRAFE_LEFT)
	self.is_alt_left_hold = Input.is_action_pressed(InputConfig.USER_INPUT.STRAFE_LEFT)
	self.is_alt_left_release = Input.is_action_just_released(InputConfig.USER_INPUT.STRAFE_LEFT)
	# Right
	self.is_right_press = Input.is_action_just_pressed(InputConfig.USER_INPUT.ROTATE_RIGHT)
	self.is_right_hold = Input.is_action_pressed(InputConfig.USER_INPUT.ROTATE_RIGHT)
	self.is_right_release = Input.is_action_just_released(InputConfig.USER_INPUT.ROTATE_RIGHT)
	self.is_alt_right_press = Input.is_action_just_pressed(InputConfig.USER_INPUT.STRAFE_RIGHT)
	self.is_alt_right_hold = Input.is_action_pressed(InputConfig.USER_INPUT.STRAFE_RIGHT)
	self.is_alt_right_release = Input.is_action_just_released(InputConfig.USER_INPUT.STRAFE_RIGHT)
	# Up
	self.is_up_press = Input.is_action_just_pressed(InputConfig.USER_INPUT.FORWARD)
	self.is_up_hold = Input.is_action_pressed(InputConfig.USER_INPUT.FORWARD)
	self.is_up_release = Input.is_action_just_released(InputConfig.USER_INPUT.FORWARD)
	# Down
	self.is_down_press = Input.is_action_just_pressed(InputConfig.USER_INPUT.BACKWARD)
	self.is_down_hold = Input.is_action_pressed(InputConfig.USER_INPUT.BACKWARD)
	self.is_down_release = Input.is_action_just_released(InputConfig.USER_INPUT.BACKWARD)
	# Directional
	self.detected_input_direction = Input.get_vector(InputConfig.USER_INPUT.STRAFE_LEFT, InputConfig.USER_INPUT.STRAFE_RIGHT, InputConfig.USER_INPUT.FORWARD, InputConfig.USER_INPUT.BACKWARD)
