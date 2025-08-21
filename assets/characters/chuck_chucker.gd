extends PlayableCharacter
class_name ChuckChucker

var asset_data: AssetData

# BUG Shift spring zoom out and release reset zoom no longer works
# TODO Get ChuckChucker, mesh, and collision into a scene as BaseCharacter
#		Then make another scene off that one with controls in the script and a camera at creation called ControllableCharacter

func _ready() -> void:
	super._ready()
	if self.asset_data == null:
		self.asset_data = AssetData.new(AssetData.TYPE.PLAYER)
	self.add_to_group(self.name)
	self.asset_data.group_name = self.name
	self.camera_container.add_to_group(self.name)
	self._update_state()

func equip_item(new_item:Node3D) -> Variant:
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

# TODO Should come up with something; Maybe an unequip check and then some default interaction like a wiggle
func hold_action(_delta: float) -> void:
	pass

## Handles group calls on release_action
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

# TODO Need to go through methods in and affecting this class and determine which need to have this method called after
#		Only should set enum state and not change enablement of movement or anything like that
func _update_state() -> void:
	asset_data.camera_state = AssetData.get_camera_state(camera_container)
