extends Node3D

@onready var chuckChucker: ChuckChucker = $ChuckChucker

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _disable_character_movement() -> void:
	chuckChucker.disableMovement = true	

func _enable_character_movement() -> void:
	chuckChucker.disableMovement = false
