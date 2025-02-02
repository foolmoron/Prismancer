extends Node

@onready var line_red: PackedScene = load("res://Lines/line_red.tscn")
@onready var line_green: PackedScene = load("res://Lines/line_green.tscn")
@onready var line_blue: PackedScene = load("res://Lines/line_blue.tscn")
@onready var line_yellow: PackedScene = load("res://Lines/line_yellow.tscn")
@onready var line_magenta: PackedScene = load("res://Lines/line_magenta.tscn")
@onready var line_cyan: PackedScene = load("res://Lines/line_cyan.tscn")
@onready var line_white: PackedScene = load("res://Lines/line_white.tscn")

var red: Array = []
var green: Array = []
var blue: Array = []
var yellow: Array = []
var magenta: Array = []
var cyan: Array = []
var white: Array = []

func obtain(color: Cell.COLOR, parent: Node3D) -> Node3D:
	var line: Node3D
	match color:
		Cell.COLOR.RED:
			if red.size() == 0:
				release(color, line_red.instantiate())
			line = red.pop_back()
		Cell.COLOR.GREEN:
			if green.size() == 0:
				release(color, line_green.instantiate())
			line = green.pop_back()
		Cell.COLOR.BLUE:
			if blue.size() == 0:
				release(color, line_blue.instantiate())
			line = blue.pop_back()
		Cell.COLOR.YELLOW:
			if yellow.size() == 0:
				release(color, line_yellow.instantiate())
			line = yellow.pop_back()
		Cell.COLOR.MAGENTA:
			if magenta.size() == 0:
				release(color, line_magenta.instantiate())
			line = magenta.pop_back()
		Cell.COLOR.CYAN:
			if cyan.size() == 0:
				release(color, line_cyan.instantiate())
			line = cyan.pop_back()
		Cell.COLOR.WHITE:
			if white.size() == 0:
				release(color, line_white.instantiate())
			line = white.pop_back()
	if line.get_parent() != null:
		line.reparent(parent)
	else:
		parent.add_child(line, false)
	line.visible = true
	line.process_mode = Node.PROCESS_MODE_INHERIT
	return line

func release(color:Cell.COLOR, line: Node3D) -> void:
	line.visible = false
	line.process_mode = Node.PROCESS_MODE_DISABLED
	match color:
		Cell.COLOR.RED:
			red.push_back(line)
		Cell.COLOR.GREEN:
			green.push_back(line)
		Cell.COLOR.BLUE:
			blue.push_back(line)
		Cell.COLOR.YELLOW:
			yellow.push_back(line)
		Cell.COLOR.MAGENTA:
			magenta.push_back(line)
		Cell.COLOR.CYAN:
			cyan.push_back(line)
		Cell.COLOR.WHITE:
			white.push_back(line)
