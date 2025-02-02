class_name Orb
extends Node3D

@onready var color_mesh := $quadcolor as MeshInstance3D

static var COLOR_MAP := {
    Cell.COLOR.RED: Color(1, 0, 0),
    Cell.COLOR.GREEN: Color(0, 1, 0),
    Cell.COLOR.BLUE: Color(0, 0, 1),
    Cell.COLOR.YELLOW: Color(1, 1, 0),
    Cell.COLOR.MAGENTA: Color(1, 0, 1),
    Cell.COLOR.CYAN: Color(0, 1, 1),
    Cell.COLOR.WHITE: Color(1, 1, 1),
}

func _ready() -> void:
    color_mesh.mesh.material.set_shader_parameter("color", COLOR_MAP[Cell.COLOR.YELLOW])

func set_color(color: Cell.COLOR) -> void:
    color_mesh.mesh.material.set_shader_parameter("color", COLOR_MAP[color])
