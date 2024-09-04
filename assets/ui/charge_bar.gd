extends HBoxContainer
class_name ChargeBar

@onready var chargeAmount: Label = $ChargeAmount
@onready var progressBar: ProgressBar = $ChargeBarContainer/ChargeBackground/ProgressBar

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	progressBar.value = 0
	_updateVisuals()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_progress(value: float) -> void:
	progressBar.value = value
	_updateVisuals()

func _updateVisuals() -> void:
	chargeAmount.text = str(progressBar.value)
