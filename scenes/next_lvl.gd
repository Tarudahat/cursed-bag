extends Area2D

var target_scene
var leave = false

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		if is_node_ready():
			if Globals.current_level >= len(Globals.level_room_count)-1:
				Globals.win_screen()
			else:
				Globals.next_level()
			
