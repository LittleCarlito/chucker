extends Control
class_name ChargeBar

@onready var charge_amount: Label = $ChargeBarParentContainer/ChargeAmount
@onready var progress_bar: ProgressBar = $ChargeBarParentContainer/ChargeBarContainer/ChargeBackground/ProgressBar

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	progress_bar.value = 0
	_updateVisuals()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func set_progress(value: float) -> void:
	progress_bar.value = int(value)
	_updateVisuals()
	

func _updateVisuals() -> void:
	charge_amount.text = str(progress_bar.value)
