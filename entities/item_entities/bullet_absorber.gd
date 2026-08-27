extends Area2D


func _on_area_entered(area: Area2D) -> void:
	if area is Spear && area.spear_owner && area.spear_owner is CharEnemy ||\
		area is Rocket || area is Bullet:
		area.call_deferred("queue_free")

func _on_despawn_timer_timeout() -> void:
	$AnimationPlayer.play("fade out")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	call_deferred("queue_free")
