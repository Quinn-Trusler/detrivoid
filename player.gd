extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var starting_health : int = 100

@export var SpawnPoint : Node2D
@export var Camera : Camera2D
@export var HeldItem : Sprite2D

@onready var tween = get_tree().create_tween()

enum Action {NONE, SCAVENGE}

signal create_doodad_at_player(item_id : String, number : int)
signal add_item_to_inventory(item_id : String, number : int)

# Subject to change
var health : int = 0
var current_action : Action = Action.NONE
var scavenge_doodad = null


func _ready() -> void:
	tween.pause()

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var direction := Input.get_axis("move_left", "move_right")
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
		
	if Input.is_action_just_pressed("pickup_item"):
		pickup_doodad()
		
	if current_action == Action.NONE:
		if Input.is_action_pressed("scavenge"):
			start_scavenge()
				
	if Input.is_action_just_released("scavenge") and current_action == Action.SCAVENGE:
		cancel_scavenge()
		
		

func take_damage(dmg : float):
	health -= dmg
	if health <= 0:
		die()
func die():
	#tween.kill()
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

func pickup_doodad():
	var doodad_id = $ItemArea.pickup_doodad()
	if doodad_id:
		add_item_to_inventory.emit(doodad_id, 1)
	else:
		print("No Doodad pickup up") # Add sound to play here in future

func _on_action_timer_timeout() -> void:
	if current_action == Action.NONE:
		assert(false, "Action timer should never end on none")
	elif current_action == Action.SCAVENGE:
		finish_scavenge()
	$ActionTimer.stop()
	current_action = Action.NONE
	
func start_scavenge() -> void:
	print("start scavenge")
	if HeldItem.can_scavenge():
		scavenge_doodad = $ScavengeArea.get_doodad_in_scavenge_area()
		if scavenge_doodad:
			$ActionTimer.wait_time = scavenge_doodad.get_scavenge_time() / HeldItem.get_scavenge_power()
			$ActionTimer.start()
			current_action = Action.SCAVENGE
			print("Scavenging " + scavenge_doodad.get_id() + " with " + str($ActionTimer.time_left) + " untill completion")
	else:
		print("The item you are holding cannot be used to scavenge")
		
func cancel_scavenge() -> void:
	$ActionTimer.stop()
	print("Scavenging of " + scavenge_doodad.get_id() + "Canceled")
	scavenge_doodad = null
	current_action = Action.NONE
	
func finish_scavenge() -> void:
	var items : Dictionary = scavenge_doodad.scavenge()
	print("Scavenging of " + scavenge_doodad.get_id() + "Finished")
	print("The following items have been added to inventory: ", items)
	scavenge_doodad = null
	
	for item in items:
		add_item_to_inventory.emit(item, items[item])
	
	
