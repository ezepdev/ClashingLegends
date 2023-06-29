extends "res://AbstractState.gd"

var knockbackTimer = 0
var KNOCKBACK_DURATION = 1

func enter(knockback = null) -> void:
	knockbackTimer = 0
	character.velocity += knockback
	
func exit() -> void:
	return


func handle_input(event: InputEvent) -> void:
	return


func update(delta:float) -> void:
		knockbackTimer += delta
		if knockbackTimer >= KNOCKBACK_DURATION:
			emit_signal("finished" , "idle")
		else:
			character.velocity.x = clamp(character.velocity.x + (character.move_direction * character.ACCELERATION), -2000, 2000)
			character._apply_movement()

func _on_animation_finished(anim_name: String) -> void:
	return

func handle_event(event: String, value = null) -> void:
	return
