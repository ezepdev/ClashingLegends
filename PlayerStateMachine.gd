extends "res://AbstractStateMachine.gd"

func _ready() -> void:
	states_map = {
		"idle": $Idle,
		"walk": $Walk,
		"jump": $Jump,
		"attack": $Attak,
		"dash": $Dash,
		"shoot": $Shoot,
		"knockback": $Knockback
	}

func _on_Player_hit(dmg, knockback):
	current_state.handle_event("hit" , [dmg, knockback])
