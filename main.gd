extends Node2D

var doodad_scene = load("res://object.tscn") 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("click"):
		var temp = doodad_scene.instantiate()
		add_child(temp)
		temp.position = get_local_mouse_position()
