extends CharEnemy
class_name Snake

var is_agro: bool = false

var bite_delay: float = 3.0
var target_rot: float

@export var dmg: float = 10

func _ready() -> void:
	super()
	next_wander_target()
	target_rot = rotation + get_angle_to(wander_target)
	speed = 400
	$BiteTimer.wait_time = 0.0
	$CloseRange/CollisionShape2D.disabled = true

func _physics_process(delta: float) -> void:
	var speed_bonus: float = 1.0
	
	#move close
	if is_agro:
		if $BiteTimer.time_left == 0:
			$BiteTimer.wait_time = bite_delay + randf_range(-1,1)
			$BiteTimer.start()
		
		if Globals.player_node:
			wander_target = Globals.player_node.global_position
			target_rot = rotation + get_angle_to(wander_target)
	
	#wander
	else:
		speed_bonus = 0.45
		if global_position.distance_to(wander_target) < 100:
			next_wander_target()
			target_rot = rotation + get_angle_to(wander_target)
			$WanderTimer.start()
	
	
	rotation = move_toward(rotation, target_rot, delta * speed_multiply * 5)
	velocity = global_position.direction_to(wander_target) * speed * speed_multiply * speed_bonus
	
	
	char_entity_move_and_slide()

func _on_far_range_body_entered(body: Node2D) -> void:
	if body is Player:
		is_agro = true

func _on_far_range_body_exited(body: Node2D) -> void:
	if body is Player:
		is_agro = false
		$BiteTimer.wait_time = 0.0

func _on_wander_timer_timeout() -> void:
	if !is_agro:
		next_wander_target()

func _on_bite_timer_timeout() -> void:
	if is_agro:
		$CloseRange/CollisionShape2D.disabled = false
		$AnimatedSprite2D.play("bite")

func _on_close_range_body_entered(body: Node2D) -> void:
	if body is CharEntity:
		if body is Player:
			print(body.name)
		body.damage(dmg)
		body.apply_status_effect(StatusEffect.POISON)
		body.knockback(global_position.direction_to(body.global_position) * knockback_strength)
	


func _on_animated_sprite_2d_animation_finished() -> void:
	if $AnimatedSprite2D.animation == "bite":
		$CloseRange/CollisionShape2D.disabled = true
		$AnimatedSprite2D.play("default")
