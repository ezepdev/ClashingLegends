extends "res://AbstractState.gd"

func enter(value = null) -> void:
	character._play_animation("dash");
	if "left" in character.last_action_name: 
		character.dash(-500)
	else:
		character.dash(500)

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "dash":
		emit_signal("finished" , "idle")
