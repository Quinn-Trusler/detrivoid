@tool
extends Sprite2D

@export var item_data : DoodadResource

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not Engine.is_editor_hint():
		visible = false


func equip(ID) -> void:
	visible = true
	item_data = load("res://doodad/resources/"+ ID + ".tres")
	apply_item_data()
	
func unequip() -> void:
	visible = false
	

func apply_item_data():
	if item_data.held_texture:
		texture = item_data.held_texture
	else:
		texture = item_data.texture

func _process(_delta: float) -> void:
	if Engine.is_editor_hint() and item_data:
		apply_item_data()
