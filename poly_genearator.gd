
##################################################################


extends Node2D
## TilemapPolygonGenerator.gd
## Generates outline polygons directly from a TileMapLayer node.
##
## Usage:
##   var gen = TilemapPolygonGenerator.new()
##   var polygons = gen.generate_polygons_from_layer(tile_map_layer)
##
## Each entry in `polygons` is a PackedVector2Array of LOCAL-space vertices
## (relative to the TileMapLayer). Pass them straight to Polygon2D or
## CollisionPolygon2D children of the same layer node.
##
## To get world-space vertices instead, call generate_polygons_from_layer()
## with world_space = true.

class_name TilemapPolygonGenerator


## Generate polygons from a TileMapLayer node.
##
## @param layer       TileMapLayer  – the layer node to read cells from
## @param world_space bool          – if true, transform vertices to global space
## @returns           Array[PackedVector2Array]
func generate_polygons_from_layer(layer: TileMapLayer, world_space := false) -> Array:
	var cells: Array[Vector2i] = layer.get_used_cells()
	if cells.is_empty():
		return []

	var tile_size := Vector2(layer.tile_set.tile_size)

	# ── 1. Occupied set ───────────────────────────────────────────────────────
	var occupied := {}
	for cell in cells:
		occupied[cell] = true

	# ── 2. Collect directed boundary edges in LOCAL tile-map space ────────────
	# Corner positions are derived from map_to_local(), which correctly handles
	# tile size, spacing, and any TileSet offsets.
	# We compute the center of each cell then offset by half the tile size to
	# get corners, preserving a consistent CCW winding for outer loops.
	var edges: Array = []   # Array of [Vector2, Vector2]

	for cell in occupied.keys():
		var cx: int = cell.x
		var cy: int = cell.y

		# map_to_local() returns the CENTER of the cell in local space.
		var center: Vector2 = layer.map_to_local(cell)
		var hw := tile_size.x * 0.5
		var hh := tile_size.y * 0.5
		var tl := center + Vector2(-hw, -hh)   # top-left
		var tr := center + Vector2( hw, -hh)   # top-right
		var br := center + Vector2( hw,  hh)   # bottom-right
		var bl := center + Vector2(-hw,  hh)   # bottom-left

		# Top edge → left to right
		if not occupied.has(Vector2i(cx, cy - 1)):
			edges.append([tl, tr])

		# Bottom edge → right to left
		if not occupied.has(Vector2i(cx, cy + 1)):
			edges.append([br, bl])

		# Left edge → bottom to top
		if not occupied.has(Vector2i(cx - 1, cy)):
			edges.append([bl, tl])

		# Right edge → top to bottom
		if not occupied.has(Vector2i(cx + 1, cy)):
			edges.append([tr, br])

	if edges.is_empty():
		return []

	# ── 3. Adjacency map: start-point → list of edge indices ─────────────────
	# Forms an array representation of the graph, with a point and all it's respective edges
	var adj: Dictionary = {}
	for i in range(edges.size()):
		var start: Vector2 = edges[i][0]
		if not adj.has(start):
			adj[start] = []
		adj[start].append(i)

	# ── 4. Walk directed chains into closed loops ─────────────────────────────
	var used := {}
	var polygons: Array = []

	for start_idx in range(edges.size()):
		if used.has(start_idx):
			continue

		var loop := PackedVector2Array()
		var idx: int = start_idx

		while not used.has(idx):
			used[idx] = true
			var edge: Array = edges[idx]
			loop.append(edge[0])

			var next_pt: Vector2 = edge[1]
			var found_next := false

			if adj.has(next_pt):
				for candidate in adj[next_pt]:
					if not used.has(candidate):
						idx = candidate
						found_next = true
						break

			if not found_next:
				break

		if loop.size() >= 3:
			if world_space:
				loop = _to_world(loop, layer)
			polygons.append(loop)

	return polygons


## Transform a loop from the layer's local space to global/world space.
static func _to_world(loop: PackedVector2Array, layer: TileMapLayer) -> PackedVector2Array:
	var out := PackedVector2Array()
	out.resize(loop.size())
	for i in range(loop.size()):
		out[i] = layer.to_global(loop[i])
	return out


## Signed area of a polygon loop.
## Positive → counter-clockwise (outer boundary, Godot Y-down)
## Negative → clockwise (hole)
static func signed_area(loop: PackedVector2Array) -> float:
	var n := loop.size()
	var area := 0.0
	for i in range(n):
		var a: Vector2 = loop[i]
		var b: Vector2 = loop[(i + 1) % n]
		area += (a.x * b.y) - (b.x * a.y)
	return area * 0.5


## Returns true if the loop is a hole (clockwise winding).
static func is_hole(loop: PackedVector2Array) -> bool:
	return signed_area(loop) < 0.0
