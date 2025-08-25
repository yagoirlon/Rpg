extends Node2D
class_name Level

@export var world_size: Vector2i = Vector2i(1280, 720)
@export var enemy_count: int = 8
@export var spawn_area: Rect2 = Rect2(120,120,1000,480)
@export var has_exit: bool = true

var completed: bool = false

func _ready() -> void:
	_build_walls()
	_spawn_enemies()
	if has_exit: _spawn_exit()

func _build_walls() -> void:
	var wall_rects: Array[Rect2] = [
		Rect2(0, 0, world_size.x, 24),
		Rect2(0, 0, 24, world_size.y),
		Rect2(0, world_size.y-24, world_size.x, 24),
		Rect2(world_size.x-24, 0, 24, world_size.y),
		Rect2(300, 150, 600, 24),
		Rect2(600, 150, 24, 300),
		Rect2(220, 460, 700, 24),
	]
	for r in wall_rects:
		var body := StaticBody2D.new()
		var shape := CollisionShape2D.new()
		var rect := RectangleShape2D.new()
		rect.size = r.size
		shape.shape = rect
		body.position = r.position + r.size * 0.5
		body.add_child(shape)
		add_child(body)

func _spawn_enemies() -> void:
	for i in enemy_count:
		var e := preload("res://scripts/enemy.gd").new()
		e.position = Vector2(
			randf_range(spawn_area.position.x, spawn_area.position.y + spawn_area.size.y),
			randf_range(spawn_area.position.y, spawn_area.position.y + spawn_area.size.y)
		)
		add_child(e)

func _spawn_exit() -> void:
	var ex := Node2D.new()
	ex.name = "Exit"
	ex.position = Vector2(world_size.x - 80, world_size.y/2)
	var area := Area2D.new()
	var cs := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(28, 64)
	cs.shape = shape
	area.add_child(cs)
	ex.add_child(area)
	add_child(ex)
	area.area_entered.connect(_on_exit_entered)
	ex.set_meta("draw_rect", Rect2(-14,-32,28,64))

func _draw() -> void:
	# chão
	draw_rect(Rect2(0,0, world_size.x, world_size.y), Color(0.16,0.65,0.34))
	# saida
	var ex := get_node_or_null("Exit")
	if ex:
		var rect: Rect2 = ex.get_meta("draw_rect")
		draw_rect(rect.translated(ex.position), Color(0.2,0.2,0.8))

func _process(delta: float) -> void:
	queue_redraw()
	if not completed and _all_enemies_dead():
		Game.add_to_log("Área limpa! Vá até a saída.")
		completed = true

func _all_enemies_dead() -> bool:
	for n in get_children():
		if n is Enemy:
			return false
	return true

func _on_exit_entered(other: Area2D) -> void:
	if not completed: return
	Game.add_to_log("Avançando de fase...")
	get_tree().change_scene_to_file(Game.next_level())
