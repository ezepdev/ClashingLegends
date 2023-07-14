extends "res://AbstractState.gd"

func enter(value = null , value2 = null) -> void:
	character._play_animation("energy")

# Clean up the state. Reinitialize values like a timer
func exit() -> void:
	character.energy.visible = false
	character.energy.modulate = character.energy_jump_color


func handle_input(event: InputEvent) -> void:
	if event.is_action_released("jump" + str(character.id)):
		emit_signal("finished","jump")
	if event.is_action_released("charge_mana" + str(character.id)):
		emit_signal("finished" , "idle")


func update(delta:float) -> void:
	character.handle_movement()
	character.handle_energy_charge()
	if character.move_direction != 0:
		emit_signal("finished" , "walk")

func handle_event(event: String, value = null) -> void:
	match event:
		"hit":
			character._handle_hit(value[0])
			emit_signal("finished", "knockback" , value[1] , value[2])
