extends RigidBody2D

@export var data : DoodadResource 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if data:
		setup()
	pass
	
func setup(ID : String = "none"):
	if ID != "none":
		data = load("res://doodad/resources/"+ ID + ".tres")
	
	$Sprite2D.texture = data.texture
	physics_material_override.set_friction(data.friction)
	physics_material_override.set_bounce(data.bounce)
	mass = data.mass
	$CollisionShape2D.position = data.colision_shape_offset
	$CollisionShape2D.rotation = data.colision_shape_rotation
	$CollisionShape2D.shape = data.colision_shape
	
	$Timer.start()

	#print("Doodad created with value: ", doodad_data.health)

func get_id() -> String:
	return data.ID

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


# Decompose into tiles
# Place tiles
# delete self

func _on_timer_timeout() -> void:
	turn_to_dirt()
	
func turn_to_dirt() -> void:
	get_parent().place_dirt(position)
	queue_free()
