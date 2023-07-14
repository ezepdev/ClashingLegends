extends "res://AbstractState.gd"

var block_sound = load("res://audio/block.wav")

func enter(value = null,value2=null) -> void:
	character._play_animation("block")


func handle_input(event: InputEvent) -> void:
	if event.is_action_released("jump" + str(character.id)):
		emit_signal("finished","jump")
	elif character.is_on_floor() && event.is_action_pressed("charge_mana" + str(character.id)):
		emit_signal("finished" , "charge")
	elif event.is_action_released("block" + str(character.id)):
		emit_signal("finished" , "idle")



func update(delta:float) -> void:
	character.handle_movement()
	character.handle_charge_jump(delta)
	character._handle_constant_energy()
	if character.move_direction != 0:
		emit_signal("finished" , "walk")
	else:
		character._handle_deacceleration()
		character.apply_speed_limit()
		character._apply_movement()


func handle_event(event: String, value = null) -> void:
	match event:
		"hit":
			if character.get_mana() > 0:
				character.audio_player.stream = block_sound
				character.audio_player.play()
				character._handle_blocked_hit(value[0])
			else:
				character._handle_hit(value[0])
				emit_signal("finished", "knockback" , value[1] , value[2])
