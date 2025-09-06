extends StateData
class_name InstanceState

var player_states: Dictionary
var item_states: Dictionary

# TODO Will need functions for updating states on players and items by id and state
#		Or just by transition forward or backward based of finite system (or setting based off nearest value)

func _init() -> void:
	self.player_states = {}
	self.item_states = {}

func get_state_data() -> Dictionary:
	var state_data = {}
	state_data[StateTypes.PLAYER_STATE] = self.player_states.duplicate(true)
	state_data[StateTypes.ITEM_STATE] = self.item_states.duplicate(true)
	return state_data

func duplicate() -> InstanceState:
	var new_state = InstanceState.new()
	for player_id in self.player_states.keys():
		new_state.player_states[player_id] = []
		for state in self.player_states[player_id]:
			new_state.player_states[player_id].append(state.duplicate())
	for item_id in self.item_states.keys():
		new_state.item_states[item_id] = []
		for state in self.item_states[item_id]:
			new_state.item_states[item_id].append(state.duplicate())
	return new_state
