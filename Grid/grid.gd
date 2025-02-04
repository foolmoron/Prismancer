class_name Grid
extends Resource

const TIER2 := 5
const TIER3 := 12

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

	# mark all out directions
	_process_cells_for_dir(Cell.DIR.UP, Vector2i(0, 0))
	_process_cells_for_dir(Cell.DIR.UP, Vector2i(2, 0))
	_process_cells_for_dir(Cell.DIR.UP, Vector2i(4, 0))

	# clean up out directions on edges
	var no_left := ~(Cell.DIR.LEFT | Cell.DIR.UP_LEFT | Cell.DIR.DOWN_LEFT)
	for y in range(rows):
		cells[to_idx(0, y)].out_mask &= no_left
	var no_right := ~(Cell.DIR.RIGHT | Cell.DIR.UP_RIGHT | Cell.DIR.DOWN_RIGHT)
	for y in range(rows):
		cells[to_idx(columns - 1, y)].out_mask &= no_right
	var no_up := ~(Cell.DIR.UP | Cell.DIR.UP_LEFT | Cell.DIR.UP_RIGHT)
	for x in range(columns):
		cells[to_idx(x, rows - 1)].out_mask &= no_up
	var no_down := ~(Cell.DIR.DOWN | Cell.DIR.DOWN_LEFT | Cell.DIR.DOWN_RIGHT)
	for x in range(columns):
		cells[to_idx(x, 0)].out_mask &= no_down

	# mark colors
	_process_cells_with_color(Cell.COLOR.RED, Vector2i(0, 0))
	_process_cells_with_color(Cell.COLOR.GREEN, Vector2i(2, 0))
	_process_cells_with_color(Cell.COLOR.BLUE, Vector2i(4, 0))

	# set lines based on out directions and colors
	for y in range(rows):
		for x in range(columns):
			cells[to_idx(x, y)].reset_lines(side.to_local(side.coord_to_global_pos(Vector2i(x, y)))) 

func kill_lines() -> void:
	for cell in cells:
		cell.kill_lines()

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

const SURGE_INTERVAL_SECS := 0.1

