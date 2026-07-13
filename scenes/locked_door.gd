extends StaticBody2D

@export var direction: Vector2 = Vector2.UP
var twin_node = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	match direction:
		Vector2.UP:
			$UpperLockedDoor.visible = true
			$UpperCollisionShape.disabled = false
		Vector2.DOWN:
			$UpperLockedDoor.visible = true
			$UpperLockedDoor.flip_v = true
			$UpperCollisionShape.disabled = false
			self.position.x -= 16
		Vector2.RIGHT:
			$SideLockedDoor.visible = true
			$SideCollisionShape.disabled = false
			self.position.x += 16
		Vector2.LEFT:
			$SideLockedDoor.visible = true
			$SideLockedDoor.flip_h = true
			$SideCollisionShape.disabled = false
			self.position.x -= 16

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		if body.keys > 0:
			$UpperCollisionShape.set_deferred("disabled", true)
			$SideCollisionShape.set_deferred("disabled", true)
			body.keys -= 1
			self.queue_free()
			if twin_node != null:
				twin_node.queue_free()
	
	
