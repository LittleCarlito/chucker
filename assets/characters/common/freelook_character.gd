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
	if is_unequipped():
		GlobalCursorController.request_captured(self, "Unequipped primary action")

func press_primary_secondary_action() -> void:
	_reset_camera_control()

func _handle_primary_movement(v_motion: float, h_motion: float) -> void:
	if is_unequipped():
		horizontal_pan(h_motion, global_position)

func release_primary_action() -> void:
	if is_unequipped():
		snap_back(global_rotation.z)

func press_secondary_action() -> void:
	if is_unequipped():
		_handle_zoom_in()

func _handle_secondary_movement(v_motion: float, h_motion: float) -> void:
	if is_unequipped():
		rotate_camera(v_motion, h_motion)

func release_secondary_action() -> void:
	if is_unequipped():
		_handle_zoom_out()
