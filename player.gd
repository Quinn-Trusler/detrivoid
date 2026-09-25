extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var starting_health = 100
var health = 0

@export var SpawnPoint : Node2D
@export var Camera : Camera2D
@export var HeldItem : Sprite2D

@onready var tween = get_tree().create_tween()

var doodads_in_field : Array= []
var closest_doodad = null


signal create_doodad_at_player(item_id : String, number : int)
signal add_item_to_inventory(item_id : String, number : int)


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
		
	if Input.is_action_just_pressed("pickup_item"):
		pickup_doodad()

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
	
	
# To get the closest item:
# Add objects that enter field
# Remove objects that leave field
# Calculate closes item based on position

func get_dist_sqrd(vec1 : Vector2, vec2 : Vector2):
	return (vec1.x - vec2.x)**2 + (vec1.y - vec2.y)**2

func pickup_doodad():
	if closest_doodad == null:
		print("No Doodad to pickup") # will want to put sound hear in futur
	else:
		add_item_to_inventory.emit(closest_doodad.get_id(), 1)
		doodads_in_field.erase(closest_doodad)
		closest_doodad.queue_free()
		closest_doodad = null
		update_closest_doodad_in_field()
		

func update_closest_doodad_in_field():
	if len(doodads_in_field) == 0:
		closest_doodad = null 
	else:
		if closest_doodad:
			closest_doodad.set_pickup_tag(false)
		#var old_closest_doodad = closest_doodad
		closest_doodad = doodads_in_field[0]
		for doodad in doodads_in_field:
			if get_dist_sqrd(position, doodad.position) < get_dist_sqrd(position, closest_doodad.position):
				closest_doodad = doodad
		
		closest_doodad.set_pickup_tag(true)
			
	# Also write code to deal with non pickupables (Keep them in field but just ignore)
		#deal with setting closest null edge case when deleting from field

func _on_item_field_area_entered(area: Area2D) -> void:
	if area.is_in_group("doodad"):
		var doodad = area.get_parent()
		if doodad.is_pickupable():
			doodads_in_field.append(doodad)
			update_closest_doodad_in_field()
			
		


func _on_item_field_area_exited(area: Area2D) -> void:
	if area.is_in_group("doodad"):
		var doodad = area.get_parent()
		if doodad.is_pickupable():
			doodad.set_pickup_tag(false)
			doodads_in_field.erase(doodad)
			update_closest_doodad_in_field()
