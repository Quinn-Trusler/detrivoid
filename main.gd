extends Node2D

var doodad_scene = load("res://doodad.tscn") 
@export var DOODADMANAGER : Node2D

const TILE = Vector2(2,1)

var testing_tiles = [Vector2(7,13), Vector2(6,13), Vector2(7,13), Vector2(4,13), Vector2(4,14), Vector2(5,14), Vector2(5,13)]
var ind = 0 
var testing_removal_tiles = [Vector2(7,13), Vector2(6,13), Vector2(7,13), Vector2(4,13), Vector2(4,14), Vector2(5,14), Vector2(5,13)]
var ind2 = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("click"):
		#DOODADMANAGER.create_doodad("none", get_local_mouse_position())
		#if ind < len(testing_tiles):
			#add_tile(testing_tiles[ind])
			#ind += 1
		#elif ind2 < len(testing_removal_tiles):
			#add_tile(testing_removal_tiles[ind2], false)
			#ind2 += 1
		
		add_tile($TileMapLayer.local_to_map($TileMapLayer.get_local_mouse_position()))
	elif Input.is_action_just_pressed("right_click"):
		add_tile($TileMapLayer.local_to_map($TileMapLayer.get_local_mouse_position()), false)

func add_tile(pos, add = true):
	if add:
		$TileMapLayer.set_cell(pos,0,TILE)
	else: # Remove
		$TileMapLayer.set_cell(pos)
	$PolygonManager.update_tile(pos, 1)
	#$TileMap/PolyExample.edit_tile(pos, add)
