extends Area2D
class_name Bullet

var direction = Vector2.ZERO
var knockback_strength = 3000
@export var speed = 500
@export var dmg = 3

func _ready() -> void:
	look_at(to_global(direction))
	$Sprite2D.play("default")
	Sounds.bullet.play()
	Sounds.bullet.position = global_position

func _process(delta: float) -> void:
	position += direction * speed * delta


func _on_timer_timeout() -> void:
	self.queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body.get_parent() is Player && body.get_name() == "Shield" || body.get_parent() is Level && not body is CharEnemy:
		self.queue_free()
	if body is Player:
		body.knockback(global_position.direction_to(body.global_position) * knockback_strength)
		body.damage(dmg)
		self.queue_free()
