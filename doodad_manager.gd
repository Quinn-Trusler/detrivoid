extends Node2D

var doodad_scene = load("res://doodad.tscn")
var doodad_list = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
	
func create_doodad(doodad_name, pos):
	print("Create Doodad: ", doodad_name)
	var new_doodad = doodad_scene.instantiate()
	new_doodad.position = pos
	add_child(new_doodad)
	doodad_list.append(new_doodad)
