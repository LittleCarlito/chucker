extends Control
class_name PauseMenu

signal close_menu

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed(USER_INPUT.MENU.MAIN) and self.visible:
		close_menu.emit()

func _on_close_menu() -> void:
	self.visible = false
	get_tree().paused = false

func _on_quit() -> void:
	get_tree().quit()
