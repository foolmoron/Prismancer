class_name Character
extends Node3D

@onready var char_idle := $char_idle as MeshInstance3D 
@onready var char_active := $char_active as MeshInstance3D
@onready var bg_idle := $bg_idle as MeshInstance3D
@onready var bg_active := $bg_active as MeshInstance3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_state_active(false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_state_active(active: bool) -> void:
	char_idle.visible = not active
	char_active.visible = active
	bg_idle.visible = not active
	bg_active.visible = active
