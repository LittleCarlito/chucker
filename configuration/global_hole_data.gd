extends Node

# TODO If this class causes things to run slowly it is internal usage of methods doing things like contains repeatedly (leading to super high n values on complex calls)
#			Fix by adding non checking methods to call that don't iterate through data storage but just assume existance is known before call

# TODO Simplify these
const _UNEXPECTED_NODE_VALUE: String = "Node value \"%s\" was %s than expected"
const _SEQUENTIAL_DEBUG_LOG: String = "Sequential order for hole \"%s\" is \"%s\""
const _HOLE_ALREADY_EXISTS: String = "Hole \"%s\" already exists in global data"
const _HOLE_NODE_ALREADY_EXISTS: String = "Hole %s already has node data for %s"
const _HOLE_NOT_FOUND: String = "Data for hole \"%s\" could not be found"
const _NODE_NOT_FOUND_FOR_HOLE: String = "Node \"%s\" not found for hole \"%s\""
const _INVALID_DATA_LOG: String = "Incoming %s data \"%s\" is not valid given the data already stored"
const _NO_EXISTING_NODES: String = "No existing nodes could be found for hole \"%s\""
const _NODE_DATA_DELETED: String = "Node number \"%s\" for hole \"%s\" has had their data deleted"
const _DELETING_COUNT_LOG: String = "Deleting all \"%s\" records from hole_data"
const _HOLE_NUMBER_STRING: String = "hole number %s"
const _HOLE_NODE_NOT_GIVEN_STRING: String = "Hole node not given or was equal to default value; Returning hole_data \"%s\" calculated value of %s"
const _BASE_CREATION_FAILURE: String = "Creation of base node failed; Data could not be added for hole \"%s\", node number \"%s\""
const _HOLE_NODE_NUMBER_STRING: String = "hole node number %s for %s"
const _NOT_ADDING_DATA: String = "Not adding data"
const _BASE_CREATION_ATTEMPT_STRING: String = "Attempting to create a base node for the hole"
const _NOT_BASE_CREATION_NODE: String = "Not node_number 1; Holes can only be started with node_number 1 assets"
const _CANNOT_INCREASE_RELOAD: String = "Cannot increase node numbers starting at \"%s\""
const _NO_NODE_AT_OR_GREATER: String = "No node of value \"%s\" or higher for hole \"%s\" could be found"
const _NO_HOLE_OR_GREATER: String = "No hole of value \"%s\" or higher could be found"
const _HOLE_DATA_ADD_FAIL: String = "Data for hole number %s can't be added; Data \"%s\""
const _NO_ACTION_RELOAD: String = "No %s and reload"
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

## Retruns if data storage has an entry for the hole number
func has_data_for(hole_number: int) -> bool:
	return hole_data.has(hole_number)

## Adds hole data using given HoleNodeData
## Does not change existing hole numbers
## Returns false if existing hole already exists or given HoleNodeData is not qualifying base node
func simple_add_hole_data(incoming_hole_number: int, incoming_data: HoleNodeData) -> bool:
	var data_added: bool = false
	if _verify_incoming_values(incoming_hole_number):
		if !hole_data.has(incoming_hole_number):
			if _is_base_node(incoming_data):
				if(_create_base_node(incoming_hole_number, incoming_data)):
					data_added = true
				else:
					var formatted_string: String = _BASE_CREATION_FAILURE + CONSTANTS.LOG_SEPARATOR + CONSTANTS.RETURNING_FALSE_LOG
					Logger.debug(formatted_string, [str(incoming_hole_number), str(incoming_data.node_number)], self)
			else:
				var formatted_string: String = _NOT_BASE_CREATION_NODE + CONSTANTS.LOG_SEPARATOR + CONSTANTS.RETURNING_FALSE_LOG
				Logger.debug(formatted_string, [str(incoming_data.node_number)], self)
		else:
			var formatted_string: String = _HOLE_ALREADY_EXISTS + CONSTANTS.LOG_SEPARATOR + _NOT_ADDING_DATA + CONSTANTS.LOG_SEPARATOR + CONSTANTS.RETURNING_FALSE_LOG
			Logger.debug(formatted_string, [str(incoming_hole_number)], self)
	return data_added

