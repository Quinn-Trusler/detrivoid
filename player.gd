extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var starting_health = 100
var health = 0

@export var SpawnPoint : Node2D
@export var Camera : Camera2D
@export var HeldItem : Sprite2D

@onready var tween = get_tree().create_tween()



signal create_doodad_at_player(item_id : String, number : int)


func _ready() -> void:
	tween.pause()

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	
	
	for i in get_slide_collision_count():
		var c = get_slide_collision(i)
		if c.get_collider() is RigidBody2D:
			c.get_collider().apply_central_impulse(-c.get_normal() * 100)

func _process(delta: float) -> void:
	if not tween.is_running():
		Camera.position = position 

func take_damage(dmg : float):
	health -= dmg
	if health <= 0:
		die()
func die():
	create_doodad_at_player.emit("dead_body")
	position = SpawnPoint.position
	var tween_time = 1
	tween.tween_property(Camera, "position", SpawnPoint.position, tween_time)
	tween.play()
	await get_tree().create_timer(tween_time).timeout
	
	
func equip(ID : String) -> void:
	print("equip part 1")
	HeldItem.equip(ID)
func unequip() -> void:
	print("unequip")
	HeldItem.unequip()
