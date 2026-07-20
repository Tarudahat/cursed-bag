extends Node2D
class_name Level

@export var rooms = 5
@export var room_size := Vector2i(16, 10)
@export var wall_count := 1
@export var constructions_count := 1
@export var hole_gen_rate := 50
@export var pot_gen_rate := 100
@export var max_pot_count := 10
@export var minimum_rooms_before_lock_count := 6

var tp_area = preload("res://tp_area.tscn")
var exit = preload("res://scenes/next_lvl.tscn")
var shop = preload("res://scenes/shop.tscn")

var pot = preload("res://entities/terrain/pot.tscn")

var locked_door = preload("res://scenes/locked_door.tscn")
var key = preload("res://entities/misc/key.tscn")

var enemy_spawner = preload("res://entities/enemies/enemy_spawn_area.tscn")
var spawned_mobs = false

var room_buf := []
var walls_buf := []
var constructions_buf := []

var doors_buf := []
var door_placement_buf: Array[Array] = []
var room_pos_tiles: Array[Vector4i] = []

var map := Array()
var min_coord := Vector2i.MAX
var map_size := Vector2i.ZERO

var fused_rooms_count: int = 0

const door_tiles_src_pos = [Vector2i(0, -2), Vector2i(0, -1), Vector2i(1, -2), Vector2i(1, -1), Vector2i(2, -2), Vector2i(3, -2), Vector2i(2, -1), Vector2i(3, -1)]
const merge_patterns = \
[
	[], # 0 reserved for none
	[Vector3i(0, 0, 1), Vector3i(0, 1, 4), Vector3i(1, 0, 2), Vector3i(1, 1, 3)], # sqr
	[Vector3i(0, 0, 7), Vector3i(0, 1, 8)], # straight |
	[Vector3i(0, 0, 6), Vector3i(1, 0, 5)], # straight -
	[Vector3i(0, 0, 0)], # single
]
const merge_rates = \
[
	0,
	30,
	40,
	30,
	100
]

		
func global_to_tilemap(global_coord: Vector2) -> Vector2i:
	var on_tilemap_coord = $tilemap.local_to_map(to_local(global_coord) * 2) * 1.0
	return on_tilemap_coord

func global_to_room(global_coord: Vector2) -> Vector2i:
	var coord = global_to_tilemap(global_coord) * 1.0 / (room_size * 1.0) - min_coord * 1.0
	return coord

func tilemap_to_global(tilemap_coord: Vector2i) -> Vector2:
	return to_global($tilemap.map_to_local(tilemap_coord) * 0.5)


func get_room_pos(v4: Vector4i) -> Vector2i:
	return Vector2i(v4.x, v4.y)

func get_room_merge_state(v4: Vector4i) -> int:
	return v4.z

func get_room_biome(v4: Vector4i) -> int:
	return v4.w

func place_door(pos: Vector2i, dir: Vector2, tilemap: TileMapLayer = $tilemap):
	var door_pos = tilemap.map_to_local(pos) * 0.5
	var door_dis = 475
	
	var tp = tp_area.instantiate()
	var tp2 = tp_area.instantiate()
	
	if dir == Vector2.UP:
		paste_tile_region(pos, doors_buf[2])
		paste_tile_region(pos + Vector2i.UP * 3, doors_buf[3])
		door_pos += Vector2.RIGHT * 84
		door_pos += Vector2.UP * 30
	elif dir == Vector2.DOWN:
		paste_tile_region(pos, doors_buf[3])
		paste_tile_region(pos + Vector2i.DOWN * 3, doors_buf[2])
		door_pos += Vector2.RIGHT * 84
		door_pos += Vector2.DOWN * 30
	elif dir == Vector2.LEFT:
		paste_tile_region(pos, doors_buf[0])
		paste_tile_region(pos + Vector2i.LEFT * 3, doors_buf[1])
		door_pos += Vector2.DOWN * 84
		door_pos += Vector2.LEFT * 84
		door_dis = 356
		tp.dist = 750 - 100
		tp2.dist = 750 - 100
	else: # RIGHT
		paste_tile_region(pos, doors_buf[1])
		paste_tile_region(pos + Vector2i.RIGHT * 3, doors_buf[0])
		door_pos += Vector2.DOWN * 84
		door_pos += Vector2.RIGHT * 84
		door_dis = 356
		tp.dist = 750 - 100
		tp2.dist = 750 - 100
		
	tp.dir = dir
	tp.position = door_pos
	tp2.dir = dir * -1
	tp2.position = door_pos + dir * door_dis

	add_child(tp)
	add_child(tp2)
	
