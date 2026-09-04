extends Node2D

@export var TileLayer : TileMapLayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	tilemap_to_polygons()
	add_lines()

func add_lines():
	for edge in edges:
		var line = Line2D.new()
		line.width = 2
		line.default_color = Color.BLACK
		line.points = edge
		lines.append(line)
		add_child(line)
 

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# Stores all the iregular edges, these edges need lines
var edges = []
var lines = []
var polygons = []
const TILE_RANGE = [Vector2i(0, 0), Vector2i(100,100)]
func get_ID(pos) -> int:
	var tile_data = TileLayer.get_cell_tile_data(pos)
	if tile_data:
		return tile_data.get_custom_data("ID")
	return -1

const LEFT = Vector2i(-1,0)
const RIGHT = Vector2i(1,0)
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
				print("Tile pos: ", pos)
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
					print("not adding special down edge")
				else:
					down_edge = generate_points(bottom_right, bottom_left)
					print("adding special down edge: ", down_edge)

			
				# Stich edges together and creating a fancy edge
				var loop = []
				
				# Add the clockwise most point when we don't see another tile
				
				if left_edge:
					if len(left_edge) > 1:
						if get_ID(pos + UP) != tile_id:
							edges.append(left_edge + [up_edge[0]])
						else: 
							edges.append(left_edge)
					loop += left_edge
				if up_edge:
					if len(up_edge)>1:
						if get_ID(pos + RIGHT) != tile_id:
							edges.append(up_edge + [right_edge[0]])
						else:
							edges.append(up_edge)
							
					loop += up_edge
				if right_edge:
					if len(right_edge)>1:
						if get_ID(pos + DOWN) != tile_id:
							edges.append(right_edge + [down_edge[0]])
						else:
							edges.append(right_edge)
					loop += right_edge
				if down_edge:
					if len(down_edge)>1:
						if get_ID(pos + LEFT) != tile_id:
							edges.append(down_edge + [left_edge[0]])
						else:
							edges.append(down_edge)
					loop += down_edge
					
				# Show polygon
				var poly = Polygon2D.new()
				poly.texture = TEXTURES[tile_id]
				poly.set_texture_repeat(CanvasItem.TEXTURE_REPEAT_ENABLED)
				poly.polygon = loop
				polygons.append(poly)
				add_child(poly)
				#print(loop)
			
var sample_interval = 1
var wave_height = 2

func get_worldly_distance(position : Vector2):
	return position.x + position.y

# Needs worldy position of 2 corners
# This function returns a sampled wave
func generate_points(start_pos : Vector2, end_pos : Vector2) -> Array:
	# Walk along the vector(start to end) and create points
	var points = []
	
	var vec = end_pos - start_pos
	var vec_normalized = vec.normalized()
	var vec_length = vec.length()
	var perp_vec = vec.orthogonal().normalized()
	var worldly_distance = get_worldly_distance(start_pos) # Don't use length because then it is a float and because computationaly expensive
	
	# Increment this
	var current_pos = start_pos
	
	var distance = 0#worldly_distance % sample_interval # Big brain
	print("worldy_distance: ", worldly_distance)
	while distance*sample_interval < vec_length:
		var d = get_worldly_distance(current_pos)
		print(d)
		var amplitude = get_wave(d)
		points.append(current_pos + perp_vec * amplitude * wave_height) # Start position + how far walked + push off walking vector
		distance += sample_interval
		current_pos += vec_normalized * sample_interval
		
	distance = vec_length # Do something like this to add last point(But I don't need to)
	var amplitude = get_wave(get_worldly_distance(current_pos))
	points.append(start_pos + vec_normalized* distance + perp_vec * amplitude * wave_height) # Start position + how far walked + push off walking vector
	
	
	return points

# If this returns a negative value then two divits in the polygon could cross and then polygon will not display :(
func get_wave(distance):
	return  1 + 0.5 * sin(distance * PI/6) + 0.5 * sin(distance * PI/9) +  0.3 * sin(distance * PI/2) 
	
	
