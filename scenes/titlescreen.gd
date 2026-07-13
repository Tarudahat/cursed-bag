extends TextureRect

func _on_button_pressed() -> void:	
	Globals.current_level = -1
	Globals.next_level()
	self.queue_free()