func copy_tile_region(from_pos: Vector2i, region_size: Vector2i, buffer: Array, tilemap: TileMapLayer = $tilemap):
	buffer.clear()

	for x in region_size.x:
		buffer.append([])
		for y in region_size.y:
			var pos = from_pos + Vector2i(x, y)

			var source_id = tilemap.get_cell_source_id(pos)

			if source_id == -1:
				buffer[x].append(null)
			else:
				buffer[x].append({
					"source_id": source_id,
					"atlas_coords": tilemap.get_cell_atlas_coords(pos),
					"alternative": tilemap.get_cell_alternative_tile(pos)
				})
				
func paste_tile_region(to_pos: Vector2i, buffer: Array, tilemap: TileMapLayer = $tilemap):
	if buffer.is_empty():
		return

	for x in buffer.size():
		for y in buffer[0].size():
			var data = buffer[x][y]
			var target = to_pos + Vector2i(x, y)

			if data != null:
				tilemap.set_cell(
					target,
					data.source_id,
					data.atlas_coords,
					data.alternative
				)

func clear_tile_region(from_pos: Vector2i, region_size: Vector2i, tilemap: TileMapLayer = $tilemap):
	for x in region_size.x:
		for y in region_size.y:
			var pos = from_pos + Vector2i(x, y)
			tilemap.erase_cell(pos)

func init_map_buffers():
	# copy the door tiles into buffers
	doors_buf.append_array([[], [], [], []])
	copy_tile_region(door_tiles_src_pos[0], Vector2i(1, 2), doors_buf[0])
	copy_tile_region(door_tiles_src_pos[2], Vector2i(1, 2), doors_buf[1])
	copy_tile_region(door_tiles_src_pos[4], Vector2i(2, 1), doors_buf[2])
	copy_tile_region(door_tiles_src_pos[6], Vector2i(2, 1), doors_buf[3])

	# clear door tiles
	for p in door_tiles_src_pos:
		$tilemap.erase_cell(p)

	# copy rooms and walls into buffers	
	copy_tile_region(Vector2i(0, 0), room_size, room_buf)

	for wall in wall_count:
		walls_buf.append([])
		copy_tile_region(Vector2i(0, room_size.y * (1 + wall)), room_size, walls_buf[wall])
	
	# clear wall tiles
	clear_tile_region(Vector2i(0, room_size.y), room_size * Vector2i(1, wall_count))

	# copy constructions into buffers
	for construction in constructions_count:
		constructions_buf.append([])
		copy_tile_region(Vector2i(0, room_size.y * (1 + construction)), room_size, constructions_buf[construction])

	# clear wall tiles
	clear_tile_region(Vector2i(room_size.x, 0), room_size * Vector2i(1, constructions_count))
				
