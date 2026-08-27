extends StaticBody2D

@onready var explosion = preload("res://entities/explosion_area.tscn")

func explode() -> void:
	var expl_inst = explosion.instantiate()
	expl_inst.global_position = global_position
	get_parent().add_child(expl_inst)
	queue_free()

func _on_timer_timeout() -> void:
	explode()