## Adds hole data using given HoleNodeData
## Increases existing hole numbers if existing conflict was found
## Returns false if given HoleNodeData is not qualifying base node
func dynamic_add_hole_data(incoming_hole_number:int, incoming_data: HoleNodeData) -> bool:
	var data_added: bool = false
	if _verify_incoming_values(incoming_hole_number):
		if hole_data.has(incoming_hole_number):
			_alter_hole_number(1, incoming_hole_number)
		if(simple_add_hole_data(incoming_hole_number, incoming_data)):
			data_added = true
		else:
			var formatted_string: String = _HOLE_DATA_ADD_FAIL + CONSTANTS.LOG_SEPARATOR + CONSTANTS.RETURNING_FALSE_LOG
			Logger.debug(formatted_string, [str(incoming_hole_number), str(incoming_data)], self)
	return data_added

## Removes hole data
## Does not update existing data after
## Returns Dictionary containing hole's Node data or empty dictionary if blank entry or not found (also a debug log if not found)
func simple_remove_hole_data(incoming_hole_number: int) -> Dictionary:
	var return_dictionary: Dictionary = {}
	if _contains_data(incoming_hole_number):
		return_dictionary = hole_data.get(incoming_hole_number)
		hole_data.erase(incoming_hole_number)
	else:
		var formatted_string: String = _HOLE_NOT_FOUND + CONSTANTS.LOG_SEPARATOR + _REMOVE_DATA_LOG
		Logger.deug(formatted_string, [incoming_hole_number], self)
	return return_dictionary

## Removes hole data and adjusts remaining holes to decrease number
## Returns Dictionary containing hole's Node data or empty dictionary if blank entry or not found (also a debug log if not found)
func dynamic_remove_hole_data(incoming_hole_number: int) -> Dictionary:
	# Make decisions off this variable as simple remove can return empty dictionary on not existing and blank entry
	var contains_data: bool = _contains_data(incoming_hole_number)
	var return_dictionary: Dictionary = simple_remove_hole_data(incoming_hole_number)
	if contains_data:
		_alter_hole_number(-1, incoming_hole_number)
	return return_dictionary

## Removes node data for the given hole
## Does not update data after
## Returns removed HoleNodeData or null if no data removed
func simple_remove_hole_node_data(hole_number: int, node_number: int) -> HoleNodeData:
	var found_data: HoleNodeData = null
	if _contains_data(hole_number, node_number):
		var existing_hole_data: Dictionary = hole_data.get(hole_number) as Dictionary
		found_data = existing_hole_data.get(node_number) as HoleNodeData
		existing_hole_data.erase(node_number)
		Logger.debug(_NODE_DATA_DELETED, [node_number, hole_number], self)
	else:
		var formatted_string: String = _HOLE_NOT_FOUND + CONSTANTS.OR_SEPARATOR + _NODE_NOT_FOUND_FOR_HOLE
		Logger.warn(formatted_string, [str(hole_number), str(node_number), str(hole_number)], self)
	return found_data

## Removes node data for the given hole and adjusts data after
func dynamic_remove_hole_node_data(hole_number:int, node_number:int) -> HoleNodeData:
	var found_data: HoleNodeData = simple_remove_hole_node_data(hole_number, node_number)
	if found_data != null:
		_alter_hole_node_number(-1, hole_number, node_number)
	return found_data

