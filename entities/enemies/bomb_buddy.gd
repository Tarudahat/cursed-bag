extends CharEnemy

@onready var explosion = preload("res://entities/explosion_area.tscn")

var t: float = 0.0
var jump_height: float = 800

var max_wander_distance: float = 220

var jump_start_pos: Vector2
var jump_target_pos: Vector2

var in_charge_range: bool = false
var in_jump_range: bool = false

var can_wander: bool = false
var is_jumping: bool = false

func _ready() -> void:
	super()
	$WanderCooldown.start()
	
func explode() -> void:
	var expl_inst = explosion.instantiate()
	expl_inst.global_position = global_position
	get_parent().add_child(expl_inst)
	queue_free()

func _physics_process(delta: float) -> void:
	# wander
	if can_wander:
		if wander_target.distance_to(global_position) > 20:
			velocity = global_position.direction_to(wander_target) * speed * speed_multiply * 0.5
		else:
			velocity = Vector2.ZERO
	else:
		$WanderCooldown.wait_time = randf_range(1.2, 1.6)
		$WanderCooldown.start()
		wander_target = global_position + Vector2(randf_range(-0.75, 1), randf_range(-0.5, 1)) * max_wander_distance
		can_wander = true
	
	if Globals.player_node != null:
		# see -> move
		if in_charge_range:
			velocity = global_position.direction_to(Globals.player_node.global_position) * speed * speed_multiply
		
		# in range -> jump and boom
		if in_jump_range && !is_jumping:
			is_jumping = true
			jump_start_pos = global_position
			jump_target_pos = Globals.player_node.global_position
			set_collision_mask_value(2, false)
			$CollisionShape2D.disabled = true
			
		if is_jumping:
			velocity = global_position.direction_to(jump_target_pos) * speed * speed_multiply * 0.96
			t = global_position.distance_to(jump_start_pos) \
				/ jump_target_pos.distance_to(jump_start_pos)
			
			if jump_target_pos.x > jump_start_pos.x:
				$Sprite2D.rotation_degrees = 180 * t
			else:
				$Sprite2D.rotation_degrees = -180 * t
			
			$Sprite2D.global_position.y = Globals.bezier_curve(jump_start_pos, (jump_target_pos + jump_start_pos) / 2 + Vector2.UP * jump_height, jump_target_pos, t).y

			if t >= 0.9:
				set_collision_mask_value(2, true)
				$CollisionShape2D.disabled = false
	
	char_entity_move_and_slide()
	
	for i in get_slide_collision_count():
		var collider = get_slide_collision(i).get_collider()
		if is_jumping && collider is CharEntity:
			explode()
	
	if t >= 0.95 && !falling_into_hole:
		explode()
			
func _on_jump_range_area_body_entered(body: Node2D) -> void:
	if body is Player:
		in_jump_range = true


func _on_jump_range_area_body_exited(body: Node2D) -> void:
	if body is Player:
		in_jump_range = false


func _on_charge_range_area_body_entered(body: Node2D) -> void:
	if body is Player:
		in_charge_range = true


func _on_charge_range_area_body_exited(body: Node2D) -> void:
	if body is Player:
		in_charge_range = false


func _on_wander_cooldown_timeout() -> void:
	can_wander = false


func _on_got_hit(hp: Variant) -> void:
	$Sprite2D.material.set_shader_parameter("enabled", true)

func _on_inv_end() -> void:
	$Sprite2D.material.set_shader_parameter("enabled", false)
