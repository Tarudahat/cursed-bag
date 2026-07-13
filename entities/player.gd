extends CharacterBody2D
class_name Player

const SPEED = 720.0
const JUMP_VELOCITY = -400.0

const CAM_SPEED = 800
const MAX_CAM_DIST = 300.0

var cam_target_distance = 0
var cam_target_direction: Vector2
var group_cam_limits: PackedVector2Array

enum Items {GEM_MAGNET}
var inventory: Array[Items] = []
var current_room_id: int = -1

var current_sword_look = Vector2.ZERO
var current_sword_speed = 20
var mouse_speed = 0

var can_jump = true
var air_t = 0
var in_air = false

const hp_max = 100
const atk_max = 25

var hp = hp_max
var atk = atk_max;

var is_inv = false
var gems = 0
var keys = 0
var curse_cap = 500

var attacking = false
var attacking_cooldown = false
var atk_angl = 0.0
var atk_angl_init = 0.0

var perma_shield = false

var can_fire = true
var fire_cooldown = false
var blast_node = preload("res://entities/sword_blast.tscn")
var player_ui_rsrc = preload("res://entities/player_ui.tscn")
var cam_is_moving: bool = false

func _ready() -> void:
	Globals.player_node = self
	var player_ui = player_ui_rsrc.instantiate()
	get_parent().get_parent().add_child.call_deferred(player_ui)
	
	if Globals.player_gems != -1:
		gems = Globals.player_gems
		hp = Globals.player_current_hp
		perma_shield = Globals.perm_shield
		curse_cap = Globals.curse_cap
	else:
		hp = hp_max
		atk = atk_max
		gems = 0
		Globals.curse_cap = curse_cap
	
	$sprite.material.set_shader_parameter("enabled", false)
	
	$Camera2D.global_position = global_position


func _process(delta: float) -> void:
	# camera panning
	if !group_cam_limits.is_empty():
		$Camera2D.limit_top = group_cam_limits[0].y
		$Camera2D.limit_left = group_cam_limits[0].x
		$Camera2D.limit_bottom = group_cam_limits[1].y
		$Camera2D.limit_right = group_cam_limits[1].x

	var a = curse_cap - gems

	if hp <= 0:
		Globals.player_gems = 0
		Globals.player_current_hp = hp_max
		Globals.current_level = 0
		Globals.game_over()
	else:
		if Globals.player_gems != gems: # got gems
			a = curse_cap - gems
			if a <= 0:
				a = float(curse_cap) / 10
			
			if hp > hp_max * (float(a) / curse_cap): # cap
				hp = round(hp_max * (float(a) / curse_cap))
			if atk > atk_max * (float(a) / curse_cap): # cap
				atk = round(atk_max * (float(a) / curse_cap))
				
			Globals.player_gems = gems
		
		Globals.player_current_hp = hp
	
	if (gems >= curse_cap * 0.70):
		can_jump = false
	
	if (gems >= curse_cap * 0.35) && not perma_shield:
		$Shield.set_collision_layer_value(4, false)
		$Shield.visible = false
	else:
		$Shield.set_collision_layer_value(4, true)
		$Shield.visible = true
	
	if $Shield.visible == false && perma_shield:
		$Shield.set_collision_layer_value(4, true)
		$Shield.visible = true
	
	# can fire?
	can_fire = !(gems >= curse_cap * 0.25)
	
	if Input.is_action_pressed("fire_btn"):
		if can_fire && !fire_cooldown:
			Sounds.bullet.play()
			Sounds.bullet.position = global_position
			var blast = blast_node.instantiate()
			blast.direction = current_sword_look.normalized()
			blast.rotation = $Sword.rotation
			blast.position = $Sword.global_position + blast.direction * 200
			get_parent().add_child(blast)
			fire_cooldown = true
			$blast_timer.start()
			
	if Input.is_action_pressed("hit_btn") && !attacking && !attacking_cooldown:
		attacking = true
		attacking_cooldown = true
		atk_angl_init = (get_local_mouse_position() - $Sword.position).angle()
		atk_angl = atk_angl_init - PI / 2.5
		Sounds.sword.play()
		Sounds.sword.position = global_position
		
	if Input.is_action_just_pressed("ui_accept") && !in_air && can_jump:
		in_air = true
		
		
