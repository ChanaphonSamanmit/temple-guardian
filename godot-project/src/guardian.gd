extends Node2D
class_name Guardian

var g_type: String = "melee"
var hp: int = 20
var max_hp: int = 20
var attack_range: float = 120.0
var attack_damage: int = 5
var attack_speed: float = 1.0 # attacks per sec
var is_attacking: bool = false
var is_dead: bool = false
var attack_timer: float = 0.0

@onready var sprite: ColorRect = $ColorRect
@onready var range_indicator: ReferenceRect = $RangeIndicator
@onready var health_bar: ProgressBar = $HealthBar

func _ready():
	range_indicator.size = Vector2(attack_range * 2, attack_range * 2)
	range_indicator.position = -range_indicator.size / 2
	update_health_display()

func _process(delta):
	if is_dead:
		return
	attack_timer += delta
	if attack_timer >= 1.0 / attack_speed:
		attack_timer = 0.0
		try_attack()

func try_attack():
	var targets = get_tree().get_nodes_in_group("enemies")
	var closest = null
	var closest_dist = attack_range
	for enemy in targets:
		if not is_instance_valid(enemy):
			continue
		var d = position.distance_to(enemy.position)
		if d < closest_dist:
			closest_dist = d
			closest = enemy
	if closest != null:
		perform_attack(closest)

func perform_attack(target: Enemy):
	if g_type == "ranged":
		# Spawn projectile
		var proj = load("res://src/projectile.tscn").instantiate()
		proj.global_position = global_position
		proj.target = target
		proj.damage = attack_damage
		get_tree().current_scene.add_child(proj)
	else:
		# Melee / Tank - instant damage
		if is_instance_valid(target):
			target.take_damage(attack_damage)
			# Flash effect
			sprite.modulate = Color.WHITE
			await get_tree().create_timer(0.05).timeout
			if is_instance_valid(sprite):
				sprite.modulate = Color(1, 1, 1, 1)

func take_damage(amount: int):
	hp -= amount
	update_health_display()
	if hp <= 0:
		die()

func update_health_display():
	health_bar.max_value = max_hp
	health_bar.value = hp
	health_bar.visible = hp < max_hp

func die():
	is_dead = true
	# Death animation
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	await tween.finished
	queue_free()

func setup(type: String):
	g_type = type
	match type:
		"melee":
			max_hp = 20; hp = 20
			attack_range = 120.0
			attack_damage = 5
			attack_speed = 1.0
			sprite.color = Color(0.9, 0.1, 0.1, 1.0)
		"ranged":
			max_hp = 15; hp = 15
			attack_range = 250.0
			attack_damage = 4
			attack_speed = 1.2
			sprite.color = Color(0.1, 0.1, 0.9, 1.0)
		"tank":
			max_hp = 50; hp = 50
			attack_range = 100.0
			attack_damage = 3
			attack_speed = 0.7
			sprite.color = Color(0.1, 0.7, 0.1, 1.0)
	update_health_display()
