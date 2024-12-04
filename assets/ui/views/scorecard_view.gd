extends Node3D
class_name ScorecardView

@onready var scorecardSprite: Sprite3D = $ScorecardSprite
@onready var scorecardControl: Control = $ScorecardViewport/ScorecardControl

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func set_pixel_size(pixelSize: float) -> void:
	scorecardSprite.pixel_size = pixelSize
