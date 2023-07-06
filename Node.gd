extends "res://AbstractState.gd"

func enter(value = null , value2 = null) -> void:
	return
# Clean up the state. Reinitialize values like a timer
func exit() -> void: 
	return
func handle_input(event: InputEvent) -> void:
	return


func update(delta:float) -> void:
	character.handle_movement()
	character._handle_deacceleration()
	character.apply_speed_limit()
	character._apply_movement()

func handle_event(event: String, value = null) -> void:
	return
