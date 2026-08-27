extends TextureRect

func _ready() -> void:
	pass

func _on_button_pressed() -> void:	
	Globals.loadout_screen()
	self.queue_free()

func _on_button_2_pressed() -> void:
	Globals.gacha_screen()
	self.queue_free()
