extends Node3D
class_name ScorecardView

@onready var scorecard_sprite: Sprite3D = $ScorecardSprite

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func set_pixel_size(pixel_size: float) -> void:
	scorecard_sprite.pixel_size = pixel_size
