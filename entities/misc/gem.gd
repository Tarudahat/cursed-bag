extends CharacterBody2D

@export var value = 1

var player_node: Player = null
var player_in_range: bool = false
var pull_mulitplyr = 42.0

var can_be_collected: bool = false
var is_being_collected: bool = false

var falling_into_hole: bool = false
var hole_global_pos: Vector2

func _ready() -> void:
	$gem/Sprite2D.play(str(randi_range(0, 1)))
	velocity = Vector2(randf_range(-1, 1) * 1300, randf_range(-1, 1) * 1300)
	
	if Globals.player_node.has_item(Player.Items.GEM_MAGNET):
		pull_mulitplyr = 50.0
		$AttractionField/CollisionShape2D.shape.radius *= 1.5

func _physics_process(_delta: float) -> void:
	if falling_into_hole:
		velocity = global_position.direction_to(hole_global_pos) * 100
		rotation += 0.1
		scale *= 0.95
		if scale.x <= 0.1:
			queue_free()

	if player_node != null && player_in_range && can_be_collected && !falling_into_hole:
		set_collision_mask_value(1, false)
		set_collision_mask_value(2, false)
		pull_mulitplyr += 45
		velocity = position.direction_to(player_node.position) * pull_mulitplyr / position.distance_to(player_node.position) / 0.005
	
	if velocity != Vector2.ZERO:
		move_and_slide()

		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			var collider = collision.get_collider()

			var tilemap_layer = collider as TileMapLayer
			if tilemap_layer && Globals.level_node && Globals.level_node.has_node("tilemap") && tilemap_layer == Globals.level_node.get_node("tilemap"):
				var tile_pos = Globals.level_node.global_to_tilemap(collision.get_position())
				hole_global_pos = Globals.level_node.tilemap_to_global(tile_pos)
				var tile_data = tilemap_layer.get_cell_tile_data(tile_pos)
				var is_hole = tile_data.has_custom_data("is_hole") && tile_data.get_custom_data("is_hole")
				if is_hole && !falling_into_hole:
					falling_into_hole = true
					set_collision_mask_value(1, true)
			else:
				velocity = collision.get_normal() * velocity.length() * 0.9


		velocity.x = move_toward(velocity.x, 0, 2.5)
		velocity.y = move_toward(velocity.y, 0, 2.5)

func _on_timer_timeout() -> void:
	can_be_collected = true

func _on_attraction_field_body_entered(body: Node2D) -> void:
	if body is Player:
		player_node = body
		player_in_range = true


func _on_attraction_field_body_exited(body: Node2D) -> void:
	if body is Player:
		player_node = body
		player_in_range = false
		set_collision_mask_value(2, true)


func _on_gem_body_entered(body: Node2D) -> void:
	if body is Player:
		body.gems += value
		self.queue_free()
