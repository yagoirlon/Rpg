extends CharacterBody2D
class_name Enemy

@export var hp: int = 6
@export var speed: float = 120.0
@export var contact_damage: int = 1
@export var drop_potion_chance: float = 0.15
@export var xp_reward: int = 4
@export var coin_reward: int = 2

var target: Player

func _ready() -> void:
	var a := Area2D.new()
	var cs := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(22,22)
	cs.shape = shape
	a.add_child(cs)
	add_child(a)
	a.body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	if not target:
		target = get_tree().get_first_node_in_group("player") as Player
	if target:
		var dir := (target.global_position - global_position)
		if dir.length() > 4.0:
			velocity = dir.normalized() * speed
		else:
			velocity = Vector2.ZERO
	move_and_slide()

func take_damage(amount: int) -> void:
	hp -= amount
	if hp <= 0:
		_die()

func _die() -> void:
	if randf() <= drop_potion_chance:
		Game.add_item("Poção de Vida", 1)
	Game.gain_xp(xp_reward)
	Game.add_coins(coin_reward)
	queue_free()

func _on_body_entered(b):
	if b is Player:
		b.take_damage(contact_damage)
