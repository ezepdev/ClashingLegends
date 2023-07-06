extends "res://AbstractState.gd"

func enter(value = null , value2 = null) -> void:
	character._play_animation("dash");
	if "left" in character.last_action_name: 
		character.dash(-800)
	else:
		character.dash(800)

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "dash":
		emit_signal("finished" , "idle")
