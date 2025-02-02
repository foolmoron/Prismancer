class_name Grid
extends Resource

var columns: int
var rows: int
var cells: Array = []

var side: Side

func _init(_columns = 2, _rows = 2, _side: Side = null) :
	columns = _columns
	rows = _rows
	side = _side
	for i in range(columns * rows):
		cells.append(Cell.new(side))

func to_idx(column_idx: int, row_idx: int) -> int:
	if row_idx < 0:
		row_idx += rows
	return column_idx + row_idx * columns

func get_cell(column_idx: int, row_idx: int) -> Cell:
	return cells[to_idx(column_idx, row_idx)]

func refresh() -> void:
	for c in cells:
		c.reset_masks()

	_process_cells_for_dir(Cell.DIR.UP, Vector2i(0, 0))
	_process_cells_for_dir(Cell.DIR.UP, Vector2i(2, 0))
	_process_cells_for_dir(Cell.DIR.UP, Vector2i(4, 0))

	_process_cells_with_color(Cell.COLOR.RED, Vector2i(0, 0))
	_process_cells_with_color(Cell.COLOR.GREEN, Vector2i(2, 0))
	_process_cells_with_color(Cell.COLOR.BLUE, Vector2i(4, 0))

	for y in range(rows):
		for x in range(columns):
			cells[to_idx(x, y)].reset_lines(side.coord_to_global_pos(Vector2i(x, y)))

func _process_cells_for_dir(initial_dir: Cell.DIR, initial_pos: Vector2i) -> void:
	var seen := {}
	var queue := [[initial_pos, initial_dir]]
	while queue.size() > 0:
		var c = queue.pop_back()
		var pos := c[0] as Vector2i
		var dir := c[1] as Cell.DIR
		if pos.x < 0 || pos.x >= columns || pos.y < 0 || pos.y >= rows:
			continue
		var cell := cells[to_idx(pos.x, pos.y)] as Cell
		if cell.gem == null || seen.has(cell):
			continue
		
		if cell.gem.type == Gem.GEM_TYPE.SPHERE:
			if cell.try_add_outdir(dir):
				queue.append([pos + Cell.dir_to_vec(dir), dir])
		elif cell.gem.type == Gem.GEM_TYPE.TRI_LEFT:
			if dir == Cell.DIR.UP:
				if cell.try_add_outdir(Cell.DIR.LEFT):
					queue.append([pos + Cell.dir_to_vec(Cell.DIR.LEFT), Cell.DIR.LEFT])
			elif dir == Cell.DIR.DOWN:
				if cell.try_add_outdir(Cell.DIR.RIGHT):
					queue.append([pos + Cell.dir_to_vec(Cell.DIR.RIGHT), Cell.DIR.RIGHT])
			elif dir == Cell.DIR.LEFT:
				if cell.try_add_outdir(Cell.DIR.UP):
					queue.append([pos + Cell.dir_to_vec(Cell.DIR.UP), Cell.DIR.UP])
			elif dir == Cell.DIR.RIGHT:
				if cell.try_add_outdir(Cell.DIR.DOWN):
					queue.append([pos + Cell.dir_to_vec(Cell.DIR.DOWN), Cell.DIR.DOWN])
			else:
				if cell.try_add_outdir(dir):
					queue.append([pos + Cell.dir_to_vec(dir), dir])
		elif cell.gem.type == Gem.GEM_TYPE.TRI_RIGHT:
			if dir == Cell.DIR.UP:
				if cell.try_add_outdir(Cell.DIR.RIGHT):
					queue.append([pos + Cell.dir_to_vec(Cell.DIR.RIGHT), Cell.DIR.RIGHT])
			elif dir == Cell.DIR.DOWN:
				if cell.try_add_outdir(Cell.DIR.LEFT):
					queue.append([pos + Cell.dir_to_vec(Cell.DIR.LEFT), Cell.DIR.LEFT])
			elif dir == Cell.DIR.LEFT:
				if cell.try_add_outdir(Cell.DIR.DOWN):
					queue.append([pos + Cell.dir_to_vec(Cell.DIR.DOWN), Cell.DIR.DOWN])
			elif dir == Cell.DIR.RIGHT:
				if cell.try_add_outdir(Cell.DIR.UP):
					queue.append([pos + Cell.dir_to_vec(Cell.DIR.UP), Cell.DIR.UP])
			else:
				if cell.try_add_outdir(dir):
					queue.append([pos + Cell.dir_to_vec(dir), dir])
		elif cell.gem.type == Gem.GEM_TYPE.STAR:
			if cell.try_add_outdir(Cell.DIR.UP_LEFT):
				queue.append([pos + Cell.dir_to_vec(Cell.DIR.UP_LEFT), Cell.DIR.UP_LEFT])
			if cell.try_add_outdir(Cell.DIR.UP_RIGHT):
				queue.append([pos + Cell.dir_to_vec(Cell.DIR.UP_RIGHT), Cell.DIR.UP_RIGHT])
			if cell.try_add_outdir(Cell.DIR.DOWN_LEFT):
				queue.append([pos + Cell.dir_to_vec(Cell.DIR.DOWN_LEFT), Cell.DIR.DOWN_LEFT])
			if cell.try_add_outdir(Cell.DIR.DOWN_RIGHT):
				queue.append([pos + Cell.dir_to_vec(Cell.DIR.DOWN_RIGHT), Cell.DIR.DOWN_RIGHT])


func _process_cells_with_color(color: Cell.COLOR, initial: Vector2i) -> void:
	var seen := {}
	var queue := [initial]
	while queue.size() > 0:
		var pos = queue.pop_back() as Vector2i
		if pos.x < 0 || pos.x >= columns || pos.y < 0 || pos.y >= rows:
			continue
		var cell := cells[to_idx(pos.x, pos.y)] as Cell
		if seen.has(cell):
			continue
		seen[cell] = true

		cell.color_mask = (cell.color_mask | color) as Cell.COLOR
		
		for dir in Cell.DIR.values():
			if cell.out_mask & dir != 0:
				queue.append(pos + Cell.dir_to_vec(dir))
