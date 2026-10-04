@tool
extends Sprite2D

@export var item_data : DoodadResource
var tool_data

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not Engine.is_editor_hint():
		visible = false


func equip(ID) -> void:
	visible = true
	item_data = load("res://resources/doodad/"+ ID + ".tres")
	assert(item_data.ID == ID, "Filename and it's ID do not match")
	apply_item_data()
	
func unequip() -> void:
	visible = false
	unapply_item_data()

func unapply_item_data() -> void:
	item_data = null
	tool_data = null

func apply_item_data() -> void:
	if item_data.held_texture:
		texture = item_data.held_texture
	else:
		texture = item_data.texture
	position = item_data.hold_position
	tool_data = item_data.tool

func _process(_delta: float) -> void:
	if Engine.is_editor_hint() and item_data:
		apply_item_data()
		
		
func can_scavenge() -> bool:
	return (tool_data and tool_data.scavenge_power > 0)
func get_scavenge_power():
	if tool_data:
		return tool_data.scavenge_power
	return -1
