extends Area2D

var direction = Vector2.ZERO
@export var speed = 500

func _ready() -> void:
	look_at(to_global(direction))
	$Sprite2D.play("default")
	Sounds.bullet.play()
	Sounds.bullet.position = global_position

func _process(delta: float) -> void:
	position += direction * speed *delta


func _on_timer_timeout() -> void:
	self.queue_free()


func _on_area_entered(area: Area2D) -> void:
	if area.get_parent() is Player && area.get_name() == "atk_hitbox":
		area.get_parent().damage(3)	
		self.queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body.get_parent() is Player && body.get_name() == "Shield" || body.get_parent() is Level && not body is StaticEnemy && not body is CharEnemy:
		self.queue_free()
	
		
