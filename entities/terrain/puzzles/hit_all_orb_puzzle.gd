extends Node2D

var orb = preload("res://entities/terrain/puzzles/orb_button.tscn")

@export var orb_count: int = 3

var orb_instances: Array

signal puzzle_failed
signal puzzle_succeeded

func _ready() -> void:
	# spawn orbs
	for orb_idx in orb_count:
		var orb_instance = orb.instantiate()
		orb_instances.append(orb_instance)
		orb_instance.global_position = global_position + Vector2.RIGHT * 600 * orb_idx
		# connect got_hit 
		orb_instance.got_hit.connect(handle_hit.bind(orb_idx))
		get_parent().call_deferred("add_child", orb_instance)

func handle_hit(hp: int, orb_idx: int) -> void:
	orb_instances[orb_idx].glow(5.0)
	
	var all_orb_active = orb_instances.all(func(orb): return !orb.can_get_hit)
	if all_orb_active:
		emit_signal("puzzle_succeeded")
