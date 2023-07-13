extends "res://AbstractStateMachine.gd"

func _ready() -> void:
	states_map = {
		"idle": $Idle,
		"walk": $Walk,
		"jump": $Jump,
		"dash": $Dash,
		"knockback": $Knockback,
		"charge" : $Charge,
		"dead": $Dead,
		"block": $Block
	}

func _on_Player_hit(dmg, knockback , power):
	current_state.handle_event("hit" , [dmg, knockback, power])

