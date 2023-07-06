tool
extends StaticBody2D
class_name Destructible

onready var default_quadrant_polygon: Array = $CollisionPolygon2D.polygon
onready var texture : StreamTexture = $CollisionPolygon2D/Polygonete.texture
onready var audio = $CollisionPolygon2D/AudioStreamPlayer
var explosionAudio = load("res://audio/Explosion.wav")
export (Array , Vector2) var starting_polygon : Array


func _ready():
	generate(starting_polygon)

func carve(clipping_polygon):
	"""
	Carves the clipping_polygon away from the quadrant
	"""
	
	for colpol in get_children():
		var final_polygon_square = Transform2D(0, global_position).xform(colpol.polygon)
		if Geometry.intersect_polygons_2d(final_polygon_square , clipping_polygon):
			var clipped_polygons = Geometry.clip_polygons_2d(final_polygon_square, clipping_polygon)
			var n_clipped_polygons = len(clipped_polygons)

			match n_clipped_polygons:
				0:
					# clipping_|polygon completely overlaps colpol
					colpol.free()
				1:
					# Clipping produces only one polygon
					call_deferred("update_col" , colpol , clipped_polygons[0])
					#update_col(colpol , clipped_polygons[0])
#					colpol.set_polygon(Transform2D(0, -global_position).xform(clipped_polygons[0]))
#					colpol.get_node("Polygonete").polygon = colpol.polygon
	#				colpol.update_pol(clipped_polygons[0])
				2:
					# Check if you carved a hole (one of the two polygons
					# is clockwise). If so, split the polygon in two that
					# together make a "hollow" collision shape
					if _is_hole(clipped_polygons):
						# split and add
						for p in _split_polygon(clipping_polygon):
							var new_colpol = _new_colpol(
								Transform2D(0, -global_position).xform(p)
								)
							call_deferred("add_child", new_colpol)
						colpol.free()
						# if its not a hole, behave as in match _
					else:
						#colpol.update_pol(clipped_polygons[0])
						call_deferred("update_col" , colpol , clipped_polygons[0])
						for i in range(n_clipped_polygons-1):
							var new_col = _new_colpol(Transform2D(0, -global_position).xform(clipped_polygons[i+1]))
							call_deferred("add_child" , new_col)
				
				# if more than two polygons, simply add all of
				# them to the quadrant
				_:
					call_deferred("update_col" , colpol , clipped_polygons[0])
					for i in range(n_clipped_polygons-1):
						var new_col = _new_colpol(Transform2D(0, -global_position).xform(clipped_polygons[i+1]))
						call_deferred("add_child" , new_col)
#	if self != null:
#		audio.play()
						
func _split_polygon(clip_polygon: Array):
	"""
	Returns two polygons produced by vertically
	splitting split_polygon in half
	"""
	var avg_x = Transform2D(0 , -global_position).xform(_avg_position(clip_polygon)).x
	print(avg_x)
	var left_subquadrant = PoolVector2Array(default_quadrant_polygon.duplicate())
	left_subquadrant[1] = Vector2(avg_x, left_subquadrant[1].y)
	left_subquadrant[2] = Vector2(avg_x, left_subquadrant[2].y)
	var right_subquadrant = PoolVector2Array(default_quadrant_polygon.duplicate())
	right_subquadrant[0] = Vector2(avg_x, right_subquadrant[0].y)
	right_subquadrant[3] = Vector2(avg_x, right_subquadrant[3].y)
	var left_offseteado = Transform2D(0, global_position).xform(left_subquadrant)
	var right_offseteado = Transform2D(0, global_position).xform(right_subquadrant)
	var pol1 = Geometry.clip_polygons_2d(left_offseteado, clip_polygon)[0]
	var pol2 = Geometry.clip_polygons_2d(right_offseteado, clip_polygon)[0]
	return [pol1, pol2]


func _is_hole(clipped_polygons):
	"""
	If either of the two polygons after clipping
	are clockwise, then you have carved a hole
	"""
	return Geometry.is_polygon_clockwise(clipped_polygons[0]) or Geometry.is_polygon_clockwise(clipped_polygons[1])


func _avg_position(array: Array):
	"""
	Average 2D position in an
	array of positions
	"""
	var sum = Vector2()
	for p in array:
		sum += p
	return sum/len(array)


func _new_colpol(polygon):
	"""
	Returns ColPol instance
	with assigned polygon
	"""
	var colpol = CollisionPolygon2D.new()
	var polygonete = Polygon2D.new()
#	var audioStream = AudioStreamPlayer.new()
#	audioStream.stream = explosionAudio
#	colpol.name = "CollisionPolygon2D"
	polygonete.texture = texture
	polygonete.polygon = polygon
	polygonete.name = "Polygonete"
	colpol.polygon = polygon
	colpol.add_child(polygonete)
#	colpol.add_child(audioStream)
	
	return colpol

func update_col(colpol , cutpol):
	colpol.set_polygon(Transform2D(0, -global_position).xform(cutpol))
	colpol.get_node("Polygonete").polygon = colpol.polygon

func generate(polygon :Array):
	$CollisionPolygon2D.polygon = polygon
	$CollisionPolygon2D/Polygonete.polygon = polygon
