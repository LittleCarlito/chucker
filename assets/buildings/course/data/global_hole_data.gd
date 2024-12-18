extends Node

const _SEQUENTIAL_DEBUG_LOG: String = "Sequential order for hole \"%s\" is \"%s\""
const _HOLE_ALREADY_EXISTS: String = "Hole \"%s\" already exists in global data"
const _HOLE_NOT_FOUND: String = "Data for hole \"%s\" could not be found"
const _INVALID_DATA_LOG: String = "Incoming %s data \"%s\" is not valid given the data already stored"
const _NO_EXISTING_NODES: String = "No existing nodes could be found for hole \"%s\""
const _REMOVE_DATA_LOG: String = "Cannot remove data"
const _ADD_NODE_DATA: String = "add_node_data"
const _HOLE_NODE_DATA: String = "HoleNodeData"
const _HOLE_DATA: String = "HoleData"
const _SEQUENTIAL_ORDER: String = "sequential_order"

## With the logic hopefully acts as a set for hole data
## Dictionary of dictionaries
## First key is hole number, key for next dictionary is node number
var hole_data: Dictionary = {}
var invalid_keys: Dictionary = {0: CONSTANTS.BLOCKING_VALUE, null: CONSTANTS.BLOCKING_VALUE}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

## Sets hole data; incoming_data should contain
#func set_hole_data(incoming_data: HoleNodeData) -> void:
	#var incoming_hole_number: int = incoming_data.get_hole_number()
	#if !invalid_keys.has(incoming_hole_number) && !has_data_for(incoming_hole_number):
		#if _can_add_hole_node_data(incoming_data):
			#var new_hole_entry: Dictionary = {incoming_data.node_number: incoming_data}
			#hole_data.get_or_add(incoming_hole_number, new_hole_entry)
		#else:
			#Logger.warn(_INVALID_DATA_LOG, [_HOLE_NODE_DATA, str(incoming_data)], self)
	#else:
		#Logger.warn(_HOLE_ALREADY_EXISTS, [incoming_hole_number], self)

# TODO Method to add hole node to existing data
#		Need to make sure hole data exists
#		Need to check node number and make sure they sequentially make sense for stored data
#			Should make a method for that in this class

func remove_hole_data(incoming_hole_number: int) -> void:
	if !invalid_keys.has(incoming_hole_number) && has_data_for(incoming_hole_number):
		hole_data.erase(incoming_hole_number)
	else:
		var formattedString: String = _HOLE_NOT_FOUND + CONSTANTS.LOG_SEPARATOR + _REMOVE_DATA_LOG
		Logger.warn(formattedString, [incoming_hole_number], self)

func has_data_for(hole_number: int) -> bool:
	return hole_data.has(hole_number)

 ## Figure out the next sequential node number for the data store about the given hole number
func get_next_node_number_for_hole(hole_number: int) -> int:
	var return_node_number: int = 0
	if !invalid_keys.has(hole_number) && hole_data.has(hole_number):
		var hole_node_data: Dictionary = hole_data.get(hole_number) as Dictionary
		var node_numbers: Array[int] = hole_node_data.keys()
		if !node_numbers.is_empty():
			node_numbers.sort()
			# TODO Change this to look at some config run level setting
			## Debug only method
			if Logger.log_level == Logger.LEVEL.DEBUG:
				var sequential_order: bool = true
				var node_count: int = node_numbers.size()
				for i in node_count:
					if i != node_numbers[i]:
						sequential_order = false
				Logger.debug(_SEQUENTIAL_DEBUG_LOG, [str(hole_number), str(sequential_order)], self)
			# Get the next sequential node value for the requested hole
			return_node_number = node_numbers[node_numbers.size() - 1] + 1
		else:
			var formatted_string: String  = _NO_EXISTING_NODES + CONSTANTS.LOG_SEPARATOR + CONSTANTS.RETURNING_ZERO_LOG
	else:
		var formatted_string: String = _HOLE_NOT_FOUND + CONSTANTS.LOG_SEPARATOR + CONSTANTS.RETURNING_ZERO_LOG
		Logger.warn(formatted_string, [str(hole_number)], self)
	return return_node_number

# TODO Refactor this to just be adding to the data
# TODO Get rid of the other set method
func add_node_data(incoming_hole_node_data: HoleNodeData) -> void:
	if incoming_hole_node_data.hole_data != null:
		var incoming_hole_num: int = incoming_hole_node_data.hole_data.hole_number
		if !invalid_keys.has(incoming_hole_node_data) && hole_data.has(incoming_hole_num):
			var expecting_hole_data: Dictionary = hole_data.get(incoming_hole_num) as Dictionary
			var next_expected_node_number: int = get_next_node_number_for_hole(incoming_hole_num)
			if expecting_hole_data.has(incoming_hole_node_data.node_number):
				# TODO Need to get existing entry out of the dictionary and replace it with the incoming HoleNodeData
				# TODO Then need to put the popped entry at the en of the holes data dictionary with the next_exted_node_number as its node_number
				pass
			elif next_expected_node_number == incoming_hole_node_data.node_number:
				expecting_hole_data[next_expected_node_number] = incoming_hole_node_data
			elif incoming_hole_node_data.node_number > next_expected_node_number:
				# TODO Log debug that given node number was higher than expected value
				expecting_hole_data[next_expected_node_number] = incoming_hole_node_data
			else:
				# TODO Log debug that given node number was lower than expected value
				expecting_hole_data[next_expected_node_number] = incoming_hole_node_data
			# TODO BIGGEST CONTINUE FROM HERE: get_or_add isn't what you think; Need to swap to dictionary[key] = value notation
			# TODO Verify that the node number is the next sequential node for the hole
			# TODO If next sequential add it
			# TODO Add group method call to node that gets poped out and moved for incoming data
			pass
		else:
			# TODO If no data exists verify this is saying its the first node otherwise log saying thats why its false
			pass
	else:
		var formattedString: String = CONSTANTS.NULL_LOG + CONSTANTS.LOG_SEPARATOR + CONSTANTS.METHOD_LOG
		Logger.warn(formattedString, [_HOLE_DATA, _ADD_NODE_DATA, CONSTANTS.RETURNING_FALSE_LOG], self)
