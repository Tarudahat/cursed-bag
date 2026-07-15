extends Area2D
class_name EnemySpawnArea

static var enemy_resources: Dictionary
const enemy_resource_blacklist: PackedStringArray = ["bullet.tscn", "char_enemy.tscn", "enemy_spawn_area.gd", "static_enemy.tscn"]

static var GROUP_PREFIX: String = "group_area_"
var group_id: int

static var group_member_count: int = 0
var group_member_idx: int
var group_state_array: PackedByteArray
var group_cam_limits: PackedVector2Array

var should_spawn_enemies: bool = false
var spawned_enemies: bool = false
var owned_enemies = []

func _ready() -> void:
	# assign group member idx
	group_member_idx = group_member_count

	# load rsrcs
	if enemy_resources.is_empty():
		var rsrcs = ResourceLoader.list_directory("res://entities/enemies")
		for res in rsrcs:
			if res.ends_with(".tscn") && not (res in enemy_resource_blacklist):
				enemy_resources[res.get_basename()] = load("res://entities/enemies" + "/" + res)
			
	# set cam boundaries for group
	var min_vec: Vector2 = group_cam_limits[0]
	var max_vec: Vector2 = group_cam_limits[1]

	var collision_shape_extent = $CollisionShape2D.shape.size / 2
	min_vec = Vector2(min(min_vec.x, position.x - collision_shape_extent.x), min(min_vec.y, position.y - collision_shape_extent.y))
	group_cam_limits[0] = min_vec
	
	max_vec = Vector2(max(max_vec.x, position.x + collision_shape_extent.x), max(max_vec.y, position.y + collision_shape_extent.y))
	group_cam_limits[1] = max_vec

	group_member_count += 1

func activate_or_spawn_enemies():
	if spawned_enemies:
		for enemy in owned_enemies:
			if enemy != null:
				enemy.set_process(true)
				enemy.set_physics_process(true)
	else:
		should_spawn_enemies = true

func deactivate_enemies():
	for enemy in owned_enemies:
		if enemy != null:
			enemy.set_process(false)
			enemy.set_physics_process(false)

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		group_state_array[group_member_idx] = 1
		get_tree().call_group(GROUP_PREFIX + str(group_id), "activate_or_spawn_enemies")

		if !body.screen_change_cam_target_set && body.should_change_screen_target && body.moved_room:
			body.screen_change_cam_target = global_position
			body.get_node("Camera2D").global_position = body.get_node("Camera2D").get_screen_center_position()
			body.screen_change_cam_target_set = true
			
		body.group_cam_limits = group_cam_limits
		
func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		group_state_array[group_member_idx] = 0
		if group_state_array.count(1) == 0: # player left all of them safe to deactivate
			get_tree().call_group(GROUP_PREFIX + str(group_id), "deactivate_enemies")
		
func _process(_delta: float) -> void:
	if should_spawn_enemies:
		spawn_enemies()
		should_spawn_enemies = false
		spawned_enemies = true

func spawn_enemies():
	var enemy = null
	var choice = randi_range(0, 2)
	var count = 0

	if choice == 0:
		count = randi_range(2, 5) + Globals.current_level * 2
	elif choice == 1:
		count = 1 + Globals.current_level
		if count > 3:
			count = 3
	elif choice == 2:
		count = 1 + Globals.current_level
		if count > 3:
			count = 3

	var rnd_pos_offset = Vector2(randi_range(-4, 4) * 355 / 2.0, randf_range(-1.5, 1.5) * 355.0 / 2.0)
	# todo make sure this does not end up on the doors

	for i in range(count):
		if choice == 0:
			enemy = enemy_resources["ghost"].instantiate()
		elif choice == 1:
			enemy = enemy_resources["turret"].instantiate()
		else:
			enemy = enemy_resources["caster"].instantiate()
			enemy.position = position

		if choice != 2:
			enemy.position = position + rnd_pos_offset

		if enemy.get_parent() != null:
			owned_enemies.erase(enemy)
			get_parent().remove_child(enemy)

		get_parent().add_child(enemy)
		owned_enemies.append(enemy)
		if choice == 2:
			enemy.position = position + rnd_pos_offset
