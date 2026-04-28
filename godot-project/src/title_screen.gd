extends Control

func _ready():
	# Set up UI
	var title_label = Label.new()
	title_label.text = "TEMPLE GUARDIAN"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 48)
	title_label.add_theme_color_override("font_color", Color.GOLD)
	title_label.position = Vector2(0, 200)
	title_label.size = Vector2(720, 60)
	add_child(title_label)
	
	var subtitle = Label.new()
	subtitle.text = "ปกป้องวัดไทยจากผีร้าย"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 24)
	subtitle.position = Vector2(0, 280)
	subtitle.size = Vector2(720, 40)
	add_child(subtitle)
	
	# Play button
	var play_btn = Button.new()
	play_btn.text = "เริ่มเล่น"
	play_btn.position = Vector2(260, 500)
	play_btn.size = Vector2(200, 60)
	play_btn.pressed.connect(_on_play_pressed)
	add_child(play_btn)
	
	# Leaderboard button
	var lb_btn = Button.new()
	lb_btn.text = "ตารางคะแนน"
	lb_btn.position = Vector2(260, 580)
	lb_btn.size = Vector2(200, 60)
	lb_btn.pressed.connect(_on_leaderboard_pressed)
	add_child(lb_btn)
	
	# Background color
	var bg = ColorRect.new()
	bg.color = Color(0.1, 0.05, 0.02)
	bg.size = Vector2(720, 1280)
	bg.z_index = -1
	add_child(bg)

func _on_play_pressed():
	get_tree().change_scene_to_file("res://src/gameplay.tscn")

func _on_leaderboard_pressed():
	get_tree().change_scene_to_file("res://src/leaderboard.tscn")
