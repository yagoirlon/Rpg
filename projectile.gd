extends Area2D
class_name Projectile

@export var speed: float = 320.0
@export var direction: Vector2 = Vector2(1,0)
@export var damage: int = 1
@export var lifetime: float = 4.0

func _ready() -> void:
	var cs := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(10,10)
	cs.shape = shape
	add_child(cs)
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	lifetime -= delta
	if lifetime <= 0.0: queue_free()
	position += direction * speed * delta
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(-5,-5,10,10), Color(1,1,0.4))

func _on_body_entered(b):
	if b is Player:
		b.take_damage(damage)
		queue_free()
