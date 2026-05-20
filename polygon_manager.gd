extends Node2D

@export var TileLayer : TileMapLayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	tilemap_to_polygons()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# Stores all the iregular edges, these edges need lines
var edges = {}
var lines = []
var polygons = []
const TILE_RANGE = [Vector2i(0, 0), Vector2i(100,100)]
func get_ID(pos) -> int:
	var tile_data = TileLayer.get_cell_tile_data(pos)
	if tile_data:
		return tile_data.get_custom_data("ID")
	return -1

const LEFT = Vector2i(1,0)
const RIGHT = Vector2i(-1,0)
const DOWN = Vector2i(0,1)
const UP = Vector2i(0,-1)

var TEXTURES = {1 : load("res://art/dirt.png")}
const TILE_SIZE = Vector2i(16,16)
func tilemap_to_polygons() -> void:
	
	for y in range(TILE_RANGE[0].y,TILE_RANGE[1].y):
		for x in range(TILE_RANGE[0].x,TILE_RANGE[1].x):
			var pos = Vector2i(x, y)
			var tile_id = get_ID(pos)
			if tile_id != -1:
				var left_edge = null
				var right_edge = null
				var down_edge = null
				var up_edge = null
				var tile_center = TileLayer.map_to_local(pos)
				print("Tile Center: ", tile_center)
				var hw := TILE_SIZE.x * 0.5
				var hh := TILE_SIZE.y * 0.5
				var top_left = tile_center + Vector2(-hw, -hh)
				var top_right = tile_center + Vector2(hw, -hh)
				var bottom_right = tile_center + Vector2(hw,  hh)
				var bottom_left = tile_center + Vector2(-hw,  hh)
				
				# If ID's are equal it means don't put a fancy edge in between
				if get_ID(pos + LEFT) == tile_id:
					left_edge = [bottom_left]
				else:
					left_edge = generate_points(bottom_left, top_left)
				if get_ID(pos + UP) == tile_id:
					up_edge = [top_left]
				else:
					up_edge = generate_points(top_left, top_right)
				if get_ID(pos + RIGHT) == tile_id:
					right_edge = [top_right]
				else:
					right_edge = generate_points(top_right, bottom_right)
				if get_ID(pos + DOWN) == tile_id:
					down_edge = [bottom_right]
				else:
					down_edge = generate_points(bottom_right, bottom_left)
				# Ignore tiles that have priorities
				
				# Stich edges together
				var loop = []
				# Offset polygon position by 
				if left_edge:
					loop += left_edge
				if up_edge:
					loop += up_edge
				if right_edge:
					loop += right_edge
				if down_edge:
					loop += down_edge
					
				var poly = Polygon2D.new()
				poly.texture = TEXTURES[tile_id]
				poly.set_texture_repeat(CanvasItem.TEXTURE_REPEAT_ENABLED)
				poly.polygon = loop
				polygons.append(poly)
				add_child(poly)
				print(loop)
			
# Generates a set of offset points
# Needs worldy position of 2 corners
# This function returns a sampled wave that needs to be added to
func generate_points(start_pos : Vector2, end_pos : Vector2) -> Array:
	# Always generate points on the bounds, then generate more points in between
	
	return [start_pos]
