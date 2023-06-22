extends "res://AbstractState.gd"


func enter(value = null) -> void:
	return

# Clean up the state. Reinitialize values like a timer
func exit() -> void:
	return


func handle_input(event: InputEvent) -> void:
	return


func update(delta:float) -> void:
	return


func _on_animation_finished(anim_name: String) -> void:
	return


func handle_event(event: String, value = null) -> void:
	return
