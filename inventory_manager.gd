extends Node2D

@export var Hotbar : CanvasLayer
@export var Inventory : CanvasLayer


var inventory_data := InventoryData.new(30)
var is_enabled = false

var inventory_open : bool = false
func _ready() -> void:
	Inventory.set_inventory_data(inventory_data)
	Hotbar.set_inventory_data(inventory_data)
	Hotbar.enable()
	Inventory.setup()
	
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("open_inventory"):
		if inventory_open:
			close_inventory()
		else:
			open_inventory()
		

func close_inventory():
	inventory_open = false
	Inventory.disable()
	Hotbar.enable()
	
func open_inventory():
	inventory_open = true
	print("Open Inventory")
	Inventory.enable()
	Hotbar.disable()
	
	

# Stacks item in hotbar or adds to leftmost available slot
func add_items(ID : String, num : int) -> void:
	var slot_num = inventory_data.add_items(ID, num)
	if slot_num == -1:
		assert(false, "Inventory full, cannot add item")
	else:
		update_inventory_slot(slot_num)
		
func update_inventory_slot(slot_num):
	if Hotbar.is_enabled:
		Hotbar.update_inventory_slot(slot_num)
	if Inventory.is_enabled:
		Inventory.update_inventory_slot(slot_num)


func get_inventory_data() -> InventoryData:
	return inventory_data

func show_inventory():
	Inventory.visible = true
	Inventory.enable()
	
func hide_inventory():
	Inventory.visible = false
	Inventory.disable()
	
func show_hotbar():
	Hotbar.visible = true
	Hotbar.enable()
	
func hide_hotbar():
	Hotbar.visible = false
	Hotbar.disable()
