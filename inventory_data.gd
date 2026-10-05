class_name InventoryData

enum D_Key {ID, NUM}

var item_slots : Dictionary = {} # slot_num{ D_Key.ID : ID,D_Key.NUM : num }
var max_items_cache : Dictionary = {} # item id : max number

func _init(size : int):
	for i in range(size):
		item_slots[i] = {D_Key.ID : "", D_Key.NUM : 0}


func get_id(slot_num : int) -> String:
	return item_slots[slot_num][D_Key.ID]
func get_num(slot_num : int) -> int:
	return item_slots[slot_num][D_Key.NUM] 
func is_empty(slot_num : int) -> bool:
	if item_slots[slot_num][D_Key.NUM]:
		return false
	return true
		
# Returns number of items dropped
func remove_items_from_slot(slot_num :int, num : int) -> int:
	
	if num == item_slots[slot_num][D_Key.NUM] or num == -1: # Remove all
		num = item_slots[slot_num][D_Key.NUM]
		set_slot_emtpy(slot_num)
	elif num > item_slots[slot_num][D_Key.NUM]:
		assert(false, "Trying to remove too many items from item slot")
	else:
		item_slots[slot_num][D_Key.NUM] -= num
		
	return num
		
			
func set_slot_emtpy(slot_num : int):
	item_slots[slot_num][D_Key.ID]  =  ""
	item_slots[slot_num][D_Key.NUM]  =  0

func set_item_in_slot(ID : String, slot_num : int, num : int = 1):
	item_slots[slot_num][D_Key.ID] = ID
	item_slots[slot_num][D_Key.NUM] = num
	
# Returns how many items where added to slot
func add_items_to_slot(ID : String, slot_num : int, num : int =1) -> int:
	var max_item_num = max_items_cache[ID]
	if item_slots[slot_num][D_Key.NUM] + num > max_item_num: # Not enough space to add all the items
		num = max_item_num - item_slots[slot_num][D_Key.NUM]

	item_slots[slot_num][D_Key.NUM] += num
	return num
	
func add_id_to_max_items_cache(ID : String):
	var item_data = load("res://resources/doodad/"+ ID + ".tres")
	max_items_cache[ID] = item_data.stack_size



# Stacks item in hotbar or adds to leftmost available slot
# Returns the slot the item was added to
func add_items(ID : String, num : int) -> int:
	# Trys to find if item already in hotbar
	for slot_num in item_slots:
		if item_slots[slot_num][D_Key.ID] == ID:
			item_slots[slot_num][D_Key.NUM] += num
			return slot_num
	# Add item to leftmost slot
	for slot_num in item_slots:
		if item_slots[slot_num][D_Key.NUM] == 0:
			set_item_in_slot(ID, slot_num, num)
			return slot_num
	return -1
		
