extends Node2D

@onready var shop: Area2D = $ShopArea
@onready var portal: Area2D = $Portal
@onready var panel: ColorRect = $UI/ShopPanel
@onready var btn_buy: Button = $UI/ShopPanel/BtnBuyPotion
@onready var btn_close: Button = $UI/ShopPanel/BtnCloseShop

var player: Player

func _ready() -> void:
	# simple ground & UI draw handled via _draw
	btn_buy.pressed.connect(_buy_potion)
	btn_close.pressed.connect(_close_shop)
	shop.area_entered.connect(_on_area)
	portal.area_entered.connect(_on_area)
	
	player = preload("res://scripts/player.gd").new()
	player.add_to_group("player")
	player.position = Vector2(160,360)
	add_child(player)

func _buy_potion() -> void:
	Game.try_buy("Poção de Vida", 5)

func _close_shop() -> void:
	panel.visible = false

func _on_area(a: Area2D) -> void:
	# player touch triggers
	if panel.visible: return
	panel.visible = true

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("interact"):
		panel.visible = not panel.visible

func _draw() -> void:
	# ground
	draw_rect(Rect2(0,0,1280,720), Color(0.12,0.55,0.30))
	# shop marker
	draw_rect(Rect2(276,276,48,48), Color(0.6,0.4,0.1))
	# portal marker
	draw_rect(Rect2(956,318,48,84), Color(0.2,0.2,0.8))

func _unhandled_input(event):
	# Enter level when near portal and pressing interact
	if event.is_action_pressed("interact"):
		var d := (player.global_position - Vector2(980,360)).length()
		if d <= 80.0:
			get_tree().change_scene_to_file("res://scenes/main.tscn")
