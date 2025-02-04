extends Button

@onready var template := self.text

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.text = template.format([GameStuff.TIME_SECS])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_pressed() -> void:
	var idx = GameStuff.TIME_SECS_OPTIONS.find(GameStuff.TIME_SECS)
	idx = (idx + 1) % GameStuff.TIME_SECS_OPTIONS.size()
	GameStuff.TIME_SECS = GameStuff.TIME_SECS_OPTIONS[idx]
	self.text = template.format([GameStuff.TIME_SECS])
