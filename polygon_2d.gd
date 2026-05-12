extends Polygon2D


var outer = PackedVector2Array([
	Vector2(0,0),
	Vector2(300,0),
	Vector2(300,300),
	Vector2(0,300)
])

var hole = PackedVector2Array([
	Vector2(100,100),
	Vector2(200,100),
	Vector2(200,200),
	Vector2(100,200)
])

func _ready() -> void:
	#hole.reverse() # Makes it a hole
	pass
	#polygons = [outer, hole]
