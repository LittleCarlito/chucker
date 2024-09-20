extends Node3D

@onready var chargeControl: ChargeBar = $ChargeView/ChargeControl
@onready var chargeSprite: Sprite3D = $ChargeSprite

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if float(chargeControl.chargeAmount.text) >= 0:
		chargeSprite.visible = true
	else:
		chargeSprite.visible = false
