class_name Grid
extends Resource

var columns: int
var rows: int
var cells: Array[Cell] = []

func _init(_columns = 2, _rows = 2) :
	columns = _columns
	rows = _rows
	for i in range(columns * rows):
		cells.append(Cell.new())

func to_idx(column_idx: int, row_idx: int) -> int:
	if row_idx < 0:
		row_idx += rows
	return column_idx + row_idx * columns

func get_cell(column_idx: int, row_idx: int) -> Cell:
	return cells[to_idx(column_idx, row_idx)]

# TODO: DFS all Rs and mark cells with color mask and outdir mask, repeat with Gs and Bs
# TODO: respawn all lines for each cell based on masks (pool per color)
