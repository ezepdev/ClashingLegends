extends CanvasLayer

onready var doubleJumpVideo = $DoubleJumpVideo
onready var dashJumpVideo = $DashMoveVideo

func start():
	$Timer.start()

func _on_DoubleJumpVideo_finished():
	doubleJumpVideo.play()
	
func _on_DashMoveVideo_finished():
	dashJumpVideo.play()
