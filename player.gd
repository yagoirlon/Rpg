extends CharacterBody2D
class_name Player

@export var speed: float = 210.0

var touch_target: Vector2 = Vector2.ZERO
var moving_to_touch: bool = false
var attack_cooldown: float = 0.0

func _ready() -> void:
	set_physics_process(true)
	add_to_group("player")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		if event is InputEventScreenTouch and not event.pressed:
			return
		touch_target = event.position
		moving_to_touch = true

func _physics_process(delta: float) -> void:
	attack_cooldown = max(0.0, attack_cooldown - delta)
	var input_vec := Vector2.ZERO
	if Input.is_action_pressed("move_left"): input_vec.x -= 1.0
	if Input.is_action_pressed("move_right"): input_vec.x += 1.0
	if Input.is_action_pressed("move_up"): input_vec.y -= 1.0
	if Input.is_action_pressed("move_down"): input_vec.y += 1.0
	
	if input_vec.length() > 0.0:
		moving_to_touch = false
		velocity = input_vec.normalized() * speed
	elif moving_to_touch:
		var dir := (touch_target - global_position)
		if dir.length() > 6.0:
			velocity = dir.normalized() * speed
		else:
			velocity = Vector2.ZERO
			moving_to_touch = false
	else:
		velocity = Vector2.ZERO
	
	move_and_slide()
	
	if Input.is_action_just_pressed("attack"):
		try_attack()

func try_attack() -> void:
	if attack_cooldown > 0.0: return
	attack_cooldown = Game.player_attack_cd
	var radius := 44.0
	var space := get_world_2d().direct_space_state
	var result := space.intersect_circle(global_position, radius, [], 32, true, true)
	for r in result:
		var c := r.get("collider", null)
		if c and c.has_method("take_damage"):
			c.take_damage(Game.player_attack)
			Game.add_to_log("Ataque causou %d dano." % Game.player_attack)
			break

func take_damage(amount: int) -> void:
	Game.player_hp -= amount
	if Game.player_hp <= 0:
		Game.player_hp = 0
		Game.add_to_log("Você caiu em batalha.")
		get_tree().change_scene_to_file("res://scenes/menu.tscn")
