extends CharacterBody2D
class_name Boss

@export var hp: int = 80
@export var speed: float = 140.0
@export var contact_damage: int = 2

var phase: int = 1
var attack_timer: float = 0.0
var target: Player

func _ready() -> void:
	set_physics_process(true)

func _physics_process(delta: float) -> void:
	if not target:
		target = get_tree().get_first_node_in_group("player") as Player
	
	if target:
		var dir := (target.global_position - global_position)
		if dir.length() > 8.0:
			velocity = dir.normalized() * speed
		else:
			velocity = Vector2.ZERO
	move_and_slide()
	
	attack_timer -= delta
	if attack_timer <= 0.0 and target:
		attack_timer = 1.0 if phase == 1 else 0.75
		_shoot_at(target.global_position)

func _shoot_at(pos: Vector2) -> void:
	var p := preload("res://scripts/projectile.gd").new()
	p.global_position = global_position
	p.direction = (pos - global_position).normalized()
	p.speed = 300.0 if phase == 1 else 360.0
	p.damage = 2 if phase == 1 else 3
	get_tree().current_scene.add_child(p)

func take_damage(amount: int) -> void:
	hp -= amount
	if hp <= 40 and phase == 1:
		phase = 2
		Game.add_to_log("O Guardião despertou sua fúria!")
	if hp <= 0:
		Game.add_to_log("Boss derrotado! Vitória!")
		Game.gain_xp(40)
		Game.add_coins(30)
		get_tree().change_scene_to_file("res://scenes/menu.tscn")
