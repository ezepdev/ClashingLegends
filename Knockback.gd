extends "res://AbstractState.gd"

var knockbackTimer = 0
var KNOCKBACK_DURATION = 1
var KNOCKBACK_END = 2
var knockback_copy
var destructibles: Array
var destruction_polygon 
var gravity = 10
var audio_explosion

func enter(knockback = null) -> void:
	if knockback.x > 0:
		character.body.flip_h = true
	elif knockback.x < 0:
		character.body.flip_h = false
	audio_explosion = character.get_parent().get_node("Explosion")
	character._play_animation("knockback")
	destructibles = get_tree().get_nodes_in_group("Destructible")
	destruction_polygon = character.get_node("DestructionArea/Polygon2D")
	character.get_node("DestructionArea").monitoring = true
	knockbackTimer = 0
	knockback_copy = knockback
	character.velocity = knockback * 6000

func handle_input(event: InputEvent) -> void:
	if knockbackTimer >= KNOCKBACK_DURATION:
		if event:
			emit_signal("finished" , "idle")

func exit()  -> void:
	return

func update(delta:float) -> void:
		knockbackTimer += delta
		character.velocity -= knockback_copy * 30
		character.velocity.y += gravity
		character.move_and_slide(character.velocity)
		for body in character.get_node("DestructionArea").get_overlapping_bodies():
			if body in destructibles:
				call_deferred("calculate_destruction" , body , destruction_polygon)
		if knockbackTimer >= KNOCKBACK_DURATION:
			if character.move_direction != 0:
				emit_signal("finished" , "walk")
			elif knockbackTimer >= KNOCKBACK_END:
				emit_signal("finished" , "idle")

func calculate_destruction(body , destruction_polygon):
	var final_position = Transform2D(0, character.get_node("DestructionArea/Polygon2D").global_position).xform(character.get_node("DestructionArea/Polygon2D").polygon)
	body.carve(final_position)
	audio_explosion.play()