## Attempts to add the HoleNodeData for the requested hole into data storage
## If hole can't be found or conflicting node found returns false
func simple_add_node_data(hole_number: int, incoming_data: HoleNodeData) -> bool:
	var data_updated: bool = false
	if _verify_incoming_values(hole_number, incoming_data.node_number):
		if _contains_data(hole_number):
			if !_contains_data(hole_number, incoming_data.node_number):
				var existing_hole_data: Dictionary = hole_data.get(hole_data)
				existing_hole_data[incoming_data.node_number] = incoming_data
				data_updated = true
			else:
				var formatted_string: String = _HOLE_NODE_ALREADY_EXISTS + CONSTANTS.LOG_SEPARATOR + CONSTANTS.RETURNING_FALSE_LOG
				Logger.debug(formatted_string, [str(hole_number), str(incoming_data.node_number)], self)
		else:
			var base_creation_debug_log: String = _HOLE_NOT_FOUND + CONSTANTS.LOG_SEPARATOR + _BASE_CREATION_ATTEMPT_STRING
			Logger.debug(base_creation_debug_log, [str(hole_number)], self)
			if(_create_base_node(hole_number, incoming_data)):
				data_updated = true
			else:
				var formatted_string: String = _BASE_CREATION_FAILURE + CONSTANTS.LOG_SEPARATOR + CONSTANTS.RETURNING_FALSE_LOG
				Logger.debug(formatted_string, [str(hole_number), str(incoming_data.node_number)], self)
	return data_updated

# TODO Continuing from here for Data things
# TODO Refactor this method to use the simple one and be shorter
## Adds the data to data storage
## If node is conflicting with existing node will move nodes up by one and insert
func dyanmic_add_node_data(hole_number: int, incoming_hole_node_data: HoleNodeData) -> bool:
	var data_updated: bool = false
	if _verify_incoming_values(hole_number, incoming_hole_node_data.node_number):
		if _contains_data(hole_number):
			var existing_hole_data: Dictionary = hole_data.get(hole_number) as Dictionary
			var next_expected_node_number: int = get_next_node_number_for_hole(hole_number)
			# If there is an already existing node at the given node_number; Increase nodes at and after node_number by 1 and insert new record
			if existing_hole_data.has(incoming_hole_node_data.node_number):
				_alter_hole_node_number(1, hole_number, incoming_hole_node_data.node_number)
				existing_hole_data[incoming_hole_node_data.node_number] = incoming_hole_node_data
				data_updated = true
			# If no entry exists and the node number is expected number add it to data storage
			elif next_expected_node_number == incoming_hole_node_data.node_number:
				existing_hole_data[next_expected_node_number] = incoming_hole_node_data
				data_updated = true
			# If given node_number is greater than expected; Log it and store the data
			## This will lead to unused node_numbers unless careful in manual controlling
			elif incoming_hole_node_data.node_number > next_expected_node_number:
				Logger.debug(_UNEXPECTED_NODE_VALUE, [str(incoming_hole_node_data.node_number), CONSTANTS.HIGHER], self)
				existing_hole_data[next_expected_node_number] = incoming_hole_node_data
				data_updated = true
			# If given node_number is less than expected; Log it and store the data
			## This will lead to unused node_numbers unless careful in manual controlling
			else:
				Logger.debug(_UNEXPECTED_NODE_VALUE, [str(incoming_hole_node_data.node_number), CONSTANTS.LOWER], self)
				existing_hole_data[next_expected_node_number] = incoming_hole_node_data
		# If no hole data exists this is the first entry
		else:
			if(_create_base_node(hole_number, incoming_hole_node_data)):
				data_updated = true
			else:
				var formatted_string: String = _BASE_CREATION_FAILURE + CONSTANTS.LOG_SEPARATOR + CONSTANTS.RETURNING_FALSE_LOG
				Logger.debug(formatted_string, [str(hole_number), str(incoming_hole_node_data.node_number)], self)
	return data_updated

 ## Figure out the next sequential node number for the data store about the given hole number
func get_next_node_number_for_hole(hole_number: int) -> int:
	var return_node_number: int = 0
	if verify_and_contains_data(hole_number):
		var hole_node_data: Dictionary = hole_data.get(hole_number) as Dictionary
		var node_numbers: Array[int] = hole_node_data.keys()
		if !node_numbers.is_empty():
			node_numbers.sort()
			# TODO Change this to look at some config run level setting
			# TODO Refactor the sequential check to a publicly available method
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
			Logger.warn(formatted_string, [str(hole_number)], self)
	else:
		var formatted_string: String = _HOLE_NOT_FOUND + CONSTANTS.LOG_SEPARATOR + CONSTANTS.RETURNING_ZERO_LOG
		Logger.warn(formatted_string, [str(hole_number)], self)
	return return_node_number

