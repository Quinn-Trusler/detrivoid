extends Node2D
# PolygonManager should be visuals only! No mechanics


@export var TileLayer : TileMapLayer
@onready var PolygonMaker = $PolygonMaker

const LINE_COLOUR  := Color.BLACK
const LINE_THICKNESS := 8
const TILE_RANGE := [Vector2i(0, 0), Vector2i(100,100)]

var polygons : Dictionary = {}
var edges : Dictionary = {}
var lines : Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	PolygonMaker.tilerange_to_polygons(polygons, edges, TILE_RANGE, TileLayer)
	PolygonMaker.edges_to_lines(lines, edges, LINE_THICKNESS, LINE_COLOUR)
	print(polygons)

func update_tile(pos, tile_id) -> void:
	PolygonMaker.update_tiles_and_adjacent(pos, TileLayer, polygons, edges, lines, LINE_THICKNESS, LINE_COLOUR, tile_id)
