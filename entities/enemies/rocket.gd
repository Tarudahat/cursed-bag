extends Area2D

var explosion = preload("res://entities/explosion_area.tscn")

var knockback_strength = 6000
var should_explode: bool = false

var owner_entity = null
var start_position: Vector2
var target_position: Vector2
var middle_position: Vector2

var speed = 400
var velocity: Vector2
var t: float = 0.0
var collision_threshold_t: float = 0.98

func _ready() -> void:
	$AnimatedSprite2D.play("default")
	start_position = global_position
	middle_position = target_position * 1.3 + start_position.direction_to(target_position).orthogonal() * 1100
	$TargetMarker.top_level = true
	$TargetMarker.global_position = target_position
	set_collision_mask_value(5, false)
	set_collision_mask_value(3, false)
	set_collision_mask_value(4, false)

func _physics_process(delta: float) -> void:		
	velocity = global_position.direction_to(target_position) * speed * target_position.distance_to(start_position) * 0.001
	t = global_position.distance_to(start_position)\
		/ target_position.distance_to(start_position)
	
	$AnimatedSprite2D.look_at(Globals.bezier_curve(start_position, middle_position, target_position, t))
	$AnimatedSprite2D.scale = Vector2(2,2) * $AnimatedSprite2D.global_position.distance_to(global_position) / 355 / 2
	
	$AnimatedSprite2D.scale.x = clampf($AnimatedSprite2D.scale.x, 1, 1.5)
	$AnimatedSprite2D.scale.y = clampf($AnimatedSprite2D.scale.y, 1, 1.5)
	
	$AnimatedSprite2D.global_position = Globals.bezier_curve(start_position, middle_position, target_position, t) - velocity * delta
			
	if t >= collision_threshold_t:
		set_collision_mask_value(5, true)
		set_collision_mask_value(3, true)
		set_collision_mask_value(4, true)
		$CollisionShape2D.disabled = false
	
	global_position += velocity * delta
	
	if should_explode || t >= 1.0:
		var instance = explosion.instantiate()
		instance.global_position = global_position
		get_parent().add_child(instance)
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.get_parent() is Player && body.get_name() == "Shield" && t >= collision_threshold_t:
		body.get_parent().knockback(global_position.direction_to(body.global_position) * knockback_strength)
	if body != owner_entity:
		should_explode = true
