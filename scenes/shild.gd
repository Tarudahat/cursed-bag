extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Globals.perm_shield:
		self.queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		if body.gems >= 250:
			body.gems -= 250
			body.perma_shield = true
			Globals.perm_shield = true
			queue_free()
