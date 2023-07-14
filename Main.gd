extends Node

onready var player1 = $Player1
onready var player2 = $Player2
onready var menu_pause = $UI/Menu/pause_scene
var backgroundMusic: Array = ["res://audio/Background songs/1UP 👾 (16-Bit Arcade No Copyright Music) [IkiBtQ_6Bug].mp3", "res://audio/Background songs/Adventure Quest 👾 (16-Bit Arcade No Copyright Music) [fPElbr1rS7g].mp3", "res://audio/Background songs/Allammo 👾 (16-Bit Arcade No Copyright Music) [vZpqjas1YYU].mp3", "res://audio/Background songs/Allstars 👾 (16-Bit Arcade No Copyright Music) [AvZi08v25wI].mp3", "res://audio/Background songs/Battle Arcade 👾 (16-Bit Arcade No Copyright Music) [v9cb0DOVBHA].mp3", "res://audio/Background songs/Continue 👾 (16-Bit Arcade No Copyright Music) [ablGbOIebSE].mp3", "res://audio/Background songs/Highscore 👾 (16-Bit Arcade No Copyright Music) [M4bGQfu6slw].mp3", "res://audio/Background songs/IDDQD 👾 (16-Bit Arcade No Copyright Music) [8Be_ZqfB8jg].mp3", "res://audio/Background songs/IDKFA 👾 (16-Bit Arcade No Copyright Music) [Y873NKTgb6Y].mp3", "res://audio/Background songs/Jump High 👾 (16-Bit Arcade No Copyright Music) [STSN6TMCKxQ].mp3", "res://audio/Background songs/Level Up 👾 (16-Bit Arcade No Copyright Music) [vG8AGaei8nc].mp3", "res://audio/Background songs/Mana Refill 👾 (16-Bit Arcade No Copyright Music) [_71_Z6YCpkY].mp3", "res://audio/Background songs/Pixel Party 👾 (16-Bit Arcade No Copyright Music) [V4vxwBEcKzc].mp3", "res://audio/Background songs/Player 1 👾 (16-Bit Arcade No Copyright Music) [AA2G7e8niSs].mp3", "res://audio/Background songs/Press Play 👾 (16-Bit Arcade No Copyright Music) [Wth5wynwxq0].mp3", "res://audio/Background songs/Punch Out 👾 (16-Bit Arcade No Copyright Music) [PZdKadG4l-k].mp3", "res://audio/Background songs/Shoryuken 👾 (16-Bit Arcade No Copyright Music) [pAZLAYVoCcY].mp3", "res://audio/Background songs/Sonic Boom 👾 (16-Bit Arcade No Copyright Music) [aJSafqknXsw].mp3", "res://audio/Background songs/Uppercut 👾 (16-Bit Arcade No Copyright Music) [I7ZoBe6O0oo].mp3", "res://audio/Background songs/Voyage 👾 (16-Bit Arcade No Copyright Music) [qqaChAqCJiU].mp3"]
var audioPlayer: AudioStreamPlayer
var rain = load("res://shaders/RainShader.tres")

func _ready():
	audioPlayer = $Background
	randomize()
	playRandomMap()
	playRandomBackgroundMusic()
	player1.initialize(self , 1)
	player2.initialize(self , 2)
	
func _process(delta):
	if (Input.is_action_just_pressed("pause")):
		get_tree().set_pause(true);
		menu_pause.visible = true;
		menu_pause.get_node("ContinueBtn").re_focus()
		
func playRandomBackgroundMusic():
	var randomIndex = rand_range(0, backgroundMusic.size())
	print(randomIndex)
	audioPlayer.stream = load(backgroundMusic[randomIndex])
	audioPlayer.play()

func playRandomMap():
	var randomNumber = rand_range(0, 100)  # Genera un número aleatorio entre 0 y 100
	if randomNumber < 70: 
		var new_material = ShaderMaterial.new()
		$CanvasLayer/TextureRect.material = new_material
		$CanvasLayer/TextureRect.modulate = Color(1,1,1,1)
		$ColorRect.modulate = Color(1,1,1,1)
	else:
		pass

	
	
