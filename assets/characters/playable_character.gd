extends LoadoutCharacter
class_name PlayableCharacter

# TODO OOOOO Disable movement and other movement stuff (that isn't input based) should be moved down to base_character

func _ready() -> void:
	super._ready()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	_handle_rotation_input()
	_handle_player_action(delta)
	_handle_player_interact()
	_handle_movement(delta)

func _input(event: InputEvent) -> void:
	_handle_view_input(event)
	_handle_horizontal_rotation_input(event)

## Extends equip item from loadout character to attempt to load camera into item
func equip_item(new_item: Node3D) -> Variant:
	self._give_camera(new_item)
	return super.equip_item(new_item)

# TODO Break out input logic from base logic; Have base logic moved to LoadoutCharacter and input logic here calling it
## Actions when disk is thrown
func _handle_player_action(delta: float) -> void:
	if item_container.is_equipped():
		if Input.is_action_pressed(InputConfig.USER_INPUT.PRIMARY):
			item_container.hold_action(delta, focusing_output)
		if Input.is_action_just_released(InputConfig.USER_INPUT.PRIMARY):
			item_container.release_action()

func _handle_view_input(event: InputEvent) -> void:
	var only_secondary: bool = Input.is_action_pressed(InputConfig.USER_INPUT.SECONDARY) and not Input.is_action_pressed(InputConfig.USER_INPUT.PRIMARY)
	# Only handle aiming mouse movements when not equipped
	if not is_equipped():
		# When secondary is pressed
		if event.is_action_pressed(InputConfig.USER_INPUT.SECONDARY):
			self._handle_zoom_in()
		elif event.is_action_pressed(InputConfig.USER_INPUT.PRIMARY) and Input.is_action_pressed(InputConfig.USER_INPUT.SECONDARY):
			self._reset_camera_control()
		# When secondary is released
		elif event.is_action_released(InputConfig.USER_INPUT.SECONDARY):
			self._handle_zoom_out()
		# When secondary is pressend and it is movement
		elif event is InputEventMouseMotion and only_secondary:
			var v_rotation_amount: float = NodeUtil.get_vertical_rotation_amount(event)
			var h_rotation_amount: float = NodeUtil.get_horizontal_rotation_amount(event)
			self.rotate_camera(v_rotation_amount, h_rotation_amount)
	# Third person viewing self
	# Only occurs when unequipped and primary is held
	if event.is_action_pressed(InputConfig.USER_INPUT.PRIMARY) and item_container.is_unequipped():
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif event is InputEventMouseMotion and (Input.is_action_pressed(InputConfig.USER_INPUT.PRIMARY) and item_container.is_unequipped()):
		## Determine amount to rotate camera
		var horizontal_rotate_amount: float = deg_to_rad(event.relative.x) * CameraConfig.get_horizontal_look_sens()
		self.horizontal_pan(horizontal_rotate_amount, self.global_position)
	elif event.is_action_released(InputConfig.USER_INPUT.PRIMARY) and item_container.is_unequipped():
		self.snap_back(self.global_rotation.z)

## Rotation
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
	_just_output = false
	self.set_camera(incoming_camera)

# TODO Break out interact logic from input logic; move interact to Loadout class keep input calling that here
#			That means moving the detection box from the front too
## Handle player pressing interact button
func _handle_player_interact() -> void:
	# Detect obejects in front of the character
	if Input.is_action_just_pressed(InputConfig.USER_INPUT.INTERACT) and front_detection.is_colliding():
		var colliding_count = front_detection.get_collision_count()
		for n in colliding_count:
			var colliding_object = front_detection.get_collider(0)
			if colliding_object != null and colliding_object is ForceDisk:
				AssetDelivery.create_and_give_item(self, colliding_object)

## Detects and executes movements
func _handle_movement(delta: float) -> void:
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

# TODO Break out input logic from rotation logic; rotation logic goes to Loadout class; input logic calls Loadout logic
#			Should have an implementation in base class but we don't ahve anything with a head that woudl "look" up, just a camera and thats not what this control is for
## Rotate input control
func _handle_horizontal_rotation_input(incoming_event: InputEvent) -> void:
	if incoming_event.is_action_pressed(InputConfig.USER_INPUT.ROTATE_UP) || incoming_event.is_action_pressed(InputConfig.USER_INPUT.ROTATE_DOWN):
		var rotation_adjust: float = GameConfig.DEFAULTS.rotate_adjust
		if incoming_event.is_action_pressed(InputConfig.USER_INPUT.ROTATE_DOWN):
			rotation_adjust *= -1
		self.item_container._handle_x_rotation(rotation_adjust)

func reload_project_settings() -> void:
	if not camera_container.reset_zoom():
		Logger.debug(Logger.NULL_CAMERA_LOG, [Logger.RESET_ZOOM], self)