## Verifies data is valid and that data storage has an entry for the requested values
func verify_and_contains_data(hole_number: int, hole_node_number: int = CONSTANTS.INT64_MAX) -> bool:
	var contains_valid_data: bool = true
	if _verify_incoming_values(hole_number, hole_node_number):
		if !_contains_data(hole_number, hole_node_number):
			contains_valid_data = false
	else:
		contains_valid_data = false
	return contains_valid_data

## Returns if data source contains data for incoming hole_number and hole_node_number if provided
func _contains_data(hole_number: int, hole_node_number:int = CONSTANTS.INT64_MAX) -> bool:
	var contains_data: bool = true
	if hole_data.has(hole_number):
		if hole_node_number != CONSTANTS.INT64_MAX:
			var existing_hole_data: Dictionary = hole_data.get(hole_number) as Dictionary
			if !existing_hole_data.has(hole_node_number):
				var formatted_string: String = _NODE_NOT_FOUND_FOR_HOLE + CONSTANTS.LOG_SEPARATOR + CONSTANTS.RETURNING_FALSE_LOG
				Logger.debug(formatted_string, [str(hole_node_number), str(hole_number)], self)
				contains_data = false
		else:
			Logger.debug(_HOLE_NODE_NOT_GIVEN_STRING, [str(hole_number), str(contains_data)], self)
	else:
		var formatted_string: String = _HOLE_NOT_FOUND + CONSTANTS.LOG_SEPARATOR + CONSTANTS.RETURNING_FALSE_LOG
		Logger.debug(formatted_string, [str(hole_number)], self)
		contains_data = false
	return contains_data

## Verifies incoming hole and node numbers don't violate data constraints
func _verify_incoming_values(incoming_hole_number: int, incoming_node_number: int = CONSTANTS.INT64_MAX) -> bool:
	var valid_parameters: bool = true
	if invalid_keys.has(incoming_hole_number):
		var hole_number_string: String = _HOLE_NUMBER_STRING % _HOLE_NUMBER_STRING
		Logger.warn(_INVALID_DATA_LOG, [incoming_hole_number, hole_number_string], self)
		valid_parameters = false
	if invalid_keys.has(incoming_node_number):
		var hole_number_string: String = _HOLE_NUMBER_STRING % _HOLE_NUMBER_STRING
		var hole_node_string: String = _HOLE_NODE_NUMBER_STRING % [incoming_node_number, hole_number_string]
		Logger.warn(_INVALID_DATA_LOG, [incoming_node_number, hole_node_string], self)
		valid_parameters = false
	return valid_parameters

## Determines if the passed in HoleNodeData can serve as a base node for a hole
func _is_base_node(incoming_data: HoleNodeData) -> bool:
	# First data entries for holes must always begin with node_number 1
	if incoming_data.node_number == 1:
		return true
	return false

## Creates the base entry for a new hole; Checking first if it is node_number 0 then making the entries in data storage
func _create_base_node(hole_number: int, incoming_data: HoleNodeData) -> bool:
	var node_added: bool = false
	if _is_base_node(incoming_data):
		# TODO Need to add a check to make sure hole_data doesn't already contain data at hole_node
		#		If non checking method type is needed for speed can be made later
		var hole_node_dictionary: Dictionary = {incoming_data.node_number: incoming_data}
		hole_data[hole_number] = hole_node_dictionary
		node_added = true
	else:
		var formatted_string: String = _NOT_BASE_CREATION_NODE + CONSTANTS.LOG_SEPARATOR + CONSTANTS.RETURNING_FALSE_LOG
		Logger.warn(formatted_string, [], self)
	return node_added

