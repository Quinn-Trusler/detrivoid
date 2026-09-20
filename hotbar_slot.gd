@tool
extends Button

@export var item_data : DoodadResource
var num_items : int = 0

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
		unset_item()
		
	$Outline.visible = false
	$Number.visible = false

func set_item(ID : String, num : int = 1):
	item_data = load("doodad/resources/" +str(ID) +".tres")
	$ItemIcon.texture = item_data.inventory_icon
	set_num_items(num)
	
func unset_item():
	$ItemIcon.texture = null
	$Number.visible = false

func add_items(num : int):
	set_num_items(num_items + num)
	
func set_num_items(num: int):
	num_items = num
	if num_items == 1:
		$Number.visible = false
	else:
		print("Setting string to visible")
		$Number.text = str(num_items)
		$Number.visible = true
	assert(num_items >= 0, "Negative number of items left: " + str(num_items))
	if num_items == 0:
		unset_item()

func select():
	$Outline.visible = true

func deselect():
	$Outline.visible = false
