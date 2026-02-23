extends Area2D

@export var value = 5


func _on_area_entered(area: Area2D) -> void:
	if area.get_parent() is Player and area != null and area.get_name() == "atk_hitbox":
		area.get_parent().gems += value	
		self.queue_free()
