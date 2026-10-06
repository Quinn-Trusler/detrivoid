@tool
extends Button

@export var item_data : DoodadResource
@export var num_items : int = 0
@export var slot_number : int

signal slot_pressed(slot_number : int)

func _process(_delta: float) -> void:
	if Engine.is_editor_hint() and item_data:
		$ItemIcon.texture = item_data.inventory_icon
		set_num_items(1)

# True if hotbar slot is empty
func is_empty() -> bool:
	if (num_items <= 0):
		return true
	else:
		return false
	
func set_slot_num(num) -> void:
	slot_number = num
	
func get_num_items() -> int:
	return num_items

func get_item_id() -> String:
	if item_data:
		return item_data.ID
	else:
		return "none"

## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not Engine.is_editor_hint():# Get rid of whatever is left over in editor
		item_data = null
		_unset_item()
		
	$Outline.visible = false
	$Number.visible = false

func set_item(ID : String, num : int = 1):
	set_num_items(num)
	if num > 0:
		# if new id
		if not (item_data and item_data.ID == ID):
			item_data = load("resources/doodad/" +str(ID) +".tres")
			assert(item_data.ID == ID, "Filename and it's ID do not match: " + ID)
			$ItemIcon.texture = item_data.inventory_icon
	
func _unset_item():
	item_data = null
	$ItemIcon.texture = null
	$Number.visible = false

func add_items(num : int):
	set_num_items(num_items + num)
	
func set_num_items(num: int):
	num_items = num
	if num_items == 1:
		$Number.visible = false
	else:
		$Number.text = str(num_items)
		$Number.visible = true
	assert(num_items >= 0, "Negative number of items left: " + str(num_items))
	if num_items == 0:
		_unset_item()

func select():
	$Outline.visible = true

func deselect():
	$Outline.visible = false


func _on_pressed() -> void:
	slot_pressed.emit(slot_number)
