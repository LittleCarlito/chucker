class_name PullData

var primary_pull: float
var secondary_pull: float

func _init(incoming_primary: float = 0, incoming_secondary: float = 0) -> void:
	self.primary_pull = incoming_primary
	self.secondary_pull = incoming_secondary
