extends CharEnemy
class_name Ghost

@export var SPEED = 150.0
@export var atk = 5

var plyr = null
var init_pos = Vector2.ZERO
var agro = false
var moving_to_target = false

func _ready() -> void:
	super()
	init_pos = position
	$AnimatedSprite2D.play()

func _physics_process(delta: float) -> void:
	if position.distance_to(init_pos) > 1200:
		position = init_pos
	
	if not agro && not moving_to_target:
		velocity = Vector2(randi_range(-1,1),randi_range(-1,1)) * SPEED
		moving_to_target = true
		$movement_timer.start()
	
	if agro && plyr != null:
		var mov_dir = position.direction_to(plyr.position)
		$AnimatedSprite2D.flip_h = mov_dir.x >= 0
		velocity = mov_dir * SPEED * 1.2
	
	move_and_slide()

	for i in get_slide_collision_count():
		var collider = get_slide_collision(i).get_collider()
		if collider is Player:
			collider.damage(atk)

func _on_movement_timer_timeout() -> void:
	moving_to_target = false

func _on_got_hit(hp, val) -> void:
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
