extends CharacterBody2D

@export var value = 1

var player_node: Player = null
var player_in_range: bool = false
var pull_mulitplyr = 42.0

var can_be_collected: bool = false
var is_being_collected: bool = false

func _ready() -> void:
	$gem/Sprite2D.play(str(randi_range(0, 1)))
	velocity = Vector2(randf_range(-1, 1) * 1300, randf_range(-1, 1) * 1300)
	
	if Globals.player_node.has_item(Player.Items.GEM_MAGNET):
		pull_mulitplyr = 50.0
		$AttractionField/CollisionShape2D.shape.radius *= 1.5

func _physics_process(delta: float) -> void:
	if player_node != null && player_in_range && can_be_collected:
		set_collision_mask_value(1, false)
		pull_mulitplyr += 45
		velocity = position.direction_to(player_node.position) * pull_mulitplyr / position.distance_to(player_node.position) / 0.005
	if velocity != Vector2.ZERO:
		move_and_slide()

		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			velocity = collision.get_normal() * velocity.length() * 0.9
	
		velocity.x = move_toward(velocity.x, 0, 2.5)
		velocity.y = move_toward(velocity.y, 0, 2.5)

func _on_gem_area_entered(area: Area2D) -> void:
	if area.get_parent() is Player and area != null and area.get_name() == "atk_hitbox":
		area.get_parent().gems += value
		self.queue_free()

func _on_attraction_field_area_entered(area: Area2D) -> void:
	if area.get_parent() is Player and area != null and area.get_name() == "atk_hitbox":
		player_node = area.get_parent()
		player_in_range = true

func _on_attraction_field_area_exited(area: Area2D) -> void:
	if area.get_parent() is Player and area != null and area.get_name() == "atk_hitbox":
		player_node = area.get_parent()
		player_in_range = false

func _on_timer_timeout() -> void:
	can_be_collected = true
