extends Node
class_name Game

var inventory: Dictionary = {}
var coins: int = 0

var player_hp: int = 14
var player_hp_max: int = 14
var player_attack: int = 2
var player_attack_cd: float = 0.30

var xp: int = 0
var level: int = 1
var next_xp: int = 10

var levels: Array[String] = [
	"res://scenes/level1.tscn",
	"res://scenes/level2.tscn",
	"res://scenes/boss_level.tscn"
]
var current_level_index: int = 0

var log: Array[String] = []

func _ready():
	add_to_log("Bem-vindo a Eldergrove Chronicles!")

func reset_run() -> void:
	inventory.clear()
	coins = 0
	player_hp_max = 14
	player_hp = player_hp_max
	player_attack = 2
	player_attack_cd = 0.30
	xp = 0
	level = 1
	next_xp = 10
	current_level_index = 0
	add_to_log("Nova jornada iniciada.")

func add_to_log(msg: String) -> void:
	log.append(msg)
	if log.size() > 7:
		log = log.slice(log.size()-7, 7)

func add_item(name: String, qty: int = 1) -> void:
	inventory[name] = (inventory.get(name, 0) as int) + qty
	add_to_log("Pegou %s x%d" % [name, qty])

func consume_item(name: String, qty: int = 1) -> bool:
	var have := inventory.get(name, 0)
	if have >= qty:
		inventory[name] = have - qty
		if inventory[name] <= 0:
			inventory.erase(name)
		return true
	return false

func use_potion() -> void:
	if consume_item("Poção de Vida", 1):
		player_hp = min(player_hp + 6, player_hp_max)
		add_to_log("Poção usada (+6 HP).")
	else:
		add_to_log("Sem poção.")

func gain_xp(amount: int) -> void:
	xp += amount
	add_to_log("Ganhou %d XP." % amount)
	while xp >= next_xp:
		xp -= next_xp
		level += 1
		player_hp_max += 2
		player_attack += 1
		player_hp = player_hp_max
		next_xp = int(next_xp * 1.4) + 5
		add_to_log("Subiu para o nível %d! ATK+1, HP+2." % level)

func next_level() -> String:
	current_level_index += 1
	if current_level_index >= levels.size():
		current_level_index = levels.size()-1
	return levels[current_level_index]

func add_coins(amount: int) -> void:
	coins += amount
	add_to_log("+%d moedas (total %d)" % [amount, coins])

func try_buy(item: String, price: int) -> bool:
	if coins >= price:
		coins -= price
		add_item(item, 1)
		add_to_log("Comprou %s por %d" % [item, price])
		return true
	add_to_log("Moedas insuficientes.")
	return false
