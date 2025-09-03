extends PlayableCharacter
class_name FreelookCharacter

func _ready() -> void:
	super._ready()
	GlobalInputController.connect(SIGNAL_NAME.PRIMARY_ACTION, press_primary_action)
	GlobalInputController.connect(SIGNAL_NAME.PRIMARY_RELEASE, release_primary_action)
	GlobalInputController.connect(SIGNAL_NAME.PRIMARY_MOTION, _handle_primary_movement)
	GlobalInputController.connect(SIGNAL_NAME.SECONDARY_ACTION, press_secondary_action)
	GlobalInputController.connect(SIGNAL_NAME.SECONDARY_RELEASE, release_secondary_action)
	GlobalInputController.connect(SIGNAL_NAME.SECONDARY_MOTION, _handle_secondary_movement)
	GlobalInputController.connect(SIGNAL_NAME.DUO_ACTION, press_primary_secondary_action)

func press_primary_action() -> void:
	if self.is_unequipped():
		pass
		# TODO change into call made to new GlobalCursorController
		#			Would think then what happens is going to be based off state of everything
		#				Like if the camera is focusing and has an integration etc.
		# Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func press_primary_secondary_action() -> void:
	self._reset_camera_control()

func _handle_primary_movement(v_motion: float, h_motion: float) -> void:
	if self.is_unequipped():
		self.horizontal_pan(h_motion, self.global_position)

func release_primary_action() -> void:
	if self.is_unequipped():
		self.snap_back(self.global_rotation.z)

func press_secondary_action() -> void:
	if self.is_unequipped():
		self._handle_zoom_in()

func _handle_secondary_movement(v_motion: float, h_motion: float) -> void:
	if self.is_unequipped():
		self.rotate_camera(v_motion, h_motion)

func release_secondary_action() -> void:
	if self.is_unequipped():
		self._handle_zoom_out()
