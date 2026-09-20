extends CanvasLayer

@export var hotbar_slots : Array[Button]
#@export var DoodadManager : Node2D
#@export var Player : CharacterBody2D

signal create_doodad_at_player(item_id : String, number : int)

#var selected_slot : Button
var selected_index : int = -1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# Either the worst or best code ever
	for i in range(len(hotbar_slots)):
		if Input.is_action_just_pressed(str(i+1)):
			select_slot(i)
	if Input.is_action_just_pressed("scroll_left"):
		select_slot(posmod(selected_index - 1 ,len(hotbar_slots)))
	elif Input.is_action_just_pressed("scroll_right"):
		select_slot(posmod(selected_index + 1 ,len(hotbar_slots)))
	
	if Input.is_action_just_pressed("drop_item"):
		drop_item_from_slot(selected_index, 1)
		
# Drops a certain number of items onto the ground
# -1 means drop all items in slot
func drop_item_from_slot(slot_num :int, num : int):
	print("drop item", slot_num)
	var slot = hotbar_slots[slot_num]
	if not slot.is_empty():
		print("slot not empty")
		if num == -1:
			num = slot.get_num_items()
		var item_id = slot.get_item_id()
		slot.add_items(-num)
		create_doodad_at_player.emit(item_id, num)
		
# Sets ID at a slot number
func add_item_to_slot(ID : String, slot_num : int, num : int = 1):
	hotbar_slots[slot_num].set_item(ID, num)

# Selects slot based on slot num
func select_slot(slot_num : int):
	if selected_index == slot_num: # Slot not already selected
		hotbar_slots[selected_index].deselect()
		print("Slot " + str(slot_num) + " deselected: ",selected_index)
		selected_index = -1
	else:
		if selected_index != -1: # Deselect already selected
			hotbar_slots[selected_index].deselect()
	
		selected_index = slot_num
		hotbar_slots[selected_index].select()
		print("Slot " + str(slot_num) + " selected: ",selected_index)
	
# Stacks item in hotbar or adds to leftmost available slot
func add_item(ID : String, num : int) -> void:
	print("add item")
	# Trys to find if item already in hotbar
	for slot in hotbar_slots:
		if slot.get_item_id() == ID:
			slot.add_items(num)
			
			print("add item")
			return
			
	# Add item to leftmost slot
	for slot in hotbar_slots:
		if slot.num_items == 0:
			slot.set_item(ID, num)
			print("set item", num)
			return
	assert(false, "Hotbar full, cannot add item")
		
	
	


func _on_hotbar_slot_0_pressed() -> void:
	select_slot(0)
func _on_hotbar_slot_1_pressed() -> void:
	select_slot(1)
func _on_hotbar_slot_2_pressed() -> void:
	select_slot(2)
