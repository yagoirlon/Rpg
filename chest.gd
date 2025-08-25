extends Area2D
class_name Chest

@export var loot: Array[String] = ["Poção de Vida", "Moeda"]
var opened: bool = false

func _ready() -> void:
	var cs := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(24,24)
	cs.shape = shape
	add_child(cs)

func interact() -> void:
	if opened:
		Game.add_to_log("Baú vazio.")
		return
	opened = true
	for item in loot:
		if item == "Moeda":
			Game.add_coins(1)
		else:
			Game.add_item(item, 1)
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(-12,-12,24,24), Color(0.83,0.33,0.0) if not opened else Color(0.56,0.27,0.68))
