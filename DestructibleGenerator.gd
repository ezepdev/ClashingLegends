tool
extends Control

export (bool) var apply :bool = false setget _set_apply
export (PackedScene) var destructible_scene setget _set_destructible_scene

func _set_destructible_scene(scene :PackedScene):
	destructible_scene = scene

func _set_apply(valor : bool):
	apply = false
	if valor:
		var new_destructible : Destructible = destructible_scene.instance()
		get_parent().add_child(new_destructible)
		new_destructible.owner = get_tree().edited_scene_root
		var new_polygon : Array = [Vector2.ZERO , Vector2(rect_size.x , 0) , rect_size , Vector2(0 , rect_size.y)]
		new_destructible.position = rect_position
		new_destructible.starting_polygon = new_polygon
		new_destructible.generate(new_polygon)
