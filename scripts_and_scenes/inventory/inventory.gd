extends InventoryClass

const COLUMNS = 10
const HOTBARSIZE = 3

@onready var inventory_slot_scene = load("res://scripts_and_scenes/inventory/inventory_slot.tscn")


func setup():
	$GridContainer.columns = COLUMNS
	var num_slots = inventory_data.get_num_slots()
	for i in range(num_slots):
		print("Adding inventory slot number: ", i)
		var inventory_slot = inventory_slot_scene.instantiate()
		inventory_slots.append(inventory_slot)
		inventory_slot.slot_pressed.connect(_slot_pressed)
		inventory_slot.set_slot_num(i)
	for i in range(HOTBARSIZE, num_slots):
		$GridContainer.add_child(inventory_slots[i])
	for i in range(HOTBARSIZE):
		$GridContainer.add_child(inventory_slots[i])
		
func _slot_pressed(slot_num : int) -> void:
	select_slot(slot_num)


func select_slot(slot_num : int):
	if selected_index == slot_num: # Slot already selected
		inventory_slots[selected_index].deselect()
		selected_index = -1
	else:
		if selected_index != -1: # Deselect already selected
			inventory_slots[selected_index].deselect()
		selected_index = slot_num
		inventory_slots[selected_index].select()
