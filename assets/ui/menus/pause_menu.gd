extends Control
class_name PauseMenu

var activated: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed(USER_INPUT.MENU.MAIN) and self.visible:
		if not activated:
			self.activated = true
		else :
			self._on_close_menu()
			self.activated = false

func _on_close_menu() -> void:
	if get_tree().paused:
		get_tree().paused = false
	self.activated = false
	self.visible = false

func _on_quit() -> void:
	get_tree().quit()
