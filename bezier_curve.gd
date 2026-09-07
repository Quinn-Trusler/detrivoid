extends Path2D

var timer = 0
var t = 0
var timeout
var points
var total_time
var total_length
var finished = false

const SCALE_VEC = Vector2(0.5,0.5)
var width_total = 10
# Starting value gets added to the total values
var starting_width = 4
var starting_scale = 0.4


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	points = curve.tessellate(5)
	total_length = curve.get_baked_length()
	total_time =  total_length * 0.1
	$Stem.add_point(points[0])
	set_new_timeout()
	
# Creates the next timeout based on next segment length, adds a dummy point
func set_new_timeout() -> void:
	var len_line2d = len($Stem.points)
	print("Timeout line length: ", len_line2d)
	if len_line2d < len(points):# set timeout using length between points
		var p1 = Vector2(points[len_line2d-1])
		var p2 = Vector2(points[len_line2d])
		var vec = p1 - p2
		timeout = vec.length() / total_length * total_time
		$Cap.rotation = Vector2(0,1).angle_to(vec)
		$Stem.add_point(points[len_line2d -1]) # Dummy point, value gets set every frame
	else:
		finished = true


func add_next_point() -> void:
	if len($Stem.points) < len(points):
		var len_line2d = len($Stem.points)
		$Stem.set_point_position(len_line2d - 1, points[len_line2d-1])#remove_point(len_line2d-1)
		len_line2d += 1
		set_new_timeout()
	
func _process(delta: float) -> void:
	if  not finished:
		if timer > timeout:
			timer = 0
			add_next_point()
		timer += delta
		t += delta
		var ind = len($Stem.points) - 1
		$Stem.set_point_position(ind, curve.sample_baked( t/total_time * total_length, true))
		$Stem.width = width_total * t/total_time + starting_width
		$Cap.position  = $Stem.points[ind]
		$Cap.scale = (t/total_time + starting_scale) * SCALE_VEC
