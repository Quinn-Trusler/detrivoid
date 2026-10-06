class_name InventoryClass
extends CanvasLayer

signal equip(ID : String)
signal unequip()

var selected_index : int = -1
	
var inventory_data : InventoryData
var is_enabled : bool = false
@export var inventory_slots : Array[Button]


func set_inventory_data(inv_data : InventoryData):
	inventory_data = inv_data

func enable():
	is_enabled = true
	visible = true
	update_inventory()
	
func disable():
	visible = false
	is_enabled = false
	
func update_inventory():
	for slot_num in range(len(inventory_slots)):
		update_inventory_slot(slot_num)
		
func update_inventory_slot(slot_num):
	if slot_num < len(inventory_slots): 
		var old_id = inventory_slots[slot_num].get_item_id()
		var new_id = inventory_data.get_id(slot_num)
		var new_num = inventory_data.get_num(slot_num)
		inventory_slots[slot_num].set_item(new_id,new_num)

	
		if selected_index == slot_num:
			var is_empty = inventory_data.is_empty(slot_num)
			if is_empty and old_id:# Previously full and now empty
				unequip.emit()
			elif old_id != new_id: # ID has changed
				equip.emit(new_id)

# Sets ID and num at a slot number
func set_item_in_slot(ID : String, slot_num : int, num : int = 1):
	inventory_data.set_item_in_slot(ID, slot_num, num)
	update_inventory_slot(slot_num)
