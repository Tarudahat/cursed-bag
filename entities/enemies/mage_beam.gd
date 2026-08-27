extends Area2D

var direction = Vector2.ZERO
var knockback_strength = 3000

var beam_owner: Node = null

@export var speed = 400
@export var dmg = 3
@export var status_effect: CharEntity.StatusEffect = CharEntity.StatusEffect.TINY
@export var effect_duration: float = 5.0

func _ready() -> void:
	look_at(to_global(direction))

func _process(delta: float) -> void:
	position += direction * speed * delta

func _on_body_entered(body: Node2D) -> void:
	if body.get_parent() is Player && body.get_name() == "Shield" || body.get_parent() is Level && not body is CharEnemy:
		self.queue_free()

	if body is CharEntity && body != beam_owner:
		body.knockback(global_position.direction_to(body.global_position) * knockback_strength)
		body.damage(dmg)
		body.apply_status_effect(status_effect, effect_duration)
		self.queue_free()