func gen_map_layout():
	var current_room = Vector4i(0, 0, 0, 0)
	room_pos_tiles.append(current_room)
	var should_lock_rooms_pos: Array = []

	min_coord = Vector2i.ZERO
	var max_coord = Vector2i.ZERO

	for r in range(1, rooms):
		var dx = 0
		var dy = 0
		var new_room = current_room
		var should_lock_entrance = false
		while true:
			dx = 0
			dy = 0
			
			# choose a direction in which to place a new room
			if randi_range(0, 1) == 0:
				dx = randi_range(-1, 1)
				dy = 0
			else:
				dx = 0
				dy = randi_range(-1, 1)

			if dx == 0 and dy == 0:
				continue
				
			# 20% - to generate adjacent to an existing room
			if randi_range(0, 100) > 80:
				current_room = room_pos_tiles[randi_range(0, len(room_pos_tiles) - 1)]
				# mark entry to new room as should lock
				should_lock_entrance = room_pos_tiles.size() >= minimum_rooms_before_lock_count && randi_range(0, 100) > 0 # - (r / rooms) * 85

			# calc new room coord
			new_room = current_room + Vector4i(dx * room_size.x, dy * room_size.y, 0, 0)
			
			# ignore if it would overwrite a room
			if new_room in room_pos_tiles:
				continue
			break
			
		# place the new room next
		paste_tile_region(get_room_pos(new_room), room_buf)
		room_pos_tiles.append(new_room)
		
		# add holes/ mazify
		if randi_range(0, 100) >= 100 - hole_gen_rate:
			gen_line_holes(get_room_pos(new_room))

		# store to-be-placed doors
		if r < rooms:
			# cur -> new, exit door + entry door
			if new_room.y < current_room.y:
				door_placement_buf.append([get_room_pos(current_room), Vector2.UP, should_lock_entrance])
			elif new_room.y > current_room.y:
				door_placement_buf.append([get_room_pos(new_room), Vector2.DOWN, should_lock_entrance])
			if new_room.x < current_room.x:
				door_placement_buf.append([get_room_pos(current_room), Vector2.LEFT, should_lock_entrance])
			elif new_room.x > current_room.x:
				door_placement_buf.append([get_room_pos(new_room), Vector2.RIGHT, should_lock_entrance])

		current_room = new_room

		# determine min & max for (mini)map offset
		min_coord.x = min(new_room.x, min_coord.x)
		min_coord.y = min(new_room.y, min_coord.y)

		max_coord.x = max(new_room.x, max_coord.x)
		max_coord.y = max(new_room.y, max_coord.y)
	
	# apparently the coords were tilemap coords... 
	min_coord /= room_size
	max_coord /= room_size

	# make a grid version of the map for further processing
	map_size = Vector2i(max_coord.x - min_coord.x + 1, max_coord.y - min_coord.y + 1)
	for col in map_size.y:
		map.append([])
		for row in map_size.x:
			map[col].resize(map_size.x)
			map[col].fill(null)

	for room in room_pos_tiles:
		var coord = get_room_pos(room)
		coord /= room_size
		coord -= min_coord
		map[coord.y][coord.x] = Vector2i(0, get_room_biome(room))
		

	var exit_node = exit.instantiate()
	exit_node.position = ($tilemap.map_to_local(get_room_pos(current_room)) + Vector2(7.5 * 355, 4.5 * 355)) * 0.5
	add_child(exit_node)
	move_child(exit_node, 1)
	

# is the given pattern found at the given position on the map?
func can_fuse(pos: Vector2i, pattern_id: int):
	for comp in merge_patterns[pattern_id]:
		var room_pos = pos + Vector2i(comp.x, comp.y)
		if room_pos.y >= map_size.y || room_pos.x >= map_size.x:
			return false
		var tile = map[room_pos.y][room_pos.x]
		if tile == null || tile.x != 0:
			return false
	return true

func fuse(pos: Vector2i, pattern_id: int):
	var fused_area_state_array: PackedByteArray
	var group_cam_limits: PackedVector2Array = [Vector2(INF, INF), Vector2(-1 * INF, -1 * INF)]
	fused_area_state_array.resize(merge_patterns[pattern_id].size())
	EnemySpawnArea.group_member_count = 0
	
	for comp in merge_patterns[pattern_id]:
		var room_pos = pos + Vector2i(comp.x, comp.y)
		var tile = map[room_pos.y][room_pos.x]
		
		# fuse spawn areas by adding to the same group
		var spawn_enemies = !(room_pos + min_coord == Vector2i.ZERO)
		place_enemy_spawner((room_pos + min_coord) * room_size, fused_rooms_count, fused_area_state_array, group_cam_limits, spawn_enemies)
		
		if tile != null:
			map[room_pos.y][room_pos.x].x = pattern_id
			paste_tile_region((room_pos + min_coord) * room_size, walls_buf[comp.z])
	fused_rooms_count += 1

