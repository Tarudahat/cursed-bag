extends Boss

const SPEED = 80.0
const DMG = [10, 15]

var target_position: Vector2
var target_direction: Vector2
var starting_position: Vector2
var done_dashing: bool = false
var player_inside_range: bool = false

const attack_stage_durations_per_attack: Array[Dictionary] = \
[
	{
		attack_stage.WINDUP: 0.3,
		attack_stage.ATTACK: 1.0,
		attack_stage.STUN: 2.0,
		attack_stage.THINK: 0.3
	},
	{
		attack_stage.WINDUP: 0.5,
		attack_stage.ATTACK: 10.0,
		attack_stage.STUN: 2.2,
		attack_stage.THINK: 0.3
	}
]

func _ready() -> void:
	super()
	
	Globals.boss = self
	
	current_atk_id = 0
	current_atk_stage = attack_stage.THINK
	attack_stage_durations = attack_stage_durations_per_attack[0]

	atk_stage_timer.start()

func calc_atk_t() -> float:
	return 1.0 - (atk_stage_timer.time_left / attack_stage_durations[attack_stage.ATTACK])

func perform_jump_attack():
	var t = calc_atk_t()
		
	if t < 0.40:
		target_position = Globals.player_node.position

	position = starting_position + (target_position - starting_position) * t

	if t >= 0.88 && player_inside_range:
		Globals.player_node.damage(DMG[0])
		

func perform_dash_attack(delta):
	if !done_dashing:
		velocity += target_direction.normalized() * (1 + calc_atk_t()) * SPEED
		velocity.x = clamp(velocity.x, -1500, 1500)
		velocity.y = clamp(velocity.y, -1500, 1500)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.y = move_toward(velocity.y, 0, SPEED)
		if velocity == Vector2.ZERO:
			atk_stage_timer.emit_signal("timeout")
		
	move_and_slide()

	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider is Player:
			collider.damage(DMG[1])
		
		velocity = collision.get_normal() * SPEED * 15
		done_dashing = true


# func perform_bounce_attack(delta):
# 	velocity = target_direction.normalized() * SPEED
		
# 	move_and_slide()

# 	for i in get_slide_collision_count():
# 		var collision = get_slide_collision(i)
# 		var collider = collision.get_collider()
# 		if collider is Player:
# 			collider.damage(5000)
# 		else:
# 			target_direction = collision.get_normal().bounce(target_direction)
			

func _physics_process(delta: float) -> void:
	match current_atk_stage:
		attack_stage.ATTACK:
			match current_atk_id:
				0:
					perform_jump_attack()
				1:
					perform_dash_attack(delta)


func _on_start_think() -> void:
	# choose move
	current_atk_id = randi_range(0, 1)

	# far away always dash
	if position.distance_to(Globals.player_node.position) > 2000:
		current_atk_id = 1

	attack_stage_durations = attack_stage_durations_per_attack[current_atk_id]
	current_atk_stage = attack_stage.THINK
	done_dashing = false
	atk_stage_timer.start()

func _on_start_windup(atk_id: int) -> void:
	$AnimationPlayer.play("windup_" + str(current_atk_id))
	$AnimationPlayer.speed_scale = $AnimationPlayer.get_animation("windup_" + str(current_atk_id)).length / attack_stage_durations[attack_stage.WINDUP]
	starting_position = position
	target_direction = position.direction_to(Globals.player_node.position)

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	$AnimationPlayer.speed_scale = 1.0
	if anim_name.contains("windup_"):
			$AnimationPlayer.play("atk_" + str(current_atk_id))
			$AnimationPlayer.speed_scale = $AnimationPlayer.get_animation("atk_" + str(current_atk_id)).length / attack_stage_durations[attack_stage.ATTACK]


func _on_got_hit(hp, val) -> void:
	$Sprite2D.material.set_shader_parameter("enabled", true)

func _on_inv_end() -> void:
	$Sprite2D.material.set_shader_parameter("enabled", false)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		player_inside_range = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is Player:
		player_inside_range = false
