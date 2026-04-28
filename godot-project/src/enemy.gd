extends Node2D
class_name Enemy

var hp: int = 10
var max_hp: int = 10
var speed: float = 50.0
var damage: int = 1
var enemy_type: String = "ghost"
@onready var shape: ColorRect = $ColorRect

func _ready():
	shape.color = Color(0.8, 0.2, 1.0, 1.0) # ม่วง-ชมพู = ผี

func _process(delta):
	position.x -= speed * delta

func take_damage(amount: int) -> bool:
	hp -= amount
	if hp <= 0:
		queue_free()
		return true
	# Flash white
	shape.color = Color.WHITE
	await get_tree().create_timer(0.1).timeout
	if is_instance_valid(self):
		shape.color = Color(0.8, 0.2, 1.0, 1.0)
	return false

func setup(type: String, wave_multiplier: float = 1.0):
	enemy_type = type
	match type:
		"ghost":
			max_hp = int(10 * wave_multiplier)
			speed = 50.0
			damage = 1
			shape.color = Color(0.8, 0.2, 1.0, 1.0)
		"zombie":
			max_hp = int(25 * wave_multiplier)
			speed = 30.0
			damage = 2
			shape.color = Color(0.3, 0.7, 0.2, 1.0)
		"fast_ghost":
			max_hp = int(8 * wave_multiplier)
			speed = 90.0
			damage = 1
			shape.color = Color(0.9, 0.5, 0.9, 1.0)
		"boss":
			max_hp = int(100 * wave_multiplier)
			speed = 25.0
			damage = 5
			shape.color = Color(0.9, 0.0, 0.0, 1.0)
			shape.size = Vector2(50, 50)
	hp = max_hp
