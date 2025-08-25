extends Control

@onready var btn_play: Button = $Buttons/BtnPlay
@onready var btn_quit: Button = $Buttons/BtnQuit

func _ready() -> void:
	btn_play.pressed.connect(_on_play)
	btn_quit.pressed.connect(get_tree().quit)

func _on_play() -> void:
	Game.reset_run()
	get_tree().change_scene_to_file("res://scenes/hub.tscn")
