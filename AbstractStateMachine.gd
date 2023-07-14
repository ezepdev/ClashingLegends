"""
Base interface for a generic state machine
It handles initializing, setting the machine active or not
delegating _physics_process, _input calls to the State nodes,
and changing the current/active state.
"""
extends Node
class_name AbstractStateMachine

signal state_changed(current_state)

"""
You must set a starting node from the inspector or on
the node that inherits from this state machine interface
If you don't the game will crash (on purpose, so you won't 
forget to initialize the state machine)
"""
export (NodePath) var START_STATE
var states_map = {}

export (NodePath) var character_path: NodePath
var character: Node setget _set_character

var states_stack:Array = []
var current_state = null
var _active:bool = false setget set_active


func _ready() -> void:
	set_physics_process(false)
	set_process_input(false)
	call_deferred("_initialize")

func _initialize() -> void:
	if !character_path.is_empty():
		var ch: Node = get_node_or_null(character_path)
		if ch != null:
			self.character = ch


func _set_character(_character: Node) -> void:
	character = _character
	if not START_STATE:
		START_STATE = get_child(0).get_path()
	for child in get_children():
		child.connect("finished", self, "_change_state")
		child.character = character
	initialize(get_node(START_STATE))


func initialize(start_state) -> void:
	set_active(true)
	states_stack.push_front(start_state)
	current_state = states_stack[0]
	current_state.enter()


func set_active(active: bool) -> void:
	_active = active
	set_physics_process(active)
	set_process_input(active)
	if not _active:
		states_stack = []
		current_state = null


func _input(event:InputEvent) -> void:
	current_state.handle_input(event)


func _physics_process(delta: float) -> void:
	current_state.update(delta)


func _on_animation_finished(anim_name: String = "") -> void:
	if not _active:
		return
	current_state._on_animation_finished(anim_name)


func _change_state(state_name: String , value = null, value2 = null) -> void:
	if not _active:
		return
	current_state.exit()
	
	if state_name == "previous":
		states_stack.pop_front()
	else:
		states_stack[0] = states_map[state_name]
	
	current_state = states_stack[0]
	emit_signal("state_changed", current_state)
	
	if state_name != "previous":
		current_state.enter(value , value2)
	print(state_name)
