extends "res://AbstractState.gd"

var dash_timer;
var dashL_timer;

func enter(value = null) -> void:
	character._play_animation("dash");

# Clean up the state. Reinitialize values like a timer
func exit() -> void:
	return


func handle_input(event: InputEvent) -> void:
	return

func update(delta:float) -> void:
	
	character.get_input(delta)

func _on_animation_finished(anim_name: String) -> void:
	return

func handle_event(event: String, value = null) -> void:
	return
