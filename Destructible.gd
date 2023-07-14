tool
extends StaticBody2D
class_name Destructible

onready var default_quadrant_polygon: Array = $CollisionPolygon2D.polygon
export (Texture) var texture : Texture
var explosionAudio = load("res://audio/Explosion.wav")
export (Array , Vector2) var starting_polygon : Array
export (bool) var apply :bool = false setget set_apply

export (Array, Texture) var texture_frames: Array setget _set_texture_frames
export (float) var fps: float = 2.0

var current_frame: int = 0
var count: float = 0.0


func _ready():
	generate(starting_polygon)
	set_process(!texture_frames.empty())
	if !texture_frames.empty():
		_animate_step()

func set_apply(valor : bool):
	apply = false
	if valor && not starting_polygon.empty():
		generate(starting_polygon)

func _set_texture_frames(frames: Array) -> void:
	texture_frames = frames

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
					print("0nomas")
					# clipping_|polygon completely overlaps colpol
					colpol.free()
				1:
					print("1solo")
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
							print("2primero")
							var new_colpol = _new_colpol(
								Transform2D(0, -global_position).xform(p)
								)
							call_deferred("add_child", new_colpol)
						colpol.free()
						# if its not a hole, behave as in match _
					else:
						print("2 segundo")
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
						print("3")
		#actualice_uv(colpol.get_node("Polygonete"))	
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
	colpol.use_parent_material = true
#	var audioStream = AudioStreamPlayer.new()
#	audioStream.stream = explosionAudio
#	colpol.name = "CollisionPolygon2D"
	polygonete.texture = texture.duplicate()
	polygonete.use_parent_material = true
	polygonete.texture.set_region(Rect2(0,0, starting_polygon[2].x, starting_polygon[2].y))
	polygonete.polygon = polygon
	polygonete.name = "Polygonete"
	#actualice_uv(polygonete)
	colpol.polygon = polygon
	colpol.add_child(polygonete)
#	colpol.add_child(audioStream)
	
	return colpol

func update_col(colpol , cutpol):
	
	colpol.set_polygon(Transform2D(0, -global_position).xform(cutpol))
	colpol.get_node("Polygonete").polygon = colpol.polygon
	
	
func generate(polygon :Array):
	var polygonete = $"%Polygonete"
	$CollisionPolygon2D.polygon = polygon
	polygonete.polygon = polygon
	polygonete.texture = texture.duplicate()
	if polygonete.texture is AtlasTexture:
		polygonete.texture.set_region(Rect2(0,0, polygon[2].x, polygon[2].y))
	if !texture_frames.empty():
		_animate_step()
	#actualice_uv($CollisionPolygon2D/Polygonete)


func _process(delta: float) -> void:
	if Engine.editor_hint:
		return
	count += delta
	if texture is AtlasTexture:
		if count >= 1.0 / fps:
			count -= 1.0 / fps
			_animate_step()


func _animate_step() -> void:
	current_frame = (current_frame + 1) % texture_frames.size()
	texture.atlas = texture_frames[current_frame]
	for colpol in get_children():
		var polygonete: Polygon2D = colpol.get_node("Polygonete")
		polygonete.texture.atlas = texture_frames[current_frame]
