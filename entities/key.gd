extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		body.keys += 1
		self.queue_free()
