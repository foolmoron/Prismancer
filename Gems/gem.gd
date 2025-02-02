class_name Gem
extends Node3D

enum GEM_TYPE {
	SPHERE,
	TRI_LEFT,
	TRI_RIGHT,
	STAR,
}

@export var type: GEM_TYPE

@onready var mesh := $mesh as MeshInstance3D

@onready var speed := Vector2(randf_range(2.1, 2.6), randf_range(2.1, 2.6))
@onready var t_x := randf_range(0.0, 2.0)
@onready var t_z := randf_range(0.0, 2.0)
@onready var base_x := mesh.rotation_degrees.x
@onready var base_z := mesh.rotation_degrees.z

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	t_x += delta 
	t_z += delta
	mesh.rotation_degrees.x = base_x + sin(t_x * speed.x) * 25
	mesh.rotation_degrees.z = base_z + sin(t_z * speed.y) * 12
	pass
