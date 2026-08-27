extends Area2D
class_name EnemySpawnArea

static var enemy_resources: Dictionary
const enemy_resource_blacklist: PackedStringArray = ["bullet.tscn", "rocket.tscn", "char_enemy.tscn", "enemy_spawn_area.gd", "static_enemy.tscn", "spike.tscn"]

static var puzzle_resources: Dictionary

static var GROUP_PREFIX: String = "group_area_"
var group_id: int

static var group_member_count: int = 0
var group_member_idx: int

var group_shared_state: Dictionary

var should_spawn_enemies: bool = false
var spawned_enemies: bool = false
var owned_enemies = []

var is_enemy_challenge_room: bool = false
var doors_cleared: bool = false
var door_instances: Array

func load_resources(directory: String, rsrcs_dict: Dictionary, blacklist: PackedStringArray = []) -> void:
	if rsrcs_dict.is_empty():
		var rsrcs = ResourceLoader.list_directory(directory)
		for res in rsrcs:
			if res.ends_with(".tscn") && not (res in blacklist):
				rsrcs_dict[res.get_basename()] = load(directory + "/" + res)


func _ready() -> void:
	# assign group member idx
	group_member_idx = group_member_count

	load_resources("res://entities/enemies", enemy_resources, enemy_resource_blacklist)
	load_resources("res://entities/terrain/puzzles", puzzle_resources)
						
	# set cam boundaries for group
	var min_vec: Vector2 = group_shared_state["cam_limits"][0]
	var max_vec: Vector2 = group_shared_state["cam_limits"][1]

	var collision_shape_extent = $CollisionShape2D.shape.size / 2
	min_vec = Vector2(min(min_vec.x, position.x - collision_shape_extent.x), min(min_vec.y, position.y - collision_shape_extent.y))
	group_shared_state["cam_limits"][0] = min_vec
	
	max_vec = Vector2(max(max_vec.x, position.x + collision_shape_extent.x), max(max_vec.y, position.y + collision_shape_extent.y))
	group_shared_state["cam_limits"][1] = max_vec

	group_member_count += 1

func activate_or_spawn_enemies():
	if spawned_enemies:
		$ActivationTimer.start()
	else:
		should_spawn_enemies = true

func deactivate_enemies():
	$ActivationTimer.stop()
	for enemy in owned_enemies:
		if enemy != null:
			enemy.set_process(false)
			enemy.set_physics_process(false)

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		group_shared_state["player_inside"][group_member_idx] = 1
		get_tree().call_group(GROUP_PREFIX + str(group_id), "activate_or_spawn_enemies")

		# set camera vars for screen change
		if !body.screen_change_cam_target_set && body.should_change_screen_target && body.moved_room:
			body.screen_change_cam_target = global_position
			body.get_node("Camera2D").global_position = body.get_node("Camera2D").get_screen_center_position()
			body.screen_change_cam_target_set = true
			
		body.group_cam_limits = group_shared_state["cam_limits"]
		
func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		group_shared_state["player_inside"][group_member_idx] = 0
		if group_shared_state["player_inside"].count(1) == 0: # player left all of them safe to deactivate
			get_tree().call_group(GROUP_PREFIX + str(group_id), "deactivate_enemies")
		
func _process(_delta: float) -> void:
	if spawned_enemies && is_enemy_challenge_room && !doors_cleared:
		group_shared_state["all_enemies_defeated"][group_member_idx] = int(owned_enemies.is_empty() || !owned_enemies.any(func(enemy): return is_instance_valid(enemy)))
		if group_shared_state["all_enemies_defeated"].count(0) == 0:
			clear_enemy_doors()

	if should_spawn_enemies:
		spawn_enemies()

		deactivate_enemies()
		$ActivationTimer.start()
		should_spawn_enemies = false
		spawned_enemies = true

		if is_enemy_challenge_room && Globals.level_node:
			spawn_enemy_doors()

func spawn_enemies():
	var enemy = null
	var choice = randi_range(0, enemy_resources.size() - 1)
	var enemy_count = 0

	if choice == 0:
		enemy_count = randi_range(2, 5) + Globals.current_level * 2
	elif choice == 1:
		enemy_count = 1 + Globals.current_level
		if enemy_count > 3:
			enemy_count = 3
	elif choice == 2:
		enemy_count = 1 + Globals.current_level
		if enemy_count > 3:
			enemy_count = 3
	else:
		enemy_count = 2 + Globals.current_level
		if enemy_count > 3:
			enemy_count = 3

	# todo make enemy groups/ classes -> 
	# main atk, mini boss, support
	# 

	# todo make sure this does not end up on the doors
	for i in range(enemy_count):
		var rnd_pos_offset = Vector2(randi_range(-4, 4) * 355 / 2.0, randf_range(-1.5, 1.5) * 300.0 / 2.0)

		match choice:
			0:
				enemy = enemy_resources["ghost"].instantiate()
			1:
				enemy = enemy_resources["turret"].instantiate()
			2:
				enemy = enemy_resources["caster"].instantiate()
				enemy.position = position
			3:
				enemy = enemy_resources["spear_crab"].instantiate()
				if global_position.x + 2000 > Globals.player_node.global_position.x || global_position.x - 2000 < Globals.player_node.global_position.x:
					enemy.movement_direction = Vector2.UP
			4:
				enemy = enemy_resources["artillery"].instantiate()
			5:
				enemy = enemy_resources["bomb_buddy"].instantiate()
			6:
				enemy = enemy_resources["puff_shroom"].instantiate()
			7:
				enemy = enemy_resources["mage"].instantiate()
			_:
				enemy = enemy_resources["bomb_buddy"].instantiate()
				
		if choice != 2:
			enemy.global_position = global_position + rnd_pos_offset

		if enemy.get_parent() != null:
			owned_enemies.erase(enemy)
			get_parent().remove_child(enemy)

		get_parent().add_child(enemy)
		owned_enemies.append(enemy)
		if choice == 2:
			enemy.global_position = global_position + rnd_pos_offset

func spawn_enemy_doors() -> void:
	for door_data in Globals.level_node.room_door_data[group_id]:
				var door_pos = door_data[0]
				var door_inst = puzzle_resources["enemy_door"].instantiate()

				door_instances.append(door_inst)
				door_inst.global_position = door_pos
				get_parent().add_child(door_inst)

func clear_enemy_doors() -> void:
	for door in door_instances:
		if door:
			door.queue_free()
	doors_cleared = true

func _on_activation_timer_timeout() -> void:
	for enemy in owned_enemies:
		if enemy != null:
			enemy.set_process(true)
			enemy.set_physics_process(true)
