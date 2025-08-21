extends PlayableCharacter
class_name ChuckChucker

var asset_data: AssetData

func _ready() -> void:
	super._ready()
	if self.asset_data == null:
		self.asset_data = AssetData.new(AssetData.TYPE.PLAYER)
	self.add_to_group(self.name)
	self.asset_data.group_name = self.name
	self.camera_container.add_to_group(self.name)
	self._update_state()

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	self._handle_interact_input()

func _input(event: InputEvent) -> void:
	super._input(event)
	self._handle_action_input(event)

func equip_item(new_item: Node3D) -> Variant:
	if new_item.has_signal(ThrowableItem.LAUNCHED):
		new_item.connect(ThrowableItem.LAUNCHED, release_action)
	# Chuck drops items if already equipping one
	var displaced_item: Variant = super.equip_item(new_item)
	if displaced_item != null && displaced_item is Node3D:
		AssetDelivery.drop_asset(displaced_item)
	_update_state()
	return

func _process(_delta: float) -> void:
	pass

func hold_primary_action() -> void:
	return

func hold_secondary_action() -> void:
	return

## Release action gets called on the items; This logic is what chuck does on release
func release_action() -> void:
	self.unequip_item()
	# Update the status of the character if the item took the camera with it
	self._update_state()
	# If the camera was released for the launch disable movement
	if asset_data.camera_state != AssetData.CAMERA_STATE.ACTIVE:
		self._just_output = true
		self.disable_movement()
		self.disable_rotation()

func get_group_name() -> String:
	return self.asset_data.group_name

func disable_camera() -> void:
	super.disable_camera()
	self._update_state()

func enable_camera() -> void:
	super.enable_camera()
	self._update_state()

func _update_state() -> void:
	asset_data.camera_state = AssetData.get_camera_state(camera_container)

func _handle_interact_input() -> void:
	if Input.is_action_just_pressed(InputConfig.USER_INPUT.INTERACT):
		self.equip_frontmost_object();

# Allows chuck to look around with right/left click combinations when not equipped
# TODO Push down into extending class called FreelookCharacter or somethign that extends Playable so this can be shared
func _handle_action_input(event: InputEvent) -> void:
	var only_secondary: bool = Input.is_action_pressed(InputConfig.USER_INPUT.SECONDARY) and not Input.is_action_pressed(InputConfig.USER_INPUT.PRIMARY)
	if self.is_unequipped():
		# Primary clicked
		if event.is_action_pressed(InputConfig.USER_INPUT.PRIMARY):
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		# Secondary clicked
		elif event.is_action_pressed(InputConfig.USER_INPUT.SECONDARY):
			self._handle_zoom_in()
		# Primary released
		elif event.is_action_released(InputConfig.USER_INPUT.PRIMARY):
			self.snap_back(self.global_rotation.z)
		# Secondary released
		elif event.is_action_released(InputConfig.USER_INPUT.SECONDARY):
			self._handle_zoom_out()
		# Secondary and primary pressed
		elif event.is_action_pressed(InputConfig.USER_INPUT.PRIMARY) and Input.is_action_pressed(InputConfig.USER_INPUT.SECONDARY):
			self._reset_camera_control()
		# When primary is pressed and there is mouse movement
		elif event is InputEventMouseMotion and (Input.is_action_pressed(InputConfig.USER_INPUT.PRIMARY)):
			## Determine amount to rotate camera
			var horizontal_rotate_amount: float = deg_to_rad(event.relative.x) * CameraConfig.get_horizontal_look_sens()
			self.horizontal_pan(horizontal_rotate_amount, self.global_position)
		# When secondary is pressed and there is mouse movement
		elif event is InputEventMouseMotion and only_secondary:
			var v_rotation_amount: float = NodeUtil.get_vertical_rotation_amount(event)
			var h_rotation_amount: float = NodeUtil.get_horizontal_rotation_amount(event)
			self.rotate_camera(v_rotation_amount, h_rotation_amount)
