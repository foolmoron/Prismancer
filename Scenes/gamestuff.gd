class_name GameStuff
extends Node3D

static var is_game_over := false

@export var side1: Side
@export var side2: Side

const TIME_SECS := 90.0
@onready var time_left := TIME_SECS
@onready var time_fill := $Separator/SeparatorFill as Node3D

var time_left_before_restart := 1.5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().change_scene_to_file("res://main.tscn")
	
	if is_game_over:
		time_left_before_restart -= delta
		if time_left_before_restart <= 0 and Input.is_key_pressed(KEY_SPACE):
			do_restart()
		return

	time_left -= delta
	time_fill.scale.y = time_left / TIME_SECS
	if time_left <= 0:
		game_over()

func game_over() -> void:
	$EndSound.play()
	is_game_over = true

	var side1s := 0
	var side2s := 0
	if side1.score_red > side2.score_red:
		side1.score_red_text.outline_modulate = Color.WHITE
		side1s += 1
	elif side2.score_red > side1.score_red:
		side2.score_red_text.outline_modulate = Color.WHITE
		side2s += 1
	if side1.score_grn > side2.score_grn:
		side1.score_grn_text.outline_modulate = Color.WHITE
		side1s += 1
	elif side2.score_grn > side1.score_grn:
		side2.score_grn_text.outline_modulate = Color.WHITE
		side2s += 1
	if side1.score_blu > side2.score_blu:
		side1.score_blu_text.outline_modulate = Color.WHITE
		side1s += 1
	elif side2.score_blu > side1.score_blu:
		side2.score_blu_text.outline_modulate = Color.WHITE
		side2s += 1
	
	$TouchDetector.visible = true
	$TouchDetector.process_mode = Node.PROCESS_MODE_INHERIT
	if side1s > side2s:
		$Player1Win.visible = true
		$Player1Win.process_mode = Node.PROCESS_MODE_INHERIT
	elif side2s > side1s:
		$Player2Win.visible = true
		$Player2Win.process_mode = Node.PROCESS_MODE_INHERIT
	else:
		$Tie.visible = true
		$Tie.process_mode = Node.PROCESS_MODE_INHERIT

func _on_touch_detector_gui_input(event:InputEvent) -> void:
	if time_left_before_restart <= 0 and event is InputEventScreenTouch:
		if (event as InputEventScreenTouch).pressed:
			do_restart()

func do_restart() -> void:
	LinePool.clear()
	is_game_over = false
	get_tree().reload_current_scene()
