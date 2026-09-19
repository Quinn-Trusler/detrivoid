extends CanvasLayer

@export var hotbar_slots : Array[Button]

#var selected_slot : Button
var selected_index : int = -1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Either the worst or best code ever
	for i in range(len(hotbar_slots)):
		if Input.is_action_just_pressed(str(i+1)):
			select_slot(i)
	if Input.is_action_just_pressed("scroll_left"):
		print("scroll left")
		select_slot(posmod(selected_index - 1 ,len(hotbar_slots)))
		#selected_index -= 1
		#if selected_index < 0: # Wrap around to the right
			#selected_index = len(hotbar_slots) -1
	elif Input.is_action_just_pressed("scroll_right"):
		print("scroll right")
		select_slot(posmod(selected_index + 1 ,len(hotbar_slots)))
		#selected_index += 1
		#if selected_index >= len(hotbar_slots):
			#selected_index = 0

func add_item_to_slot(ID : String, slot_num : int, num : int = 1):
	hotbar_slots[slot_num].set_item(ID, num)

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
	

	


func _on_hotbar_slot_0_pressed() -> void:
	select_slot(0)
func _on_hotbar_slot_1_pressed() -> void:
	select_slot(1)
func _on_hotbar_slot_2_pressed() -> void:
	select_slot(2)
