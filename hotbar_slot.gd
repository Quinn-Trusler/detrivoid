extends Button

var item_data : DoodadResource
var num_items : int

## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Outline.visible = false

func set_item(ID : String, num : int = 1):
	item_data = load("doodad/resources/" +str(ID) +".tres")
	$ItemIcon.texture = item_data.inventory_icon
	num_items = num

func select():
	$Outline.visible = true

func deselect():
	$Outline.visible = false
