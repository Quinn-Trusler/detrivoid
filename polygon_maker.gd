extends Node2D

# Queue free and remove every element from given list
# Use for polygons and lines
func remove_all_from_list(list):
	for element in list:
		element.queue_free()
	list.clear()

# Returns a list of lines given a set of edges
func add_lines(edges : Array, width : int, colour : Color) -> Array[Line2D]:
	var lines : Array[Line2D]= []
	for edge in edges:
		var line = Line2D.new()
		line.width = width
		line.default_color = colour
		line.points = edge
		lines.append(line)
		add_child(line)
	return lines

# Get ID of a tile
func get_ID(pos, tile_layer) -> int:
	var tile_data = tile_layer.get_cell_tile_data(pos)
	if tile_data:
		return tile_data.get_custom_data("ID")
	return -1

const LEFT = Vector2i(-1,0)
const RIGHT = Vector2i(1,0)
const DOWN = Vector2i(0,1)
const UP = Vector2i(0,-1)

var TEXTURES = {1 : load("res://art/dirt.png")}
const TILE_SIZE = Vector2i(16,16)
const HALF_WIDTH := TILE_SIZE.x * 0.5
const HALF_HEIGHT := TILE_SIZE.y * 0.5
const TOP_LEFT_CORNET_OFFSET = Vector2(-HALF_WIDTH, -HALF_HEIGHT)
const TOP_RIGHT_CORNER_OFFSET = Vector2(HALF_WIDTH, -HALF_HEIGHT)
const BOTTOM_RIGHT_CORNER_OFFSET = Vector2(HALF_WIDTH,  HALF_HEIGHT)
const BOTTOM_LEFT_CORNER_OFFSET = Vector2(-HALF_WIDTH,  HALF_HEIGHT)

# Will update itself and tiles around it
func update_tile(pos : Vector2i, tile_layer : TileMapLayer, polygons : Dictionary, lines):
	pass
	
# Option 1: each tile points to it's edges
# Option 2: we can define edges as what two tiles it's between []

# Given a range of tiles it will return a list of edges and polygons
# Edges are used for lines and polygons for the fill
func tilerange_to_polygons(tile_range, tile_layer : TileMapLayer) -> Array:
	var polygons = {} # Each tile gets it's own wavy polygon
	var edges = [] # Edges are used to form polygons
	for y in range(tile_range[0].y,tile_range[1].y):
		for x in range(tile_range[0].x,tile_range[1].x):
			var pos = Vector2i(x, y)
			var poly_return = get_tile_polygon(pos, tile_layer)
			var poly = poly_return[0]
			polygons[pos] = poly
			edges.append_array(poly_return[1])
			add_child(poly)
	return [polygons, edges]


# Uses position to create tile polygon. 
func get_tile_polygon(pos, tile_layer):
	var edges = []
	var tile_id = get_ID(pos, tile_layer)
	if tile_id != -1:
		var left_edge = null
		var right_edge = null
		var down_edge = null
		var up_edge = null
		var tile_center = tile_layer.map_to_local(pos)

		var top_left = tile_center + TOP_LEFT_CORNET_OFFSET
		var top_right = tile_center + TOP_RIGHT_CORNER_OFFSET
		var bottom_right = tile_center + BOTTOM_RIGHT_CORNER_OFFSET
		var bottom_left = tile_center + BOTTOM_LEFT_CORNER_OFFSET
		
		# If ID's are equal it means don't put a fancy edge in between
		if get_ID(pos + LEFT, tile_layer) == tile_id:
			left_edge = [bottom_left]
		else:
			left_edge = generate_points(bottom_left, top_left)
		if get_ID(pos + UP, tile_layer) == tile_id:
			up_edge = [top_left]
		else:
			up_edge = generate_points(top_left, top_right)
		if get_ID(pos + RIGHT, tile_layer) == tile_id:
			right_edge = [top_right]
		else:
			right_edge = generate_points(top_right, bottom_right)
		if get_ID(pos + DOWN, tile_layer) == tile_id:
			down_edge = [bottom_right]
		else:
			down_edge = generate_points(bottom_right, bottom_left)
	
		# Stich edges together and creating a fancy edge
		var loop = []
		stitch_edges_together(loop, edges, tile_layer, pos, tile_id, left_edge, up_edge, right_edge, down_edge)
			
		# Show polygon
		var poly = Polygon2D.new()
		poly.texture = TEXTURES[tile_id]
		poly.set_texture_repeat(CanvasItem.TEXTURE_REPEAT_ENABLED)
		poly.polygon = loop
		return [poly,edges]
	return [null, edges]
	
# get_tile_polygon helper
func stitch_edges_together(loop, edges, tile_layer, pos, tile_id, left_edge, up_edge, right_edge, down_edge):
	# Add the clockwise most point when we don't see another tile
	if left_edge:
		if len(left_edge) > 1:
			if get_ID(pos + UP, tile_layer) != tile_id:
				edges.append(left_edge + [up_edge[0]])
			else: 
				edges.append(left_edge)
		loop.append_array(left_edge)
	if up_edge:
		if len(up_edge)>1:
			if get_ID(pos + RIGHT, tile_layer) != tile_id:
				edges.append(up_edge + [right_edge[0]])
			else:
				edges.append(up_edge)
		loop.append_array(up_edge)
	if right_edge:
		if len(right_edge)>1:
			if get_ID(pos + DOWN, tile_layer) != tile_id:
				edges.append(right_edge + [down_edge[0]])
			else:
				edges.append(right_edge)
		loop.append_array(right_edge)
	if down_edge:
		if len(down_edge)>1:
			if get_ID(pos + LEFT, tile_layer) != tile_id:
				edges.append(down_edge + [left_edge[0]])
			else:
				edges.append(down_edge)
		loop.append_array(down_edge)


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
	#print("worldy_distance: ", worldly_distance)
	var amplitude
	while distance*sample_interval < vec_length:
		var d = get_worldly_distance(current_pos)
		#print(d)
		amplitude = get_wave(d)
		points.append(current_pos + perp_vec * amplitude * wave_height) # Start position + how far walked + push off walking vector
		distance += sample_interval
		current_pos += vec_normalized * sample_interval
		
	distance = vec_length # Do something like this to add last point(But I don't need to)
	amplitude = get_wave(get_worldly_distance(current_pos))
	points.append(start_pos + vec_normalized* distance + perp_vec * amplitude * wave_height) # Start position + how far walked + push off walking vector
	
	
	return points

# If this returns a negative value then two divits in the polygon could cross and then polygon will not display :(
func get_wave(distance):
	return  1 + 0.5 * sin(distance * PI/6) + 0.5 * sin(distance * PI/9) +  0.3 * sin(distance * PI/2) 
