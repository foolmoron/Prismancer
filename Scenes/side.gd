class_name Side
extends Node3D

@export var gem_spawn_entries: Array[GemSpawnEntry] = []
var gem_spawns : Array[PackedScene] = []

@onready var board := $Board as Node3D
@onready var origin := board.global_transform.origin - Vector3(board.scale.x / 2, board.scale.y / 2, 0)
const GRID_SIZE := 80.0

const GRID_COLUMNS := 5
const GRID_ROWS := 8
@onready var grid := Grid.new(GRID_COLUMNS, GRID_ROWS, self)

var gem_next: Gem

func _ready() -> void:
	for entry in gem_spawn_entries:
		for i in range(entry.weight):
			gem_spawns.append(entry.scene)
		
	setup_next_gem()
	grid.refresh()

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
		var idx := grid.to_idx(column_idx, -1)
		if grid.cells[idx].gem != null:
			return
		while idx >= grid.columns && grid.cells[idx - grid.columns].gem == null:
			idx -= grid.columns
		gem_next.reparent(self, false)
		gem_next.global_position = coord_to_global_pos(Vector2i(idx % grid.columns, idx / grid.columns))
		grid.cells[idx].gem = gem_next
		setup_next_gem()
		grid.refresh()

func coord_to_global_pos(coord: Vector2i) -> Vector3:
	return origin + Vector3(GRID_SIZE / 2, GRID_SIZE / 2, 0) + Vector3(coord.x * GRID_SIZE, coord.y * GRID_SIZE, 10.0)
