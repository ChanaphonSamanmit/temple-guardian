extends Node2D

enum State { PLAYING, PAUSED, GAME_OVER }
var current_state = State.PLAYING

const LANE_COUNT = 5
const LANE_HEIGHT = 100
const TEMPLE_X = 80
const SPAWN_X = 720
const MANA_REGEN = 8.0
const MAX_MANA = 100

var mana: float = 50.0
var score: int = 0
var wave: int = 1
var temple_hp: int = 100
var enemies_killed: int = 0

var lanes_y: Array = []
var enemies: Array = []
var guardians: Array = []

var enemy_spawn_timer: float = 0.0
var enemy_spawn_interval: float = 2.0

# Guardian type configs
var guardian_configs = {
	"melee": {"cost": 20, "color": Color(0.9, 0.1, 0.1)},
	"ranged": {"cost": 30, "color": Color(0.1, 0.1, 0.9)},
	"tank": {"cost": 40, "color": Color(0.1, 0.7, 0.1)}
}

@onready var mana_bar: ProgressBar = $UI/ManaBar
@onready var hp_bar: ProgressBar = $UI/HPBar
@onready var score_label: Label = $UI/ScoreLabel
@onready var wave_label: Label = $UI/WaveLabel

var enemy_scene = preload("res://src/enemy.tscn")
var guardian_scene = preload("res://src/guardian.tscn")

func _ready():
	for i in range(LANE_COUNT):
		lanes_y.append(200 + i * LANE_HEIGHT)
	Input.set_use_accumulated_input(false)
	update_ui()

func update_ui():
	mana_bar.value = mana
	hp_bar.value = temple_hp
	score_label.text = "Score: %d" % score
	wave_label.text = "Wave: %d" % wave

func _process(delta):
	if current_state != State.PLAYING:
		return
	
	# Mana regen
	mana = min(mana + MANA_REGEN * delta, MAX_MANA)
	mana_bar.value = mana
	
	# Spawn enemies
	enemy_spawn_timer += delta
	if enemy_spawn_timer >= enemy_spawn_interval:
		_spawn_enemy()
		enemy_spawn_timer = 0.0
		enemy_spawn_interval = max(0.5, 2.0 - wave * 0.08)
	
	# Update enemies + guardians
	_update_combat(delta)
	
	# Check wave progression
	if enemies_killed >= wave * 10:
		wave += 1
		wave_label.text = "Wave: %d" % wave
		enemies_killed = 0

func _update_combat(delta):
	# Guardian attacks
	for guardian in guardians:
		if not is_instance_valid(guardian) or guardian.is_dead:
			continue
		guardian.try_attack()
	
	# Clean up dead enemies
	for i in range(enemies.size() - 1, -1, -1):
		if not is_instance_valid(enemies[i]) or enemies[i].hp <= 0:
			if is_instance_valid(enemies[i]) and enemies[i].hp <= 0:
				score += 10
				enemies_killed += 1
				score_label.text = "Score: %d" % score
			if is_instance_valid(enemies[i]):
				enemies[i].queue_free()
			enemies.remove_at(i)
	
	# Clean up dead guardians
	for i in range(guardians.size() - 1, -1, -1):
		if not is_instance_valid(guardians[i]) or guardians[i].is_dead:
			if is_instance_valid(guardians[i]):
				guardians[i].queue_free()
			guardians.remove_at(i)
	
	# Check enemies reaching temple
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		if enemy.position.x <= TEMPLE_X:
			temple_hp -= enemy.damage
			hp_bar.value = temple_hp
			enemy.queue_free()
			if temple_hp <= 0:
				_game_over()
				return
	
	# Check wave
	if enemies_killed >= wave * 10:
		wave += 1
		wave_label.text = "Wave: %d" % wave
		enemies_killed = 0

func _spawn_enemy():
	var lane_idx = randi() % LANE_COUNT
	var enemy = enemy_scene.instantiate()
	enemy.position = Vector2(SPAWN_X, lanes_y[lane_idx] + LANE_HEIGHT / 2)
	add_child(enemy)
	enemies.append(enemy)
	
	# Pick enemy type based on wave
	if wave >= 5 and randf() < 0.1:
		enemy.setup("boss", wave * 0.5)
	elif wave >= 3 and randf() < 0.2:
		enemy.setup("zombie", wave * 0.5)
	elif wave >= 2 and randf() < 0.3:
		enemy.setup("fast_ghost", wave * 0.5)
	else:
		enemy.setup("ghost", wave * 0.5)

func _place_guardian(touch_pos: Vector2):
	var lane_idx = -1
	for i in range(LANE_COUNT):
		if touch_pos.y >= lanes_y[i] and touch_pos.y < lanes_y[i] + LANE_HEIGHT:
			lane_idx = i
			break
	if lane_idx == -1:
		return
	
	var g_type = "melee"
	if touch_pos.x > 400:
		g_type = "tank"
	elif touch_pos.x > 250:
		g_type = "ranged"
	
	var stats = guardian_configs[g_type]
	if mana < stats.cost:
		return
	
	mana -= stats.cost
	mana_bar.value = mana
	
	var guardian = guardian_scene.instantiate()
	guardian.position = Vector2(min(touch_pos.x, 600), lanes_y[lane_idx] + LANE_HEIGHT / 2)
	guardian.setup(g_type)
	add_child(guardian)
	guardians.append(guardian)

func _input(event):
	if current_state != State.PLAYING:
		return
	if event is InputEventScreenTouch and event.pressed:
		_place_guardian(event.position)
	elif event is InputEventMouseButton and event.pressed:
		_place_guardian(event.position)

func _game_over():
	current_state = State.GAME_OVER
	
	# Save high score
	var best = 0
	if FileAccess.file_exists("user://scores.save"):
		var f = FileAccess.open("user://scores.save", FileAccess.READ)
		if f:
			best = f.get_32()
			f.close()
	if score > best:
		var f = FileAccess.open("user://scores.save", FileAccess.WRITE)
		if f:
			f.store_32(score)
			f.close()
	
	# Show game over
	var overlay = ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.7)
	overlay.size = Vector2(720, 1280)
	add_child(overlay)
	
	var go_label = Label.new()
	go_label.text = "GAME OVER"
	go_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	go_label.add_theme_font_size_override("font_size", 72)
	go_label.add_theme_color_override("font_color", Color.RED)
	go_label.position = Vector2(0, 350)
	go_label.size = Vector2(720, 100)
	add_child(go_label)
	
	var score_text = Label.new()
	score_text.text = "Score: %d | Wave: %d" % [score, wave]
	score_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	score_text.add_theme_font_size_override("font_size", 40)
	score_text.position = Vector2(0, 480)
	score_text.size = Vector2(720, 60)
	add_child(score_text)
	
	var restart_btn = Button.new()
	restart_btn.text = "เล่นอีกครั้ง"
	restart_btn.position = Vector2(210, 600)
	restart_btn.size = Vector2(300, 80)
	restart_btn.add_theme_font_size_override("font_size", 36)
	restart_btn.pressed.connect(func(): get_tree().reload_current_scene())
	add_child(restart_btn)

	var menu_btn = Button.new()
	menu_btn.text = "เมนูหลัก"
	menu_btn.position = Vector2(210, 710)
	menu_btn.size = Vector2(300, 80)
	menu_btn.add_theme_font_size_override("font_size", 36)
	menu_btn.pressed.connect(func(): get_tree().change_scene_to_file("res://src/title_screen.tscn"))
	add_child(menu_btn)
