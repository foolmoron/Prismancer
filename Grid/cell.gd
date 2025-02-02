class_name Cell
extends Resource

enum COLOR {
	NONE = 0,
	RED = 0b001,
	GREEN = 0b010,
	BLUE = 0b100,
	YELLOW = 0b011,
	MAGENTA = 0b101,
	CYAN = 0b110,
	WHITE = 0b111,
}

enum DIR {
	UP = 1 << 0,
	DOWN = 1 << 1,
	LEFT = 1 << 2,
	RIGHT = 1 << 3,
	UP_LEFT = 1 << 4,
	UP_RIGHT = 1 << 5,
	DOWN_LEFT = 1 << 6,
	DOWN_RIGHT = 1 << 7,
}
		
static func dir_to_vec(dir: Cell.DIR) -> Vector2i:
	match dir:
		Cell.DIR.UP:
			return Vector2i(0, 1)
		Cell.DIR.DOWN:
			return Vector2i(0, -1)
		Cell.DIR.LEFT:
			return Vector2i(-1, 0)
		Cell.DIR.RIGHT:
			return Vector2i(1, 0)
		Cell.DIR.UP_LEFT:
			return Vector2i(-1, 1)
		Cell.DIR.UP_RIGHT:
			return Vector2i(1, 1)
		Cell.DIR.DOWN_LEFT:
			return Vector2i(-1, -1)
		Cell.DIR.DOWN_RIGHT:
			return Vector2i(1, -1)
		_:
			return Vector2i(0, 0)

var gem: Gem = null
var lines: Dictionary = {}

var color_mask: COLOR = COLOR.NONE
var out_mask: int = 0

var parent: Node3D = null

func _init(_parent: Node3D = null):
	parent = _parent
	for c in Cell.COLOR.values():
		lines[c] = []

func reset_masks() -> void:
	color_mask = COLOR.NONE
	out_mask = 0

func reset_lines(global_pos: Vector3) -> void:
	for color in lines.keys():
		var arr = lines[color]
		for line in arr:
			LinePool.release(color, line)
		arr.clear()

	var line_pool: Array[Node3D]
	match color_mask:
		COLOR.RED:
			line_pool = LinePool.red
		COLOR.GREEN:
			line_pool = LinePool.green
		COLOR.BLUE:
			line_pool = LinePool.blue
		COLOR.YELLOW:
			line_pool = LinePool.yellow
		COLOR.MAGENTA:
			line_pool = LinePool.magenta
		COLOR.CYAN:
			line_pool = LinePool.cyan
		COLOR.WHITE:
			line_pool = LinePool.white
	for dir in Cell.DIR.values():
		if out_mask & dir != 0:
			var line := LinePool.obtain(color_mask, parent)
			match dir:
				Cell.DIR.UP, Cell.DIR.DOWN, Cell.DIR.LEFT, Cell.DIR.RIGHT:
					line.scale.y = Side.GRID_SIZE
				Cell.DIR.UP_LEFT, Cell.DIR.UP_RIGHT, Cell.DIR.DOWN_LEFT, Cell.DIR.DOWN_RIGHT:
					line.scale.y = Side.GRID_SIZE * 1.4142
			match dir:
				Cell.DIR.UP, Cell.DIR.DOWN:
					line.rotation_degrees.z = 0
				Cell.DIR.LEFT, Cell.DIR.RIGHT:
					line.rotation_degrees.z = 90
				Cell.DIR.UP_LEFT, Cell.DIR.DOWN_RIGHT:
					line.rotation_degrees.z = 45
				Cell.DIR.UP_RIGHT, Cell.DIR.DOWN_LEFT:
					line.rotation_degrees.z = -45
			var offset := dir_to_vec(dir) * Side.GRID_SIZE / 2
			line.global_position.x = global_pos.x + offset.x
			line.global_position.y = global_pos.y + offset.y

func try_add_outdir(dir: Cell.DIR) -> bool:
	if out_mask & dir == 0:
		out_mask |= dir
		return true
	return false
