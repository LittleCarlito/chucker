extends Control
class_name ChargeBar

@onready var chargeAmount: Label = $ChargeBarParentContainer/ChargeAmount
@onready var progressBar: ProgressBar = $ChargeBarParentContainer/ChargeBarContainer/ChargeBackground/ProgressBar

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	progressBar.value = 0
	_updateVisuals()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_progress(value: float) -> void:
	progressBar.value = int(value)
	_updateVisuals()
	

func _updateVisuals() -> void:
	chargeAmount.text = str(progressBar.value)
