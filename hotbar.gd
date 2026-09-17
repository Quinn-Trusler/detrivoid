extends CanvasLayer

@export var hotbar_slots : Array[Button]

var selected_slot : Button

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func add_item_to_slot(ID : String, slot_num : int, num : int = 1):
	hotbar_slots[slot_num].set_item(ID, num)

func select_slot(slot_num : int):
	if selected_slot == hotbar_slots[slot_num]: # Slot not already selected
		selected_slot.deselect()
		print("Slot " + str(slot_num) + " deselected: ",selected_slot)
		selected_slot = null
	else:
		if selected_slot: # Deselect already selected
				selected_slot.deselect()
	
		selected_slot = hotbar_slots[slot_num]
		selected_slot.select()
		print("Slot " + str(slot_num) + " selected: ",selected_slot)
	

	


func _on_hotbar_slot_0_pressed() -> void:
	select_slot(0)
func _on_hotbar_slot_1_pressed() -> void:
	select_slot(1)
func _on_hotbar_slot_2_pressed() -> void:
	select_slot(2)
