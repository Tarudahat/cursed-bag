extends CharEnemy

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
var agro = false
var plyr = null

var init_pos
var reloading = false
var shot_max = 10
var can_shoot = true
var shots = 0

var bullet_node = preload("res://entities/enemies/bullet.tscn")

func _ready() -> void:
	super()
	init_pos = position
	$Sprite2D.material.set_shader_parameter("enabled", false)


func _physics_process(delta: float) -> void:
	if agro:
		var mov_dir = position.direction_to(plyr.position)
		if shots <= shot_max && can_shoot:
			var blast = bullet_node.instantiate()
			blast.speed = 300
			blast.direction = mov_dir
			blast.position = position + blast.direction * 10
			get_parent().add_child(blast)
			can_shoot = false
			shots += 1
			$shotcooldown.start()
			
		if shots > shot_max && !reloading:
			$tp_cooldown.start()
			reloading = true
			position = init_pos + Vector2(randi_range(-1, 1), randi_range(-1, 1)) * 500
			Sounds.evil.play()
			Sounds.evil.position = global_position
			
	velocity = Vector2.ZERO
	char_entity_move_and_slide()
	
	for i in get_slide_collision_count():
		var collider = get_slide_collision(i).get_collider()
		if collider is Player:
			collider.damage(5)


func _on_got_hit(hp) -> void:
	$Sprite2D.material.set_shader_parameter("enabled", true)

func _on_inv_end() -> void:
	$Sprite2D.material.set_shader_parameter("enabled", false)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		agro = true
		plyr = body

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is Player:
		agro = false


func _on_shotcooldown_timeout() -> void:
	can_shoot = true

func _on_tp_cooldown_timeout() -> void:
	shots = 0
	reloading = false