# merge rooms and place walls and constructions
func gen_map_walls():
	for row in range(0, map_size.y):
		for col in range(0, map_size.x):
			if map[row][col] == null:
				continue
			var room_pos: Vector2i = Vector2i(col, row)
		
			for fuse_pattern_id in merge_patterns.size():
				if randi_range(0, 100) >= 100 - merge_rates[fuse_pattern_id] && can_fuse(room_pos, fuse_pattern_id):
					fuse(room_pos, fuse_pattern_id)
				
# place doors if still needed
func gen_map_doors():
	var key_having_rooms = []

	var room_idx = 0
	for door_placement in door_placement_buf:
		var tilemap_pos = door_placement[0]
		# calc door position
		match door_placement[1]:
			Vector2.UP:
				tilemap_pos += Vector2i(floor(room_size.x / 2.0 - 1), 1)
			Vector2.DOWN:
				tilemap_pos += Vector2i(floor(room_size.x / 2.0 - 1), -2)
			Vector2.LEFT:
				tilemap_pos += Vector2i(1, floor(room_size.y / 2.0 - 1))
			Vector2.RIGHT:
				tilemap_pos += Vector2i(-2, floor(room_size.y / 2.0 - 1))

		# place door
		if $tilemap.get_cell_atlas_coords(tilemap_pos) != Vector2i(2, 1): # evil magic number
			var key_room_idx = randi_range(minimum_rooms_before_lock_count, room_idx)

			while key_room_idx < door_placement_buf.size() && door_placement_buf[key_room_idx][2] || key_room_idx in key_having_rooms:
				key_room_idx = randi_range(minimum_rooms_before_lock_count, key_room_idx - 1)
				
			if key_room_idx - 1 <= minimum_rooms_before_lock_count || key_room_idx >= door_placement_buf.size(): # can't place key in a proper room
				door_placement[2] = false
					
			if door_placement[2]:
				# gen locked door
				var locked_door_inst = locked_door.instantiate()
				var locked_door_inst2 = locked_door.instantiate()

				locked_door_inst.direction = door_placement[1]
				locked_door_inst2.direction = -1 * door_placement[1]

				locked_door_inst.position = $tilemap.map_to_local(tilemap_pos) * 0.5
				self.add_child(locked_door_inst)

				# gen key in one of the previous rooms
				var key_inst = key.instantiate()
				key_inst.position = $tilemap.map_to_local(door_placement_buf[key_room_idx][0] + Vector2i(floor(room_size.x / 2.0 - 1), floor(room_size.y / 2.0 - 1))) * 0.5
				self.add_child(key_inst)

				var locked_door2_dist = 534

				locked_door_inst2.position = $tilemap.map_to_local(tilemap_pos) * 0.5 + locked_door_inst.direction * locked_door2_dist
				key_having_rooms.append(key_room_idx)
				self.add_child(locked_door_inst2)
				
				locked_door_inst.twin_node = locked_door_inst2
				locked_door_inst2.twin_node = locked_door_inst
				

			# place the door
			place_door(tilemap_pos, door_placement[1])
		room_idx += 1
		
		
func gen_pots():
	for door_placement in door_placement_buf:
		var tilemap_pos = door_placement[0]
		if randi_range(0, 100) >= 100 - pot_gen_rate:
			spawn_pots(tilemap_pos)

