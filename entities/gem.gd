extends CharacterBody2D

@export var value = 5

var player_node: Player = null
var player_in_range: bool = false

func _ready() -> void:
	$gem/Sprite2D.play(str(randi_range(0, 1)))
	velocity = Vector2(randf_range(-1, 1) * 1300, randf_range(-1, 1) * 1300)

func _physics_process(delta: float) -> void:
	if player_node != null && player_in_range:
		var pull_mulitplyr = 25.0
		if player_node.has_item(Player.Items.GEM_MAGNET):
			pull_mulitplyr = 50.0
		velocity += position.direction_to(player_node.position) * 10 / position.distance_to(player_node.position) / 0.005
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
		player_in_range = false
