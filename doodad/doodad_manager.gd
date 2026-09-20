extends Node2D

var doodad_scene = load("res://doodad/doodad.tscn")
var doodad_list = []
@export var TileLayer : TileMapLayer
@export var PolygonManager : Node2D

const DIRT_TILE = Vector2(0,0)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
	
func create_doodad(doodad_name, pos):
	print("Create Doodad: ", doodad_name)
	var new_doodad = doodad_scene.instantiate()
	new_doodad.setup(doodad_name)
	new_doodad.position = pos
	add_child(new_doodad)
	doodad_list.append(new_doodad)
	
func place_dirt(pos : Vector2i) -> void:
	var place_pos = TileLayer.local_to_map(pos)
	TileLayer.set_cell(place_pos,0,DIRT_TILE)
	PolygonManager.update_tile(place_pos, 0)
