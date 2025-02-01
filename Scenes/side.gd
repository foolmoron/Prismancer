class_name Side
extends Node3D

@export var gem_spawn_entries: Array[GemSpawnEntry] = []
var gem_spawns : Array[PackedScene] = []

@onready var board := $Board as Node3D
@onready var origin := board.global_transform.origin - Vector3(board.scale.x / 2, board.scale.y / 2, 0)
@export var grid_size := 80.0

const GRID_COLUMNS := 5
const GRID_ROWS := 8
var grid: Array[Gem] = []

var gem_next: Gem

func to_idx(column_idx: int, row_idx: int) -> int:
	if row_idx < 0:
		row_idx += GRID_ROWS
	return column_idx + row_idx * GRID_COLUMNS

func _ready() -> void:
	for entry in gem_spawn_entries:
		for i in range(entry.weight):
			gem_spawns.append(entry.scene)

	for i in range(GRID_COLUMNS * GRID_ROWS):
		grid.append(null)
		
	setup_next_gem()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func setup_next_gem() -> void:
	gem_next = gem_spawns.pick_random().instantiate() as Gem
	$NextGem.add_child(gem_next, false)

func _on_column_input_event(camera:Node, event:InputEvent, event_position:Vector3, normal:Vector3, shape_idx:int, column_idx:int) -> void:
	if event is not InputEventScreenTouch:
		return
	var evt := event as InputEventScreenTouch
	if evt.pressed:
		var idx := to_idx(column_idx, -1)
		if grid[idx] != null:
			return
		while idx >= GRID_COLUMNS && grid[idx - GRID_COLUMNS] == null:
			idx -= GRID_COLUMNS
		gem_next.reparent(self, false)
		gem_next.global_position = origin + Vector3(grid_size / 2, grid_size / 2, 0) + Vector3((idx % GRID_COLUMNS) * grid_size, (idx / GRID_COLUMNS) * grid_size, 0)
		grid[idx] = gem_next
		setup_next_gem()
