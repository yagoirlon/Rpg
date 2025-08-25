extends Node2D

@onready var level_container: Node = $LevelContainer
@onready var hp_text: Label = $UI/HUD/HPText
@onready var hp_bar: ColorRect = $UI/HUD/HPBar
@onready var stats: Label = $UI/HUD/Stats
@onready var log_text: RichTextLabel = $UI/HUD/LogText
@onready var inv_panel: ColorRect = $UI/InventoryPanel
@onready var inv_label: Label = $UI/InventoryPanel/InventoryLabel
@onready var btn_attack: Button = $UI/HUD/Buttons/BtnAttack
@onready var btn_interact: Button = $UI/HUD/Buttons/BtnInteract
@onready var btn_inventory: Button = $UI/HUD/Buttons/BtnInventory
@onready var btn_potion: Button = $UI/HUD/Buttons/BtnPotion
@onready var btn_pause: Button = $UI/HUD/Buttons/BtnPause

func _ready() -> void:
	btn_attack.pressed.connect(_on_attack)
	btn_interact.pressed.connect(_on_interact)
	btn_inventory.pressed.connect(_on_inventory)
	btn_potion.pressed.connect(Game.use_potion)
	btn_pause.pressed.connect(_on_pause)
	_load_level(Game.levels[Game.current_level_index])
	_update_ui()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("inventory"):
		_toggle_inventory()
	if Input.is_action_just_pressed("interact"):
		_try_interact()
	if Input.is_action_just_pressed("use_potion"):
		Game.use_potion()
	if Input.is_action_just_pressed("attack"):
		_on_attack()
	if Input.is_action_just_pressed("pause"):
		_on_pause()
	_update_ui()

func _on_attack() -> void:
	var p := get_tree().get_first_node_in_group("player") as Player
	if p: p.try_attack()

func _on_interact() -> void:
	_try_interact()

func _on_inventory() -> void:
	_toggle_inventory()

func _on_pause() -> void:
	get_tree().paused = not get_tree().paused

func _toggle_inventory() -> void:
	inv_panel.visible = not inv_panel.visible

func _try_interact() -> void:
	var player := get_tree().get_first_node_in_group("player") as Player
	if not player: return
	var closest: Chest = null
	var best_d := 1e9
	for c in get_tree().get_nodes_in_group("chests"):
		var d := (c.global_position - player.global_position).length()
		if d < best_d: best_d = d; closest = c
	if closest and best_d <= 48.0:
		closest.interact()
	else:
		Game.add_to_log("Nada para interagir.")

func _update_ui() -> void:
	hp_text.text = "HP: %d/%d" % [Game.player_hp, Game.player_hp_max]
	var frac := max(0.0, float(Game.player_hp) / float(Game.player_hp_max))
	hp_bar.size.x = 200.0 * frac
	stats.text = "Nível %d | XP %d/%d | Moedas %d | ATK %d" % [Game.level, Game.xp, Game.next_xp, Game.coins, Game.player_attack]
	var bb := ""
	for line in Game.log: bb += line + "\n"
	log_text.text = bb
	if inv_panel.visible:
		var s := "Inventário:\n"
		if Game.inventory.size() == 0: s += "- vazio -"
		for k in Game.inventory.keys():
			s += "%s x%d\n" % [k, Game.inventory[k]]
		inv_label.text = s

func _load_level(path: String) -> void:
	level_container.free()
	var container := Node.new()
	container.name = "LevelContainer"
	add_child(container); move_child(container, 0)
	level_container = container
	
	var lvl := load(path).instantiate()
	level_container.add_child(lvl)
	
	var player := preload("res://scripts/player.gd").new()
	player.position = Vector2(120, 120)
	level_container.add_child(player)
	
	# Baús
	var c1 := preload("res://scripts/chest.gd").new()
	c1.position = Vector2(420, 180)
	level_container.add_child(c1); c1.add_to_group("chests")
	var c2 := preload("res://scripts/chest.gd").new()
	c2.position = Vector2(900, 520); c2.loot = ["Poção de Vida", "Moeda", "Moeda"]
	level_container.add_child(c2); c2.add_to_group("chests")
