extends Node3D
class_name ChargeView

@onready var charge_control: ChargeBar = $ChargeView/ChargeControl
@onready var charge_sprite: Sprite3D = $ChargeSprite

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if float(charge_control.charge_amount.text) >= 0:
		charge_sprite.visible = true
	else:
		charge_sprite.visible = false

func set_progress(value: float) -> void:
	charge_control.set_progress(value)
