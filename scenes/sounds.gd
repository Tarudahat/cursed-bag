extends Node

@onready var bullet = $bullet
@onready var sword = $sword
@onready var music = $music
@onready var evil = $evil

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_music_finished() -> void:
	Sounds.music.play()
