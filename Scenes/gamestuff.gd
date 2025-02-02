class_name GameStuff
extends Node3D

static var is_game_over := false

const TIME_SECS := 90.0
@onready var time_left := TIME_SECS
@onready var time_fill := $Separator/SeparatorFill as Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().change_scene_to_file("res://main.tscn")
	
	if is_game_over:
		return

	time_left -= delta
	time_fill.scale.y = time_left / TIME_SECS
	if time_left <= 0:
		game_over()

func game_over() -> void:
	$EndSound.play()
	is_game_over = true