## Alters hole node numbers for the given hole by the alter value given
## If start_value given values starting from and greater than that value will be altered
func _alter_hole_node_number(alter_value:int, hole_number: int, start_value: int = 0) -> void:
	if _contains_data(hole_number):
		var existing_hole_data: Dictionary = hole_data.get(hole_data) as Dictionary
		var existing_node_numbers: Array[int] = existing_hole_data.keys()
		existing_node_numbers.sort()
		var resize_index: int
		if existing_node_numbers.has(start_value):
			resize_index = existing_node_numbers.find(start_value)
		else:
			resize_index = NodeUtil.get_nearest_greater_index(start_value, existing_node_numbers)
		if resize_index != CONSTANTS.INT64_MAX:
			existing_node_numbers = existing_node_numbers.slice(resize_index)
			var removed_data_array: Array[HoleNodeData] = []
			for node_number in existing_node_numbers:
				var removed_data: HoleNodeData = simple_remove_hole_node_data(hole_number, node_number)
				removed_data.node_number = removed_data.node_number + alter_value
				removed_data_array.append(removed_data)
			for updated_data_entry in removed_data_array:
				# TODO This might not work but hopefully this reference was updated by simple_remove calls above and now we are adding fresh records
				existing_hole_data[updated_data_entry.node_number] = updated_data_entry
			get_tree().call_group(CONSTANTS.TEE_BOX, CONSTANTS.INCREASE_NODE_NUMBER, hole_data, start_value)
		else:
			var formatted_string: String = _NO_NODE_AT_OR_GREATER + CONSTANTS.LOG_SEPARATOR + _NO_ACTION_RELOAD
			var action_type: String = CONSTANTS.INCREASE if alter_value > 0 else CONSTANTS.DECREASE
			Logger.debug(formatted_string, [str(start_value), str(hole_number), action_type], self)
	else:
		# TODO Refactor to be generic to alter_hole_node_number and not increase/decrease wording
		var formatted_string: String = _HOLE_NOT_FOUND + CONSTANTS.LOG_SEPARATOR + _CANNOT_INCREASE_RELOAD
		Logger.debug(formatted_string, [str(hole_number), str(start_value)], self)

## Alters hole number stored for each key in data storage by the value given
## If start_value given values starting from and greater than that value will be altered
func _alter_hole_number(alter_value: int, start_value: int = 0) -> void:
	var existing_values: Array[int] = hole_data.keys()
	existing_values.sort()
	var update_index_start: int
	if existing_values.has(start_value):
		update_index_start = existing_values.find(start_value)
	else:
		update_index_start = NodeUtil.get_nearest_greater_index(start_value, existing_values)
	if update_index_start != CONSTANTS.INT64_MAX:
		existing_values = existing_values.slice(update_index_start)
		var removed_hole_data: Dictionary = {}
		for existing_value in existing_values:
			var existing_hole_data: Dictionary = simple_remove_hole_data(existing_value)
			removed_hole_data[existing_value] = existing_hole_data
		for existing_hole in removed_hole_data.keys():
			hole_data[existing_hole + alter_value] = removed_hole_data.get(existing_hole)
		get_tree().call_group(CONSTANTS.TEE_BOX, CONSTANTS.INCREASE_HOLE_NUMBER, start_value)
	else:
		var formatted_string: String = _NO_HOLE_OR_GREATER + CONSTANTS.LOG_SEPARATOR + _CANNOT_INCREASE_RELOAD
		Logger.debug(formatted_string, [start_value], self)

# TODO Create sequential checking method

# TODO Create change to sequential method
#		Optional parameters to make holes sequential or node nodes sequential for given hole

## TODO Method to purge data storage and tell assets to re calculate and upload their course data
## If hole_number if provided; does it just for that specific hole otherwise reloads all course data
func reload_course_data(hole_number: int = CONSTANTS.INT64_MAX) -> void:
# TODO Call to TeeBox group to have them get all their children node to update their stats
#			TeeBox objects should then be aggregating those stats into their HoleData objects
#			That data should then be uploaded here to global hole data
	pass

## Clears all entries in data storage
func _clear_all_data() -> void:
	var hole_data_size: int = hole_data.size()
	Logger.debug(_DELETING_COUNT_LOG, [hole_data_size], self)
	hole_data.clear()
