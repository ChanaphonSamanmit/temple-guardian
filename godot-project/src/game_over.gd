extends Control

@onready var score_label: Label = %FinalScoreLabel
@onready var wave_label: Label = %FinalWaveLabel
@onready var restart_btn: Button = %RestartBtn
@onready var menu_btn: Button = %MenuBtn

var final_score: int = 0
var final_wave: int = 0

func _ready():
	score_label.text = "คะแนน: " + str(final_score)
	wave_label.text = "Wave: " + str(final_wave)
	restart_btn.pressed.connect(_on_restart)
	menu_btn.pressed.connect(_on_menu)

func setup(score: int, wave: int):
	final_score = score
	final_wave = wave
	if score_label:
		score_label.text = "คะแนน: " + str(final_score)
	if wave_label:
		wave_label.text = "Wave: " + str(final_wave)

func _on_restart():
	get_tree().change_scene_to_file("res://src/gameplay.tscn")

func _on_menu():
	get_tree().change_scene_to_file("res://src/title_screen.tscn")
