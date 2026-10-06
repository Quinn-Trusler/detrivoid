extends InventoryClass

signal create_doodad_at_player(item_id : String, number : int)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if is_enabled:
		# Either the worst or best code ever
		for i in range(len(inventory_slots)):
			if Input.is_action_just_pressed(str(i+1)):
				select_slot(i)
		if Input.is_action_just_pressed("scroll_left"):
			select_slot(posmod(selected_index - 1 ,len(inventory_slots)))
		elif Input.is_action_just_pressed("scroll_right"):
			select_slot(posmod(selected_index + 1 ,len(inventory_slots)))

		if Input.is_action_just_pressed("drop_item"):
			if selected_index != -1 and not inventory_data.is_empty(selected_index):
				drop_item_from_slot(selected_index, 1)		

# Drops a certain number of items onto the ground
# -1 means drop all items in slot
func drop_item_from_slot(slot_num :int, num : int):
	var ID = inventory_data.get_id(slot_num)
	var num_removed = inventory_data.remove_items_from_slot(slot_num, num)

	create_doodad_at_player.emit(ID, num_removed)
	update_inventory_slot(slot_num)
		
func select_slot(slot_num : int):
	if selected_index == slot_num: # Slot already selected
		inventory_slots[selected_index].deselect()
		unequip.emit()
		selected_index = -1
	else:
		if selected_index != -1: # Deselect already selected
			inventory_slots[selected_index].deselect()
		selected_index = slot_num
		inventory_slots[selected_index].select()
		if inventory_slots[selected_index].is_empty():
			unequip.emit()
		else:
			equip.emit(inventory_slots[selected_index].get_item_id())

func _on_hotbar_slot_0_pressed() -> void:
	select_slot(0)
func _on_hotbar_slot_1_pressed() -> void:
	select_slot(1)
func _on_hotbar_slot_2_pressed() -> void:
	select_slot(2)
