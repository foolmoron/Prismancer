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

enum OUTDIR {
	NONE = 0,
	UP = 1 << 0,
	DOWN = 1 << 1,
	LEFT = 1 << 2,
	RIGHT = 1 << 3,
	UP_LEFT = 1 << 4,
	UP_RIGHT = 1 << 5,
	DOWN_LEFT = 1 << 6,
	DOWN_RIGHT = 1 << 7,
}

var gem: Gem = null
var lines: Array[Node3D] = []

var color_mask: COLOR = COLOR.NONE
var out_mask: int = 0

func _init():
	pass
