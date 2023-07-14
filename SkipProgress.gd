extends Control

onready var tween = $Tween
onready var lifebar = $TextureProgress
var progressbar: float
var decrementProgress = false
var new_scene;
func _ready():
	progressbar = 0
	new_scene = preload("res://Main.tscn")

func _process(delta):
	if (decrementProgress):
		update_progress(clamp(progressbar-100,0,1000))
	if (Input.is_action_pressed("escape")):
		update_progress(clamp(progressbar+100,0,1000))
		if (progressbar > 980):
			get_tree().change_scene_to(new_scene)
	if (Input.is_action_just_released("escape")):
		decrementProgress = true
	lifebar.value = progressbar
	
	
	
func update_progress(new_value):
	tween.interpolate_property(self, "progressbar", progressbar, new_value, 0.15, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	if not tween.is_active():
		tween.start()
