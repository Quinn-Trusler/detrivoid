extends Node2D
@export var LineHolder : Node2D
@export var PolygonHolder : Node2D

# Updates dictionary of lines given a set of edges
func edges_to_lines(lines : Dictionary, edges : Dictionary , width : int, colour : Color) -> void:
	for key in edges:
		add_line(lines, edges, key, width, colour)
	
# Only updates lines adjacent to a position
func update_tile_lines(lines : Dictionary, edges : Dictionary, pos, width : int, colour : Color) -> void:
	var keys = [[pos + UP, pos], [pos , pos + DOWN], [pos, pos + RIGHT], [pos + LEFT, pos]]
	print("\n\n -----Updating tile lines----")
	for key in keys:
		if key in edges:
			print("Adding line at key: ", key, edges[key])
			if key in lines: # Remove old line
				lines[key].queue_free()
			add_line(lines, edges, key, width, colour)
		
			

func add_line(lines : Dictionary, edges : Dictionary, key, width : int, colour : Color) -> void:
	var line = Line2D.new()
	line.width = width
	line.default_color = colour
	line.points = edges[key]
	lines[key] = line
	LineHolder.add_child(line)

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

var TEXTURES = {1 : load("res://art/test_dirt.png")}
const TILE_SIZE = Vector2i(64,64)
const HALF_WIDTH := TILE_SIZE.x * 0.5
const HALF_HEIGHT := TILE_SIZE.y * 0.5
const TOP_LEFT_CORNET_OFFSET = Vector2(-HALF_WIDTH, -HALF_HEIGHT)
const TOP_RIGHT_CORNER_OFFSET = Vector2(HALF_WIDTH, -HALF_HEIGHT)
const BOTTOM_RIGHT_CORNER_OFFSET = Vector2(HALF_WIDTH,  HALF_HEIGHT)
const BOTTOM_LEFT_CORNER_OFFSET = Vector2(-HALF_WIDTH,  HALF_HEIGHT)

func update_tiles_and_adjacent(pos : Vector2i, tile_layer : TileMapLayer, polygons : Dictionary, edges : Dictionary, lines : Dictionary, width : int, colour : Color, tile_id):
	var tile_positions = [pos, pos + LEFT, pos + RIGHT, pos + DOWN, pos + UP]
	for tile_position in tile_positions:
		update_tile(tile_position, tile_layer, polygons, edges, lines, width, colour, tile_id)
	
# Will update polygons, lines and edges given at singular tile position
# This updates this tile and this tile only. Changing a tile likely affects adjacent so use update_tiles_and_adjacent
func update_tile(pos : Vector2i, tile_layer : TileMapLayer, polygons : Dictionary, edges : Dictionary, lines : Dictionary, width : int, colour : Color, tile_id):
	removed_adjacent_edges_and_lines(pos, edges, lines, tile_layer, tile_id)
	if pos in polygons:
		polygons[pos].queue_free()
		polygons.erase(pos)
	var poly = get_tile_polygon(edges ,pos, tile_layer)
	if poly != null:
		#if pos in polygons: # Not already null
			#
	#else:
		polygons[pos] = poly
		PolygonHolder.add_child(poly)
	# Remove all sandwhiched edges
		
	update_tile_lines(lines, edges, pos, width, colour)
	
	
	
func removed_adjacent_edges_and_lines(pos, edges, lines, tile_layer, tile_id):
	
	var keys = [[pos + UP, pos], [pos , pos + DOWN], [pos, pos + RIGHT], [pos + LEFT, pos]]
	var check_locations = [pos + UP, pos + DOWN, pos + RIGHT, pos + LEFT]
	var adding = false
	if get_ID(pos, tile_layer) != -1:
		adding = true
	for i in range(len(keys)):
		var key = keys[i]
		edges.erase(key)

		if key in lines:
			if adding:
				lines[key].queue_free()
				lines.erase(key)
			elif get_ID(check_locations[i], tile_layer) != tile_id: # Don't erase lines on other tiles
				lines[key].queue_free()
				lines.erase(key)
			
				

# Given a range of tiles it will update a list of edges and polygons
# Edges are used for lines and polygons for the fill
func tilerange_to_polygons(polygons, edges, tile_range, tile_layer : TileMapLayer) -> Array:
	for y in range(tile_range[0].y,tile_range[1].y):
		for x in range(tile_range[0].x,tile_range[1].x):
			var pos = Vector2i(x, y)
			var poly = get_tile_polygon(edges ,pos, tile_layer)
			if poly != null:
				polygons[pos] = poly
				PolygonHolder.add_child(poly)
	return [polygons, edges]


# Uses position to create tile polygon. Updates edges
func get_tile_polygon(edges, pos, tile_layer):
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
		return poly
	return null
	
# get_tile_polygon helper
func stitch_edges_together(loop : Array, edges : Dictionary, tile_layer : TileMapLayer, pos, tile_id, left_edge, up_edge, right_edge, down_edge):
	# Add the clockwise most point when we don't see another tile
	if left_edge:
		if len(left_edge) > 1:
			var edges_key = [pos + LEFT, pos]
			if get_ID(pos + UP, tile_layer) != tile_id:
				edges[edges_key] = left_edge + [up_edge[0]]
			else: 
				edges[edges_key] = left_edge
		loop.append_array(left_edge)
	if up_edge:
		var edges_key = [pos + UP, pos]
		if len(up_edge)>1:
			if get_ID(pos + RIGHT, tile_layer) != tile_id:
				edges[edges_key] = up_edge + [right_edge[0]]
			else:
				edges[edges_key] = up_edge
		loop.append_array(up_edge)
	if right_edge:
		var edges_key = [pos, pos + RIGHT]
		if len(right_edge)>1:
			if get_ID(pos + DOWN, tile_layer) != tile_id:
				edges[edges_key] = right_edge + [down_edge[0]]
			else:
				edges[edges_key] = right_edge
		loop.append_array(right_edge)
	if down_edge:
		var edges_key = [pos, pos + DOWN]
		if len(down_edge)>1:
			if get_ID(pos + LEFT, tile_layer) != tile_id:
				edges[edges_key] = down_edge + [left_edge[0]]
			else:
				edges[edges_key] = down_edge
		loop.append_array(down_edge)


var sample_interval = 1
var wave_height = 10
var frequency_multiplier = 0.1

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
	return  1 + 0.5 * sin(frequency_multiplier * distance * PI/6) + 0.5 * sin(frequency_multiplier * distance * PI/9) +  0.3 * sin(frequency_multiplier * distance * PI/2) 
