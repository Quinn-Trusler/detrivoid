extends Node2D

var doodad_scene = load("res://object.tscn") 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

const TILE = Vector2(2,1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("click"):
		var temp = doodad_scene.instantiate()
		add_child(temp)
		temp.position = get_local_mouse_position()
		add_tile(Vector2(16,9))
		add_tile(Vector2(7,13))
		add_tile(Vector2(6,13))
		add_tile(Vector2(5,13))
		add_tile(Vector2(4,13))
		add_tile(Vector2(4,14))
		add_tile(Vector2(5,14))
		
		add_tile(Vector2(5,14), false)
		add_tile(Vector2(4,14),false)
		add_tile(Vector2(4,13),false)
		add_tile(Vector2(21,13),false)
		add_tile(Vector2(21,14),false)
		add_tile(Vector2(21,15),false)
		add_tile(Vector2(20,15),false)
		add_tile(Vector2(19,15),false)
		add_tile(Vector2(18,15),false)
		add_tile(Vector2(17,15),false)
		add_tile(Vector2(17,14),false)
		add_tile(Vector2(17,13),false)
		add_tile(Vector2(18,13),false)
		add_tile(Vector2(19,13),false)
	

func add_tile(pos, add = true):
	if add:
		$TileMap.set_cell(pos,0,TILE)
	else: # Remove
		$TileMap.set_cell(pos)
	$TileMap/PolyExample.edit_tile(pos, add)
