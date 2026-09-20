@tool
extends RigidBody2D

@export var data : DoodadResource
@export var DecomposeTimer : Timer

var RNG = RandomNumberGenerator.new() 

var HIDDENDOODADLAYER = 4
var DOODADLAYER = 3
var PLAYERLAYER = 2


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not Engine.is_editor_hint():
		if data:
			setup(data.ID)
	
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
	
	set_collidable(data.collidable)
		
	if data.decomposable:
		DecomposeTimer.wait_time = RNG.randf_range(data.decompose_time.x, data.decompose_time.y)
		DecomposeTimer.start()

func set_collidable(value : bool) -> void:
	# Set layer doodad is on
	set_collision_layer_value(DOODADLAYER, value)
	set_collision_layer_value(HIDDENDOODADLAYER, !value)
	# Set layers that doodad can see
	set_collision_mask_value(PLAYERLAYER, value)
	set_collision_mask_value(DOODADLAYER, value)

func get_id() -> String:
	return data.ID

 #Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		if data:
			data = load("res://doodad/resources/"+ data.ID + ".tres")
			$Sprite2D.texture = data.texture
			physics_material_override.set_friction(data.friction)
			physics_material_override.set_bounce(data.bounce)
			mass = data.mass
			$CollisionShape2D.position = data.colision_shape_offset
			$CollisionShape2D.rotation = data.colision_shape_rotation
			$CollisionShape2D.shape = data.colision_shape
			


# Decompose into tiles
# Place tiles
# delete self

func _on_timer_timeout() -> void:
	if not Engine.is_editor_hint():
		turn_to_dirt()
	
func turn_to_dirt() -> void:
	get_parent().place_dirt(position)
	queue_free()
