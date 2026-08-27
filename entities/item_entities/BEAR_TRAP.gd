extends Area2D

var is_activated: bool = false

func _on_body_entered(body: Node2D) -> void:
	if body is CharEntity && ! body is Player && !is_activated:
		is_activated = true
		body.apply_status_effect(CharEntity.StatusEffect.STUN, 5)
		$DespawnTimer.start()
		$AnimatedSprite2D.play("trap")


func _on_despawn_timer_timeout() -> void:
	call_deferred("queue_free")
