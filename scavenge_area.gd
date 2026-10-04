extends Area2D


var doodads_in_field : Array= []
var closest_doodad = null


func get_dist_sqrd(vec1 : Vector2, vec2 : Vector2):
	return (vec1.x - vec2.x)**2 + (vec1.y - vec2.y)**2

func get_doodad_in_scavenge_area():
	return closest_doodad

func update_closest_doodad_in_field():
	if len(doodads_in_field) == 0:
		closest_doodad = null 
	else:
		if closest_doodad:
			closest_doodad.set_scavenge_tag(false)
		closest_doodad = doodads_in_field[0]
		for doodad in doodads_in_field:
			if get_dist_sqrd(position, doodad.position) < get_dist_sqrd(position, closest_doodad.position):
				closest_doodad = doodad
		
		closest_doodad.set_scavenge_tag(true)
			
func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("doodad"):
		var doodad = area.get_parent()
		print("considering doodad ", doodad)
		if doodad.is_scavengeable():
			print("doodad was scavengable")
			doodads_in_field.append(doodad)
			update_closest_doodad_in_field()

func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group("doodad"):
		var doodad = area.get_parent()
		if doodad.is_scavengeable():
			doodad.set_scavenge_tag(false)
			doodads_in_field.erase(doodad)
			update_closest_doodad_in_field()
