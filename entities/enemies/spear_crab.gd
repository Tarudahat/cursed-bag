extends CharEnemy

var spear = preload("res://entities/spear.tscn")
var spr_inst

@export var movement_direction: Vector2i = Vector2.RIGHT

var player_in_range_far: bool = false
var player_in_range_close: bool = false
var enemy_target_position: Vector2

var can_throw: bool = false
var can_jab: bool = true

var should_start_go_to_spear: bool = false
var should_return_to_marching: bool = false
var original_marching_position: Vector2

var jab_atk_base_wait_time: float
var throw_atk_base_wait_time: float

func _ready() -> void:
	super()
	speed = 400
	atk = 5
	knockback_resistance = 1
	spr_inst = spear.instantiate()
	spr_inst.spear_owner = self
	spr_inst.rotation_degrees = -70
	add_child(spr_inst)
	
	jab_atk_base_wait_time = $jab_cooldown.wait_time
	throw_atk_base_wait_time = $throw_atk_cooldown.wait_time

func _physics_process(_delta: float) -> void:
	if !spr_inst.on_ground:
		if should_return_to_marching:
			# return to marching location
			velocity = global_position.direction_to(original_marching_position) * speed * speed_multiply * 1.7
			if global_position.distance_to(original_marching_position) <= 50:
				should_return_to_marching = false
		else:
			# default movement
			velocity = movement_direction * speed * speed_multiply
			
			if Globals.player_node != null:
				# close range atk
				if player_in_range_close:
					velocity *= 0.5
					if !spr_inst.being_thrown && !spr_inst.on_ground && can_jab:
						spr_inst.init_jab(Globals.player_node.global_position)
					
				# ranged movement and atk
				if player_in_range_far && !player_in_range_close:
					velocity *= 1.4
					if spr_inst.being_thrown:
						enemy_target_position = Globals.player_node.global_position
					if !spr_inst.being_thrown && !spr_inst.on_ground && can_throw:
						spr_inst.init_throw(Globals.player_node.global_position)
						can_throw = false
						should_start_go_to_spear = true
						should_return_to_marching = false
	else:
		# go pick up spear
		# before going to pick it up store current location
		if should_start_go_to_spear:
			original_marching_position = global_position
			should_start_go_to_spear = false
			should_return_to_marching = true

		velocity = global_position.direction_to(spr_inst.get_node("CollisionShape2D").global_position) * speed * speed_multiply * 1.7

		# ranged atk cooldown
		if !spr_inst.being_thrown && !spr_inst.being_jabbed:
			if !can_throw && $throw_atk_cooldown.time_left == 0 && $jab_cooldown.time_left == 0:
				$throw_atk_cooldown.wait_time = throw_atk_base_wait_time + randf_range(-1.0, 2.0)
				$throw_atk_cooldown.start()
			if !can_jab && $jab_cooldown.time_left == 0:
				$jab_cooldown.wait_time = jab_atk_base_wait_time + randf_range(-0.1, 0.1)
				$jab_cooldown.start()

	char_entity_move_and_slide()
	
	for i in get_slide_collision_count():
		var collider = get_slide_collision(i).get_collider()
		if collider is Player:
			collider.knockback(global_position.direction_to(collider.global_position) * knockback_strength)
			collider.damage(atk)
		movement_direction *= -1

func _on_ranged_area_body_entered(body: Node2D) -> void:
	if body is Player:
		player_in_range_far = true


func _on_ranged_area_body_exited(body: Node2D) -> void:
	if body is Player:
		player_in_range_far = false


func _on_close_area_body_entered(body: Node2D) -> void:
	if body is Player:
		player_in_range_close = true


func _on_close_area_body_exited(body: Node2D) -> void:
	if body is Player:
		player_in_range_close = false


func _on_atk_cooldown_timeout() -> void:
	can_throw = true


func _on_jab_cooldown_timeout() -> void:
	can_jab = true
