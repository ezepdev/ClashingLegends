"""
Base interface for all states: it doesn't do anything in itself
but forces us to pass the right arguments to the methods below
and makes sure every State object had all of these methods.
"""
extends Node
class_name AbstractState

var character


signal finished(next_state_name , value)

# Initialize the state. E.g. change the animation
func enter(value = null,value2=null) -> void:
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
