extends FreelookCharacter
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

# Extended here to update state
func disable_camera() -> void:
	super.disable_camera()
	self._update_state()

# Extended here to update state
func enable_camera() -> void:
	super.enable_camera()
	self._update_state()

func _update_state() -> void:
	asset_data.camera_state = AssetData.get_camera_state(camera_container)

# Specific to chuck as each character type might want their own interaction type
func _handle_interact_input() -> void:
	if Input.is_action_just_pressed(InputConfig.USER_INPUT.INTERACT):
		self.equip_frontmost_object();
