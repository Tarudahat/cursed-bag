extends CharEnemy
class_name Ghost

var plyr = null
var init_pos = Vector2.ZERO
var agro = false
var moving_to_target = false

func _ready() -> void:
	super()
	atk = 5
	speed = 150.0
	init_pos = position
	$AnimatedSprite2D.play()

func _physics_process(_delta: float) -> void:
	if not agro && not moving_to_target:
		velocity = Vector2(randi_range(-1, 1), randi_range(-1, 1)) * speed * speed_multiply
		moving_to_target = true
		$movement_timer.start()
	
	if agro && plyr != null:
		var mov_dir = position.direction_to(plyr.position)
		$AnimatedSprite2D.flip_h = mov_dir.x >= 0
		velocity = mov_dir * speed * 1.2 * speed_multiply
	
	char_entity_move_and_slide()

	for i in get_slide_collision_count():
		var collider = get_slide_collision(i).get_collider()
		if collider is Player:
			collider.knockback(global_position.direction_to(collider.global_position) * knockback_strength)
			collider.damage(atk)

func _on_movement_timer_timeout() -> void:
	moving_to_target = false

func _on_got_hit(_hp) -> void:
	$AnimatedSprite2D.material.set_shader_parameter("enabled", true)

func _on_inv_end() -> void:
	$AnimatedSprite2D.material.set_shader_parameter("enabled", false)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		agro = true
		plyr = body

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is Player:
		agro = false
