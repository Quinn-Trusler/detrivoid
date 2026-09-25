class_name DoodadResource
extends Resource

@export_group("Basic")
@export var ID : String = "Invalid"
@export var display_name: String = "none"
@export var texture : Texture2D
@export var inventory_icon : Texture2D
@export var held_texture : Texture2D
@export var colision_shape : Shape2D
@export var colision_shape_offset : Vector2 = Vector2.ZERO
@export_range(-360, 360) var colision_shape_rotation : float = 0

@export_group("Physics")
@export var mass :float = 10
@export_range(0,1) var friction : float = 0.3
@export var bounce : float = 0.1

@export_group("Ground_properties")
@export var pickupable : bool = true
@export var collidable : bool = true
@export var despawn_time : float = -1

@export_group("Decomposition")
@export var decomposable : bool = false
@export var decompose_time : Vector2 = Vector2.ZERO
@export var decompose_tile : String

@export_group("Item_Stuff")
@export var edible : bool = false
@export var plantable : bool = false
@export var throwable : bool = false
@export var is_tile : bool = false
@export var hold_position : Vector2 = Vector2.ZERO 
