extends "res://AbstractState.gd"

func enter(value = null , value2 = null) -> void:
	character._play_animation("dash");
	if character.body.flip_h == true: 
		character.dash(-800)
	else:
		character.dash(800)
		
func exit() -> void:
	if !character.is_on_floor():
		character.energy.visible = true
		
func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "dash":
		emit_signal("finished" , "idle")
