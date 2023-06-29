extends "res://AbstractState.gd"

var is_shooting;

func enter(value = null) -> void:
	is_shooting = true;
	character.play_animation("shoot");
	character.fire()

# Clean up the state. Reinitialize values like a timer
func exit() -> void:
	return

func handle_input(event: InputEvent) -> void:
	return

func update(delta:float) -> void:
	character.handle_movement()
	if character.move_direction != 0:
		emit_signal("finished" , "walk")
	else:
		character._handle_deacceleration()
		character.apply_speed_limit()
		character._apply_movement()
		if character.is_on_floor():
			character._play_animation("idle")
		else:
			character._play_animation("jump")

func _on_animation_finished(anim_name: String) -> void:
	return

func handle_event(event: String, value = null) -> void:
	return
