extends Area2D

var direction = Vector2.ZERO

func _process(delta: float) -> void:
	position += direction * 1500 * delta


func _on_body_entered(body: Node2D) -> void:
	if body is CharEnemy:
		body.damage(25)


func _on_timer_timeout() -> void:
	self.queue_free()
