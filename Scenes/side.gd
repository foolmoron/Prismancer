class_name Side
extends Node3D

@export_range(0, 1) var player := 0;
static var P1_COLUMNS := ["p1_0", "p1_1", "p1_2", "p1_3", "p1_4"]
static var P1_SURGES := ["p1_r", "p1_g", "p1_b"]
static var P2_COLUMNS := ["p2_0", "p2_1", "p2_2", "p2_3", "p2_4"]
static var P2_SURGES := ["p2_r", "p2_g", "p2_b"]

@export var gem_spawn_entries: Array[GemSpawnEntry] = []
var gem_spawns : Array[PackedScene] = []

@onready var board := $Board as Node3D
@onready var origin := board.global_transform.origin - to_global(Vector3(board.scale.x / 2, board.scale.y / 2, 0))
const GRID_SIZE := 80.0

const GRID_COLUMNS := 5
const GRID_ROWS := 8
@onready var grid := Grid.new(GRID_COLUMNS, GRID_ROWS, self)

@onready var orb := $Orb as Orb
@onready var character1 := $Character1 as Character
@onready var character2 := $Character2 as Character
var character: Character

var gem_next: Gem
var surging := false

func _ready() -> void:
	for entry in gem_spawn_entries:
		for i in range(entry.weight):
			gem_spawns.append(entry.scene)
		
	orb.visible = false

	if player == 0:
		character1.visible = true
		character1.process_mode = Node.PROCESS_MODE_INHERIT
		character2.visible = false
		character2.process_mode = Node.PROCESS_MODE_DISABLED
		character = character1
	else:
		character1.visible = false
		character1.process_mode = Node.PROCESS_MODE_DISABLED
		character2.visible = true
		character2.process_mode = Node.PROCESS_MODE_INHERIT
		character = character2

	setup_next_gem()
	grid.refresh()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var columns := P1_COLUMNS if player == 0 else P2_COLUMNS
	for i in range(columns.size()):
		if Input.is_action_just_pressed(columns[i]):
			do_column(i)
			break
	var surges := P1_SURGES if player == 0 else P2_SURGES
	for i in range(surges.size()):
		if Input.is_action_just_pressed(surges[i]):
			do_surge(i)
			break

func setup_next_gem() -> void:
	gem_next = gem_spawns.pick_random().instantiate() as Gem
	$NextGem.add_child(gem_next, false)
	gem_next.set_next(true)

func _on_column_input_event(camera:Node, event:InputEvent, event_position:Vector3, normal:Vector3, shape_idx:int, column_idx:int) -> void:
	if event is not InputEventScreenTouch:
		return
	var evt := event as InputEventScreenTouch
	if evt.pressed:
		do_column(column_idx)

func do_column(column_idx: int) -> void:
	if surging:
		return
	var idx := grid.to_idx(column_idx, -1)
	if grid.cells[idx].gem != null:
		return
	while idx >= grid.columns && grid.cells[idx - grid.columns].gem == null:
		idx -= grid.columns
	gem_next.reparent(self, false)
	gem_next.set_next(false)
	gem_next.global_position = coord_to_global_pos(Vector2i(idx % grid.columns, idx / grid.columns))
	grid.cells[idx].gem = gem_next
	setup_next_gem()
	grid.refresh()

func coord_to_global_pos(coord: Vector2i) -> Vector3:
	return origin + to_global(Vector3(GRID_SIZE / 2, GRID_SIZE / 2, 0) + Vector3(coord.x * GRID_SIZE, coord.y * GRID_SIZE, 10.0))

func _on_surge_input_event(camera:Node, event:InputEvent, event_position:Vector3, normal:Vector3, shape_idx:int, surge_idx:int) -> void:
	if event is not InputEventScreenTouch:
		return
	var evt := event as InputEventScreenTouch
	if evt.pressed:
		do_surge(surge_idx)

func do_surge(color_idx: int) -> void:
	if surging:
		return
	surging = true
	character.set_state_active(true)
	var count := {}
	match color_idx:
		0: count = await grid.surge_and_count(Cell.DIR.UP, Vector2i(0, 0))
		1: count = await grid.surge_and_count(Cell.DIR.UP, Vector2i(2, 0))
		2: count = await grid.surge_and_count(Cell.DIR.UP, Vector2i(4, 0))
	print(count)
	await get_tree().create_timer(0.8).timeout
	grid.kill_lines()
	orb.visible = false
	await grid.move_gems()
	grid.refresh()
	await get_tree().create_timer(0.35).timeout
	character.set_state_active(false)
	surging = false
