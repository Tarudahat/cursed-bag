extends CharEntity

func glow(t: float = 1.0):
	$Sprite2D.modulate = Color.RED
	dmg_timer.wait_time = t
	dmg_timer.start()
	can_get_hit = false

func _on_got_hit(hp: Variant) -> void:
	hp = 99999999

func _on_inv_end() -> void:
	$Sprite2D.modulate = Color.WHITE
