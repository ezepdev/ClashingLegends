extends "res://AbstractState.gd"

var knockbackTimer = 0
var KNOCKBACK_DURATION = 1
var KNOCKBACK_END = 2
var knockback_copy
var destructibles: Array
var destruction_polygon 
var gravity = 10
var audio_explosion
var power_copy
var destruction_area

func enter(knockback = null , power = null )  -> void:
	if power < 1000:
		KNOCKBACK_DURATION = 0.3
	power_copy = power
	if power < 6000:
		KNOCKBACK_END = 1
	if knockback.x > 0:
		character.body.flip_h = true
	elif knockback.x < 0:
		character.body.flip_h = false
	audio_explosion = character.get_parent().get_node("Explosion")
	character._play_animation("knockback")
	destructibles = get_tree().get_nodes_in_group("Destructible")
	destruction_area = character.get_node("DestructionArea")
	destruction_polygon = character.get_node("DestructionArea/Polygon2D")
	destruction_area.monitoring = true
	knockbackTimer = 0
	knockback_copy = knockback
	character.velocity = knockback * power


func exit()  -> void:
	destruction_area.monitoring = false

func update(delta:float) -> void:
		knockbackTimer += delta
		character.velocity -= knockback_copy * 30
		character.move_and_slide(character.velocity)
		character._handle_constant_energy()
		for body in destruction_area.get_overlapping_bodies():
			if body in destructibles:
				call_deferred("calculate_destruction" , body , destruction_polygon)
		if knockbackTimer >= KNOCKBACK_DURATION:
			if character.health_player <= 0:
				emit_signal("finished" , "dead")
			elif character.move_direction != 0:
				if Input.is_action_pressed("block" + str(character.id)):
					emit_signal("finished" , "block")
				else:
					emit_signal("finished" , "walk")
			else:
				if Input.is_action_pressed("block" + str(character.id)):
					emit_signal("finished" , "block")
				else:
					emit_signal("finished" , "idle")

func calculate_destruction(body , destruction_polygon):
	var final_position = Transform2D(0, character.get_node("DestructionArea/Polygon2D").global_position).xform(character.get_node("DestructionArea/Polygon2D").polygon)
	body.carve(final_position)
	audio_explosion.play()
