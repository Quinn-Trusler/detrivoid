
### 

## TilemapPolygonExample.gd
## Attach this script to a Node2D that is a CHILD of your TileMapLayer node
## (or any node that can parent Polygon2D / StaticBody2D children).
##
## In the Inspector, drag your TileMapLayer into the `tile_layer` export slot.

extends Node2D

## The TileMapLayer to read tiles from.
@export var tile_layer: TileMapLayer

## If true, spawns StaticBody2D + CollisionPolygon2D for physics.
## If false, spawns Polygon2D for visual outlines only.
@export var build_collision := true

@export var outline_color := Color(1.0, 0.35, 0.35, 0.85)
@export var texture : Texture2D

var _generator := TilemapPolygonGenerator.new()

var loops : Array = [] # An array that holds lists
var polygons : Array = [] # An array of Polygon2Ds

func _ready() -> void:
	#if tile_layer == null:
		#push_error("TilemapPolygonExample: assign a TileMapLayer in the Inspector.")
		#return
	#rebuild()
	pass


## Call this whenever tiles are added or removed at runtime.
func rebuild() -> void:
	for child in get_children():
		child.queue_free()

	# Polygons are in the TileMapLayer's LOCAL space.
	# Because this node should be a child of the layer (or share the same
	# transform), no extra coordinate conversion is needed.
	var polygons_: Array = _generator.generate_polygons_from_layer(tile_layer)

	print(polygons)
	for loop: PackedVector2Array in polygons_:
		if TilemapPolygonGenerator.is_hole(loop):
			# Holes: skip for now, or handle with Geometry2D.clip_polygons().
			continue

		if build_collision:
			assert(false)
		else:
			_add_visual_polygon(loop)
		loops.append(loop)

var tile_size : Vector2i = Vector2i(16,16)
# If add is false it will subtract
func cell_exists(cell: Vector2i) -> bool:
	return tile_layer.get_cell_source_id(cell) != -1
	


# Don't try removing when there is nothing to remove
# Don't try adding when there is nothing to add
# Don't try merging two polygons or creating a loop
# Will not work if adjacent tiles are in polygon and not map or vice versa. You can add the actual tile before or after this function, if you don't and run it again it will fail.
func edit_tile(cell : Vector2, add : bool = true) -> void:
	print("Trying to add: ", cell)
	# Verticies to add and vertices to delete

	var cx: int = cell.x
	var cy: int = cell.y

	# map_to_local() returns the CENTER of the cell in local space.
	var center: Vector2 = get_parent().map_to_local(cell)
	var hw := tile_size.x * 0.5
	var hh := tile_size.y * 0.5
	var tl := center + Vector2(-hw, -hh)   # top-left
	var tr := center + Vector2( hw, -hh)   # top-right
	var br := center + Vector2( hw,  hh)   # bottom-right
	var bl := center + Vector2(-hw,  hh)   # bottom-left

	var add_edges = []
	var remove_edges = []
	
	# Top edge → left to right
	if cell_exists(Vector2i(cx, cy - 1)):
		remove_edges.append([tl, tr])
	else: 
		add_edges.append([tl, tr])

	# Bottom edge → right to left
	if cell_exists(Vector2i(cx, cy + 1)):
		remove_edges.append([br, bl])
	else:
		add_edges.append([br,bl])

	# Left edge → bottom to top
	if cell_exists(Vector2i(cx - 1, cy)):
		remove_edges.append([bl, tl])
	else:
		add_edges.append([bl,tl])

	# Right edge → top to bottom
	if cell_exists(Vector2i(cx + 1, cy)):
		remove_edges.append([tr, br])
	else:
		add_edges.append([tr, br])

	if not add:
		print("attempting swamp")
		print(remove_edges)
		print(add_edges)
		var temp = add_edges
		add_edges = remove_edges
		remove_edges = temp
		print(remove_edges)
		print(add_edges)
		
	if len(add_edges) == 4: # Create a new polygon
		print("brand new polygon functionality")
	
		
	# Either last tile and remove polygon or no tile at all
	elif len(remove_edges) == 4:
		# Either last tile and remove polygon or no tile at all
		loops.remove_at(0)
		polygons[0].queue_free()
		return
	# Assume tile is no merging or unmerging two polygons 
	else:
		print(remove_edges)
		# remove points that are doubled up
		for i in range(len(remove_edges)):
			for j in range(len(remove_edges)):
				print("removed doubled points")
				if remove_edges[i][0] == remove_edges[j][1]: # If point shared between 2 edges
					print("actual removal", len(loops[0]))
					loops[0].erase(remove_edges[i][0])
					print(len(loops[0]))
					
		# No need to add any points to polygon
		if len(add_edges) == 1:
			print("One Add Edge")
		
		else: # Two to Three add_edges			
			var starting_index = -1
			var ending_index = -1
			var adj_list = {}
			var rev_adj_list = {}
			for i in range(len(add_edges)):
				adj_list[add_edges[i][0]] = add_edges[i][1]
				rev_adj_list[add_edges[i][1]] = add_edges[i][0]
			
			var start_point
			var end_point
			# Up to 3 add edges, assume they are in proper order
			for i in range(len(add_edges)):
				#Start point is the starting point that is not in second position of any
				var found_start = true
				var found_end = true
				
				# Is a start or end point if it is unique
				for j in range(len(add_edges)):
					if add_edges[i][0] == add_edges[j][1]:
						found_start = false
					if add_edges[i][1] == add_edges[j][0]:
						found_end = false
				
				# Find the index of the start/end point in the array
				if found_start:
					start_point = add_edges[i][0]
					starting_index = loops[0].find(start_point)
				if found_end:
					end_point = add_edges[i][1]
					ending_index = loops[0].find(end_point)
			
			print(adj_list)
			# Add one or two points between start and end
			if starting_index < ending_index:
				print("insert points")
				var new_point = adj_list[start_point]
				loops[0].insert(starting_index + 1, new_point)
				if len(add_edges) > 2:
					new_point = adj_list[new_point]
					loops[0].insert(starting_index + 2, new_point)
			else:
				print("insert points reversy")
				var new_point = rev_adj_list[end_point]
				loops[0].insert(ending_index + 1, new_point)
				if len(add_edges) > 2:
					new_point = rev_adj_list[new_point]
					loops[0].insert(ending_index + 2, new_point)
	
	#print("------")
	#print(loops[0])	
	polygons[0].polygon = loops[0]
	var children = polygons[0].get_children()
	children[0].points = loops[0]#free()
	#create_outline(polygons[0])
	
	print("finished addition")
	# 1. Identify polygon it's touching
	# 2. If it is not touching a po
	# 2. Add points to said loop
	# 3. Add points to said polygon
	# Add polygon seperation and merging??? - NO!!!

