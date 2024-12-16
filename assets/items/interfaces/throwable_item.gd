extends EquipableItem
class_name ThrowableItem

# TODO This class is donezo it looks like; Resources replaced it
#var aim_node: Node3D = Node3D.new()
#var aim_control_node: Node3D = Node3D.new()
#var launch_control_node: Node3D = Node3D.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

# TODO Refactor this back into callers and make sure that Flight Data exists (at least speed)
#		Then use groups or signals to disable the owners movement
func launch_disk() -> void:
	pass
	#if launch_ready:
		#DiskFactory.create_and_launch(self)
	#else:
		#Logger.error(_NOT_LAUNCH_READY_LOG, [], self)
	#self.rotation.x = 0
	#aim_disabled = true
	#item_owner.disable_movement()
	#item_owner.disable_rotation()
	#item_owner.unequip_item()
