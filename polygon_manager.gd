extends Node2D
# PolygonManager should be visuals only! No mechanics


@export var TileLayer : TileMapLayer
@onready var PolygonMaker = $PolygonMaker

const LINE_COLOUR  := Color.BLACK
const LINE_THICKNESS := 2
const TILE_RANGE := [Vector2i(0, 0), Vector2i(100,100)]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var polygons = []
	var edges = []
	var lines : Array[Line2D] = []
	var poly_return: Array
	poly_return = PolygonMaker.tilerange_to_polygons(TILE_RANGE, TileLayer)
	polygons = poly_return[0]
	edges = poly_return[1]
	lines = PolygonMaker.add_lines(edges, LINE_THICKNESS, LINE_COLOUR)
	
	# Remove/ delete the stuff
	#PolygonMaker.remove_all_from_list(lines)
	#PolygonMaker.remove_all_from_list(polygons)
	#edges.clear()
	print(polygons)


## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
