extends Node2D

var doodad_scene = load("res://doodad.tscn") 
@export var DoodadManager : Node2D
@export var Hotbar : CanvasLayer
@export var Player : CharacterBody2D

const TILE = Vector2(0,0)

var testing_tiles = [Vector2(7,13), Vector2(6,13), Vector2(7,13), Vector2(4,13), Vector2(4,14), Vector2(5,14), Vector2(5,13)]
var ind = 0 
var testing_removal_tiles = [Vector2(7,13), Vector2(6,13), Vector2(7,13), Vector2(4,13), Vector2(4,14), Vector2(5,14), Vector2(5,13)]
var ind2 = 0

func _ready() -> void:
	Hotbar.add_item_to_slot("dead_body", 0, 1)
	Hotbar.add_item("dead_body", 5)
	Hotbar.add_item("dead_body", -2)
	Hotbar.add_item("bone", 5)
	
	Hotbar.create_doodad_at_player.connect(_create_doodad_at_player)
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("debug"):
		$Player.die()
		#DOODADMANAGER.create_doodad("none", get_local_mouse_position())
		#if ind < len(testing_tiles):
			#add_tile(testing_tiles[ind])
			#ind += 1
		#elif ind2 < len(testing_removal_tiles):
			#add_tile(testing_removal_tiles[ind2], false)
			#ind2 += 1
		
		#add_tile($TileMapLayer.local_to_map($TileMapLayer.get_local_mouse_position()))
	elif Input.is_action_just_pressed("right_click"):
		#add_tile($TileMapLayer.local_to_map($TileMapLayer.get_local_mouse_position()), false)
		DoodadManager.create_doodad("dead_body", get_local_mouse_position())
		
	#elif Input.is_action_just_pressed("")

func add_tile(pos, add = true):
	if add:
		$TileMapLayer.set_cell(pos,0,TILE)
	else: # Remove
		$TileMapLayer.set_cell(pos)
	$PolygonManager.update_tile(pos, 0)

func _create_doodad_at_player(item_id : String, number : int):
	for i in range(number):
		DoodadManager.create_doodad(item_id, Player.position)
