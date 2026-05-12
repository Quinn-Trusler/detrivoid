extends Node

const SEARCH_ZONE = [Vector2i(0, 0), Vector2i(100, 100)]
@export var TileLayer : TileMapLayer
@export var Poly : Polygon2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	create_polygon(Vector2(2,3))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

const UP_VEC = Vector2i(0,-1)
const UP_RIGHT_VEC = Vector2i(1,-1)
const RIGHT_VEC = Vector2i(1,0)
const DOWN_RIGHT_VEC = Vector2i(1, 1)
const DOWN_VEC = Vector2i(0,1)
const DOWN_LEFT_VEC = Vector2i(-1,1)
const LEFT_VEC = Vector2i(-1,0)
const UP_LEFT_VEC = Vector2i(-1,-1)
const TEST_TILE = Vector2i(2, 1)

#var visited_nodes : Array = []

class link:
	#Each can take another link
	var up = null
	var up_right = null
	var right = null
	var down_right = null
	var down = null
	var down_left = null
	var left = null
	var up_left = null
	var value
	
	func _init(v : Vector2i) ->void:
		self.value = v
	
	func is_surrounded(TileLayer, pos: Vector2i) -> bool:
		var vecs = [UP_VEC, RIGHT_VEC, DOWN_VEC, LEFT_VEC]
		for vec in vecs:
			if not TileLayer.get_cell_tile_data(pos + vec):
				return false
		return true
	
	func can_move_to(TileLayer, visited_nodes ,pos : Vector2i): # can move to next tile if undiscovered or not empty
		if pos in visited_nodes:
			return false
		elif not TileLayer.get_cell_tile_data(pos): # No Tile
			return false
		elif is_surrounded(TileLayer, pos): #tile is surrounded so can't move into it
			return false
		return true

	# Recursive search function
	func progress(TileLayer, visited_nodes):
		#Label my tile as visited
		visited_nodes.append(self.value)
		TileLayer.set_cell(self.value, 0, TEST_TILE)
		
		
		print("Visiting: ", self.value)
		# Each tile contains data on if empty, discovered, undiscovered
		# Check every thingy
		var test_pos = self.value + UP_VEC
		if can_move_to(TileLayer, visited_nodes,  test_pos):
			up = link.new(test_pos)
			self.up.progress(TileLayer, visited_nodes)
		
		test_pos = self.value + RIGHT_VEC
		if can_move_to(TileLayer, visited_nodes, test_pos):
			right = link.new(test_pos)
			self.right.progress(TileLayer, visited_nodes)
			
		test_pos = self.value + UP_RIGHT_VEC
		if can_move_to(TileLayer, visited_nodes, test_pos):
			up_right = link.new(test_pos)
			self.up_right.progress(TileLayer, visited_nodes)
		
		test_pos = self.value + DOWN_VEC
		if can_move_to(TileLayer, visited_nodes, test_pos):
			down = link.new(test_pos)
			self.down.progress(TileLayer, visited_nodes)

		test_pos = self.value + DOWN_RIGHT_VEC
		if can_move_to(TileLayer, visited_nodes, test_pos):
			down_right = link.new(test_pos)
			self.down_right.progress(TileLayer, visited_nodes)

		test_pos = self.value + LEFT_VEC
		if can_move_to(TileLayer, visited_nodes, test_pos):
			left = link.new(test_pos)
			self.left.progress(TileLayer, visited_nodes)
		
		test_pos = self.value + DOWN_LEFT_VEC
		if can_move_to(TileLayer, visited_nodes, test_pos):
			down_left = link.new(test_pos)
			self.down_left.progress(TileLayer, visited_nodes)
					
		test_pos = self.value + UP_LEFT_VEC
		if can_move_to(TileLayer, visited_nodes, test_pos):
			up_left = link.new(test_pos)
			self.up_left.progress(TileLayer, visited_nodes)	


# Creates a polygon given a starting tile
# Does not deal with holes
func create_polygon(starting_tile : Vector2i):
	# Try up then move in clockwise order
	var prev_tile = starting_tile
	var head = link.new(prev_tile) 
	# First we create the tree then afterwards we can place points
	var visited_nodes = []
	head.progress(TileLayer, visited_nodes)
	print(visited_nodes)