func jagged_polygon(points: PackedVector2Array, roughness: float = 8.0, jaggy_distance: float = 20.0, period : float = 16, shift : float = PI/4, add_i : bool = false) -> PackedVector2Array:
	var new_points = PackedVector2Array()
	for i in range(points.size()):
		var a = points[i]
		var b = points[(i + 1) % points.size()]
		new_points.append(a)
		
		var edge = b - a
		var length = edge.length()
		var normal = Vector2(-edge.y, edge.x).normalized()
		
		# At least 1 jaggy, otherwise however many fit at jaggy_distance spacing
		var count = max(1, int(length / jaggy_distance))

		for j in range(1, count + 1):
			var t = float(j) / (count + 1)
			var mid = a.lerp(b, t)
			# Adding I to j yeilds diffrent effects
			var offset
			if add_i:
				offset =  roughness * sin((j+i) * jaggy_distance / period * 2* PI + shift)# + randf_range(1, 2)
			else:
				offset =  roughness * sin(j * jaggy_distance / period * 2* PI + shift)# * randf_range(1, 2)
			new_points.append(mid + normal * offset)
	
	return new_points

func create_outline(polygon: Polygon2D, color: Color = Color.BLACK, width: float = 2.0) -> Line2D:
	var line = Line2D.new()
	line.default_color = color
	line.width = width
	line.closed = true
	line.points = polygon.polygon
	polygon.add_child(line)
	return line

func remove_excess_points(points: PackedVector2Array):
	#for i in range(len(points)):
	var i = 0
	while i < len(points):
		var a = points[(i-1) % points.size()]
		var b = points[i]
		var c = points[(i + 1) % points.size()]# Cheaty Wrap around trick
		
		if a.x == b.x and b.x == c.x:
			points.remove_at(i)
			i -=1
		elif a.y == b.y and b.y == c.y:
			points.remove_at(i)
			i -=1
		i += 1
	return points

# I wrote this one
func move_corners_inwards(points: PackedVector2Array, distance : float = 3.0):
	var modifications = []
	for i in range(len(points)):
		var a = points[(i-1) % points.size()]
		var b = points[i]
		var c = points[(i + 1) % points.size()]# Cheaty Wrap around trick
		
		var ab = Vector2(b - a).normalized()
		var cb = Vector2(b - c).normalized()
		
		modifications.append((ab + cb).normalized() * distance)
		
	for i in range(len(points)):
		points[i] -= modifications[i]
	
	return points
	
	
func _add_visual_polygon(loop: PackedVector2Array) -> void:
	var poly       := Polygon2D.new()
	poly.texture = texture
	poly.set_texture_repeat(CanvasItem.TEXTURE_REPEAT_ENABLED)
	#poly.polygon   = jagged_polygon(loop, 3, 3)
	#loop = remove_excess_points(loop)
	#loop = move_corners_inwards(loop,2)
	loop = jagged_polygon(loop,2,4,16,PI/4,false)
	poly.polygon = loop 
	create_outline(poly)
	poly.color     = outline_color
	poly.antialiased = true
	polygons.append(poly)
	add_child(poly)
	
	#to make this more intresting try randomly changing the x position not just the y. What I mean is perpendicular direction to the one im already using
	# don't try strictly using a sinusoid, try making own periodic style function
	# try two layers of fake sinusoid
