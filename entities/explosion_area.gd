extends Area2D

@export var knockback_strength: float = 6000
@export var dmg: int = 15

var should_free: bool = false

func _ready() -> void:
	$AnimationPlayer.play("boom")

func _process(delta: float) -> void:
	if should_free:
		queue_free()

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	should_free = true

func _on_body_entered(body: Node2D) -> void:
	if body is CharEntity:
		body.knockback(global_position.direction_to(body.global_position) * knockback_strength)
		body.damage(dmg)