func surge_and_count(initial_dir: Cell.DIR, initial_pos: Vector2i) -> Dictionary:
	var count := {}

	var seen := {}
	var queue := [[initial_pos, initial_dir]]
	var cells_to_count := []
	while queue.size() > 0:
		var c = queue.pop_back()
		var pos := c[0] as Vector2i
		var dir := c[1] as Cell.DIR
		if pos.x < 0 || pos.x >= columns || pos.y < 0 || pos.y >= rows:
			continue
		var cell := cells[to_idx(pos.x, pos.y)] as Cell
		if cell.gem == null || (seen.has(cell) && seen[cell].has(dir)):
			continue
		seen[cell] = seen.get(cell, {})
		seen[cell][dir] = true

		cells_to_count.append(cell)

		if cell.gem.type == Gem.GEM_TYPE.SPHERE:
			queue.append([pos + Cell.dir_to_vec(dir), dir])
		elif cell.gem.type == Gem.GEM_TYPE.TRI_LEFT:
			if dir == Cell.DIR.UP:
				queue.append([pos + Cell.dir_to_vec(Cell.DIR.LEFT), Cell.DIR.LEFT])
			elif dir == Cell.DIR.DOWN:
				queue.append([pos + Cell.dir_to_vec(Cell.DIR.RIGHT), Cell.DIR.RIGHT])
			elif dir == Cell.DIR.LEFT:
				queue.append([pos + Cell.dir_to_vec(Cell.DIR.UP), Cell.DIR.UP])
			elif dir == Cell.DIR.RIGHT:
				queue.append([pos + Cell.dir_to_vec(Cell.DIR.DOWN), Cell.DIR.DOWN])
			else:
				queue.append([pos + Cell.dir_to_vec(dir), dir])
		elif cell.gem.type == Gem.GEM_TYPE.TRI_RIGHT:
			if dir == Cell.DIR.UP:
				queue.append([pos + Cell.dir_to_vec(Cell.DIR.RIGHT), Cell.DIR.RIGHT])
			elif dir == Cell.DIR.DOWN:
				queue.append([pos + Cell.dir_to_vec(Cell.DIR.LEFT), Cell.DIR.LEFT])
			elif dir == Cell.DIR.LEFT:
				queue.append([pos + Cell.dir_to_vec(Cell.DIR.DOWN), Cell.DIR.DOWN])
			elif dir == Cell.DIR.RIGHT:
				queue.append([pos + Cell.dir_to_vec(Cell.DIR.UP), Cell.DIR.UP])
			else:
				queue.append([pos + Cell.dir_to_vec(dir), dir])
		elif cell.gem.type == Gem.GEM_TYPE.STAR:
			# randomize iteration a bit
			match randi_range(0, 3):
				0: 
					queue.append([pos + Cell.dir_to_vec(Cell.DIR.UP_LEFT), Cell.DIR.UP_LEFT])
					queue.append([pos + Cell.dir_to_vec(Cell.DIR.UP_RIGHT), Cell.DIR.UP_RIGHT])
					queue.append([pos + Cell.dir_to_vec(Cell.DIR.DOWN_LEFT), Cell.DIR.DOWN_LEFT])
					queue.append([pos + Cell.dir_to_vec(Cell.DIR.DOWN_RIGHT), Cell.DIR.DOWN_RIGHT])
				1:
					queue.append([pos + Cell.dir_to_vec(Cell.DIR.DOWN_RIGHT), Cell.DIR.DOWN_RIGHT])
					queue.append([pos + Cell.dir_to_vec(Cell.DIR.DOWN_LEFT), Cell.DIR.DOWN_LEFT])
					queue.append([pos + Cell.dir_to_vec(Cell.DIR.UP_RIGHT), Cell.DIR.UP_RIGHT])
					queue.append([pos + Cell.dir_to_vec(Cell.DIR.UP_LEFT), Cell.DIR.UP_LEFT])
				2:
					queue.append([pos + Cell.dir_to_vec(Cell.DIR.DOWN_RIGHT), Cell.DIR.DOWN_RIGHT])
					queue.append([pos + Cell.dir_to_vec(Cell.DIR.UP_RIGHT), Cell.DIR.UP_RIGHT])
					queue.append([pos + Cell.dir_to_vec(Cell.DIR.DOWN_LEFT), Cell.DIR.DOWN_LEFT])
					queue.append([pos + Cell.dir_to_vec(Cell.DIR.UP_LEFT), Cell.DIR.UP_LEFT])
				3:
					queue.append([pos + Cell.dir_to_vec(Cell.DIR.DOWN_RIGHT), Cell.DIR.DOWN_RIGHT])
					queue.append([pos + Cell.dir_to_vec(Cell.DIR.UP_RIGHT), Cell.DIR.UP_RIGHT])
					queue.append([pos + Cell.dir_to_vec(Cell.DIR.UP_LEFT), Cell.DIR.UP_LEFT])
					queue.append([pos + Cell.dir_to_vec(Cell.DIR.DOWN_LEFT), Cell.DIR.DOWN_LEFT])
	
	# count and animate
	side.orb.visible = true
	side.orb.global_position = side.coord_to_global_pos(Vector2i(initial_pos.x, initial_pos.y) - Cell.dir_to_vec(initial_dir))
	side.orb.global_position.z += 10
	for text in side.score_texts:
		text.text = ""
	for cell in cells_to_count:
		if cell.gem == null:
			continue
		
		side.orb.set_color(cell.color_mask)
		var orb_pos = cell.gem.global_position
		orb_pos.z = side.orb.global_position.z
		var tween := side.get_tree().create_tween()
		tween.tween_property(side.orb, "global_position", orb_pos, SURGE_INTERVAL_SECS).set_trans(Tween.TRANS_LINEAR)
		await side.get_tree().create_timer(SURGE_INTERVAL_SECS).timeout

		count[cell.color_mask] = count.get(cell.color_mask, 0) + 1
		cell.gem.queue_free()
		cell.gem = null

		var prefix := ""
		match cell.color_mask:
			Cell.COLOR.RED:
				prefix = "RED"
			Cell.COLOR.GREEN:
				prefix = "GRN"
			Cell.COLOR.BLUE:
				prefix = "BLU"
			Cell.COLOR.YELLOW:
				prefix = "YLW"
			Cell.COLOR.MAGENTA:
				prefix = "MGN"
			Cell.COLOR.CYAN:
				prefix = "CYN"
			Cell.COLOR.WHITE:
				prefix = "WHT"
		side.score_texts[cell.color_mask].text = "%s: %s" % [prefix, count[cell.color_mask]]
		if count[cell.color_mask] >= TIER3:
			side.score_texts[cell.color_mask].text += " x 3"
		elif count[cell.color_mask] >= TIER2:
			side.score_texts[cell.color_mask].text += " x 2"

		if count[cell.color_mask] >= TIER3:
			side.get_node("Pop3Sound").play()
		elif count[cell.color_mask] >= TIER2:
			side.get_node("Pop2Sound").play()
		else:
			side.get_node("Pop1Sound").play()

	return count

const MOVE_INTERVAL_SECS := 0.05

func move_gems() -> void:
	for x in range(columns):
		for y in range(rows):
			var cell := cells[to_idx(x, y)] as Cell
			if cell.gem == null:
				continue
			var y_final := y
			for _y in range(y - 1, -1, -1):
				if cells[to_idx(x, _y)].gem != null:
					break
				y_final = _y
			if y_final != y:
				cell.gem.global_position = side.coord_to_global_pos(Vector2i(x, y_final))
				var cell2 := cells[to_idx(x, y_final)] as Cell
				cell2.gem = cell.gem
				cell.gem = null
				await side.get_tree().create_timer(MOVE_INTERVAL_SECS).timeout
