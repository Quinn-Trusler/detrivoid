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
	if tile_layer == null:
		push_error("TilemapPolygonExample: assign a TileMapLayer in the Inspector.")
		return
	rebuild()


## Call this whenever tiles are added or removed at runtime.
func rebuild() -> void:
	for child in get_children():
		child.queue_free()

	# Polygons are in the TileMapLayer's LOCAL space.
	# Because this node should be a child of the layer (or share the same
	# transform), no extra coordinate conversion is needed.
	var polygons: Array = _generator.generate_polygons_from_layer(tile_layer)

	print(polygons)
	for loop: PackedVector2Array in polygons:
		if TilemapPolygonGenerator.is_hole(loop):
			# Holes: skip for now, or handle with Geometry2D.clip_polygons().
			continue

		if build_collision:
			assert(false)
		else:
			_add_visual_polygon(loop)
		loops.append(loop)



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
	loop = remove_excess_points(loop)
	loop = move_corners_inwards(loop,2)
	loop = jagged_polygon(loop,1,4,16,PI/4,false)
	poly.polygon = loop 
	create_outline(poly)
	poly.color     = outline_color
	poly.antialiased = true
	polygons.append(poly)
	add_child(poly)
	
	#to make this more intresting try randomly changing the x position not just the y. What I mean is perpendicular direction to the one im already using
	# don't try strictly using a sinusoid, try making own periodic style function
	# try two layers of fake sinusoid