# given a polygon representing the room places an open rectangle of holes on the floor
func gen_line_holes(room_tilemap_position: Vector2i):
	var hole_rect: Array = [Vector2(-1, -1), Vector2(1, -1), Vector2(1, 1), Vector2(-1, 1)]
	hole_rect = hole_rect.map(func(el): return el * randi_range(3, 5) + Vector2(room_size) / 2)
	var room_rect: PackedVector2Array = [Vector2(randi_range(0, 4), randi_range(0, 4)), Vector2(room_size.x, 0), Vector2(room_size) - Vector2(randi_range(0, 2), randi_range(0, 2)), Vector2(0, room_size.y)]
	var intersection = Geometry2D.intersect_polygons(PackedVector2Array(hole_rect), room_rect)

	if intersection.is_empty():
		return
	intersection = intersection[0]

	for v0_idx in intersection.size():
		var v1_idx = (v0_idx + 1)%intersection.size()
		var v0 = Vector2i(intersection[v0_idx])
		var v1 = Vector2i(intersection[v1_idx])
		var e = (v0 - v1)

		# skip edges on the edge of the map
		if e.x == 0 || e.y == 0:
			continue

		var line = Geometry2D.bresenham_line(v0, v1)
		var keep_empty_tile_pos = line[clampi((line.size() - 2 + randi_range(0, 1)) / 2, 0, (line.size() - 1) / 2)]
		for tile_pos in line:
			if $tilemap.get_cell_atlas_coords(tile_pos + room_tilemap_position) == Vector2i(2, 1) && tile_pos != keep_empty_tile_pos:
				$tilemap.set_cell(
						tile_pos + room_tilemap_position,
						0,
						Vector2i(0, 3),
						0
					)
					
func spawn_pots(room_pos: Vector2i):
	for i in range(randi_range(0, max_pot_count)):
		var rel_pos = Vector2i.ZERO
		match randi_range(0, 3):
			0:
				rel_pos.x += randi_range(0, room_size.x - 5)
			1:
				rel_pos.y = room_size.y - 5
				rel_pos.x += randi_range(0, room_size.x - 5)
			2:
				rel_pos.y += randi_range(0, room_size.y - 5)
			3:
				rel_pos.y += randi_range(0, room_size.y - 5)
				rel_pos.x = room_size.x - 5
				

		var pot_map_position = room_pos + rel_pos + Vector2i(2, 2)

		if $tilemap.get_cell_atlas_coords(pot_map_position) == Vector2i(2, 1) && \
			$tilemap.get_cell_atlas_coords(pot_map_position + Vector2i.UP) == Vector2i(4, 0) || \
			$tilemap.get_cell_atlas_coords(pot_map_position + Vector2i.DOWN) == Vector2i(5, 0) || \
			$tilemap.get_cell_atlas_coords(pot_map_position + Vector2i.LEFT) == Vector2i(4, 1) || \
			$tilemap.get_cell_atlas_coords(pot_map_position + Vector2i.RIGHT) == Vector2i(4, 2):
			var p = pot.instantiate()
			p.position = $tilemap.map_to_local(pot_map_position) * 0.5
			add_child(p)
			move_child(p, 1)

func place_enemy_spawner(room_pos: Vector2i, group_id: int, group_state_array: PackedByteArray, group_cam_limits: PackedVector2Array, spawn_enemies: bool = true):
	var room_center = $tilemap.map_to_local(room_pos + room_size / 2) / 2 - Vector2(355, 355) / 4
	var spawner = enemy_spawner.instantiate()
	spawner.position = room_center
	spawner.group_id = fused_rooms_count
	spawner.group_state_array = group_state_array
	spawner.group_cam_limits = group_cam_limits
	spawner.spawned_enemies = !spawn_enemies
	spawner.add_to_group(EnemySpawnArea.GROUP_PREFIX + str(group_id))
	add_child(spawner)

func spawn_shop(room_pos):
	var room_center = $tilemap.map_to_local(room_pos) * 0.5 + Vector2(1150, 900)
	var s = shop.instantiate()
	s.position = room_center
	add_child(s)

func _ready() -> void:
	init_map_buffers()
	rooms = Globals.level_room_count[Globals.current_level]
	gen_map_layout()
	gen_map_walls()
	gen_map_doors()
	gen_pots()

	Globals.level_node = self

	
func _process(_delta: float) -> void:
	var shop_room = get_room_pos(room_pos_tiles[randi_range(1, len(room_pos_tiles) - 2)])
	
	if not spawned_mobs:
		if Globals.minimap != null:
			Globals.minimap.draw_map(map)
			Globals.minimap.room_size = room_size
			Globals.minimap.min_coord = min_coord

		for room in room_pos_tiles:
			var pos = get_room_pos(room)
			if pos != Vector2i.ZERO:
				if shop_room == pos:
					spawn_shop(pos)
					
		spawned_mobs = true
