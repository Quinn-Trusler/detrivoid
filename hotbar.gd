extends CanvasLayer

@export var hotbar_slots : Array[Button]
#@export var DoodadManager : Node2D
#@export var Player : CharacterBody2D

signal create_doodad_at_player(item_id : String, number : int)
signal equip(ID : String)
signal unequip()

#var selected_slot : Button
var selected_index : int = -1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	
var inventory_data := InventoryData.new(3)

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
		if selected_index != -1 and not inventory_data.is_empty(selected_index):
			drop_item_from_slot(selected_index, 1)
		
# Drops a certain number of items onto the ground
# -1 means drop all items in slot
func drop_item_from_slot(slot_num :int, num : int):
	var ID = inventory_data.get_id(slot_num)
	var num_removed = inventory_data.remove_items_from_slot(slot_num, num)

	print("Dropping the following ID: " + ID)
	create_doodad_at_player.emit(ID, num_removed)
	update_hotbar_slot(slot_num)
	
	# Unequip item if none left in slot
	if slot_num == selected_index and inventory_data.is_empty(slot_num):
		unequip.emit()
		
# Sets ID and num at a slot number
func set_item_in_slot(ID : String, slot_num : int, num : int = 1):
	inventory_data.set_item_in_slot(ID, slot_num, num)
	update_hotbar_slot(slot_num)
	equip.emit(ID)


# Stacks item in hotbar or adds to leftmost available slot
func add_items(ID : String, num : int) -> void:
	var slot_num = inventory_data.add_items(ID, num)
	
	if slot_num == -1:
		assert(false, "Hotbar full, cannot add item")
	else:
		update_hotbar_slot(slot_num)
		if selected_index == slot_num: # Add check to see if previously empty
			equip.emit(ID)

func update_hotbar_slot(slot_num):
	hotbar_slots[slot_num].set_item(inventory_data.get_id(slot_num),inventory_data.get_num(slot_num))

func select_slot(slot_num : int):
	if selected_index == slot_num: # Slot already selected
		hotbar_slots[selected_index].deselect()
		unequip.emit()
		selected_index = -1
	else:
		if selected_index != -1: # Deselect already selected
			hotbar_slots[selected_index].deselect()
		selected_index = slot_num
		hotbar_slots[selected_index].select()
		if hotbar_slots[selected_index].is_empty():
			unequip.emit()
		else:
			equip.emit(hotbar_slots[selected_index].get_item_id())
	



		
	
	


func _on_hotbar_slot_0_pressed() -> void:
	select_slot(0)
func _on_hotbar_slot_1_pressed() -> void:
	select_slot(1)
func _on_hotbar_slot_2_pressed() -> void:
	select_slot(2)
