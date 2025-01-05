extends Node

var _override_data: ConfigFile

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group(GroupData.CONFIG_HANDLER)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _reload_data() -> void:
	_override_data = ConfigFileHandler.get_override_file()
