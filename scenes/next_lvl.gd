extends Area2D

var target_scene
var leave = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		if is_node_ready():
			if Globals.current_level >= len(Globals.level_room_count)-1:
				Globals.win_screen()
			else:
				Globals.next_level()
			
