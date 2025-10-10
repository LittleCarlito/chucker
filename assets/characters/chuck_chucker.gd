extends FreelookCharacter
class_name ChuckChucker

@export var asset_data: AssetData

func _ready() -> void:
	super._ready()
	if asset_data == null:
		asset_data = AssetData.new(AssetData.TYPE.PLAYER)
	add_to_group(name)
	asset_data.group_name = name
	camera_container.add_to_group(name)
	item_container.connect(SIGNAL_NAME.ZOOM_IN, _handle_zoom_in)
	item_container.connect(SIGNAL_NAME.ZOOM_OUT, _handle_zoom_out)
	item_container.connect(SIGNAL_NAME.TURN_HORIZONTAL, _handle_item_rotation_signal)

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	_handle_interact_input()

func equip_item(new_item: Node3D) -> Variant:
	if new_item.has_signal(ThrowableItem.LAUNCHED):
		new_item.connect(ThrowableItem.LAUNCHED, release_action)
	# Chuck drops items if already equipping one
	var displaced_item: Variant = super.equip_item(new_item)
	if displaced_item != null && displaced_item is Node3D:
		AssetDelivery.drop_asset(displaced_item)
	return

func _process(_delta: float) -> void:
	pass

## Release action gets called on the items; This logic is what chuck does on release
func release_action() -> void:
	unequip_item()
	# Update the status of the character if the item took the camera with it
	# If the camera was released for the launch disable movement
	just_output = true
	disable_movement()
	disable_rotation()

func get_group_name() -> String:
	return asset_data.group_name

# Extended here to update state
func disable_camera() -> void:
	super.disable_camera()

# Extended here to update state
func enable_camera() -> void:
	super.enable_camera()

# Specific to chuck as each character type might want their own interaction type
func _handle_interact_input() -> void:
	if Input.is_action_just_pressed(InputConfig.USER_INPUT.INTERACT):
		equip_frontmost_object();

func _handle_item_rotation_signal(incoming_rotation: float) -> void:
	if is_unequipped():
		_handle_horizontal_rotation(incoming_rotation)
