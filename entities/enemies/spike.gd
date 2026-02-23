extends Area2D

@export var dmg = 5

func _on_area_entered(area: Area2D) -> void:
	if area.get_parent() is Player:
		if !area.get_parent().in_air && area.get_name() != "Sword":
			print(dmg)
			area.get_parent().damage(dmg)