func _physics_process(delta: float) -> void:
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	if direction == Vector2.UP:
		$sprite.play("back")
	elif direction == Vector2.DOWN:
		$sprite.play("front")
	elif direction != Vector2.ZERO:
		$sprite.play("side")
		$sprite.flip_h = direction.x > 0
	
	
	if fposmod($Sword.rotation, PI * 2) < PI * 4 / 5:
		$Sword.z_index = 2
	else:
		$Sword.z_index = 0
	if direction:
		velocity = direction * SPEED
		cam_target_distance = move_toward(cam_target_distance, MAX_CAM_DIST, SPEED * delta / 2)
		cam_target_distance = clamp(cam_target_distance, -MAX_CAM_DIST, MAX_CAM_DIST)
		cam_target_direction = direction
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.y = move_toward(velocity.y, 0, SPEED)
	
	var cam_target = global_position + cam_target_direction * cam_target_distance
	$Camera2D.global_position.x = move_toward($Camera2D.global_position.x, cam_target.x, CAM_SPEED * delta)
	$Camera2D.global_position.y = move_toward($Camera2D.global_position.y, cam_target.y, CAM_SPEED * delta)
		
	var target_look_coord = get_local_mouse_position()
	
	if !attacking:
		mouse_speed = max(mouse_speed, Input.get_last_mouse_velocity().length())
		
		current_sword_speed = move_toward(current_sword_speed, mouse_speed, 5)
		
		current_sword_look.x = move_toward(current_sword_look.x, target_look_coord.x, current_sword_speed)
		current_sword_look.y = move_toward(current_sword_look.y, target_look_coord.y, current_sword_speed)
	else:
		atk_angl += 0.15
		current_sword_look = Vector2(cos(atk_angl), sin(atk_angl))
		if atk_angl > atk_angl_init + PI / 2.5:
			$atk_timer.start()
			attacking = false
	
	if in_air:
		set_collision_mask_value(2, false) # let pass through
		$atk_hitbox.set_collision_mask_value(2, false) # let pass through no dmg
		if air_t < PI / 2:
			air_t += 4 * delta
		else:
			air_t += 3.6 * delta
			
		$sprite.position.y = sin(air_t) * -150
		$atk_hitbox.position.y = sin(air_t) * -150
		$Sword.position.y = sin(air_t) * -150
		$Shield.position.y = sin(air_t) * -150
		if sin(air_t) < 0:
			$sprite.position.y = 0
			$atk_hitbox.position.y = 0
			$Sword.position.y = 0
			$Shield.position.y = 0
			in_air = false
			set_collision_mask_value(2, true)
			$atk_hitbox.set_collision_mask_value(2, true) # let pass through no dmg
			
			air_t = 0
			
		
	$Sword.look_at(to_global(current_sword_look + $Sword.position))
	$Shield.look_at(to_global(target_look_coord))
		
	move_and_slide()

# functions for entity interaction

func damage(amount: int) -> void:
	if amount > 0:
		if !is_inv:
			is_inv = true
			$sprite.material.set_shader_parameter("enabled", true)
			$dmg_timer.start()
			hp -= amount
	else:
		hp -= amount

func has_item(item: Items) -> bool:
	return item in inventory

func add_item(item: Items):
	inventory.append(item)

# signals
func _on_blast_timer_timeout() -> void:
	fire_cooldown = false

func _on_atk_timer_timeout() -> void:
	attacking_cooldown = false


func _on_dmg_timer_timeout() -> void:
	$sprite.material.set_shader_parameter("enabled", false)
	is_inv = false


func _on_sword_body_entered(body: Node2D) -> void:
	if attacking:
		if body is StaticEnemy or body is CharEnemy:
			body.damage(atk)
