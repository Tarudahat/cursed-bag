extends Node2D
class_name Level

@export var rooms = 5
@export var room_size := Vector2i(14,11)

var blast_node = preload("res://tp_area.tscn")
var exit = preload("res://scenes/next_lvl.tscn")
var mage_enemy = preload("res://entities/enemies/caster.tscn")
var ghost_enemy = preload("res://entities/enemies/ghost.tscn")
var turret_enemy = preload("res://entities/enemies/turret.tscn")
var shop = preload("res://scenes/shop.tscn")

var spawned_mobs = false
var room_buf := []
var door_bufs := []
var rooms_positions := []  

func place_door(pos: Vector2i, dir: Vector2):
	var door_pos = $tilemap.map_to_local(pos)*0.5 
	var door_dis = 600
	
	var tp = blast_node.instantiate()
	var tp2 = blast_node.instantiate()
	
	if dir == Vector2.UP:
		$tilemap.set_cell(pos, 0, door_bufs[2][0].atl, door_bufs[2][0].alt)
		$tilemap.set_cell(pos + Vector2i.RIGHT, 0, door_bufs[2][1].atl, door_bufs[2][1].alt)
		$tilemap.set_cell(pos + Vector2i.UP * 3, 0, door_bufs[3][0].atl, door_bufs[3][0].alt)
		$tilemap.set_cell(pos + Vector2i.UP * 3 + Vector2i.RIGHT, 0, door_bufs[3][1].atl, door_bufs[3][1].alt)
		door_pos += Vector2.RIGHT * 84
		door_pos += Vector2.DOWN * 35
	elif dir == Vector2.DOWN:
		$tilemap.set_cell(pos, 0, door_bufs[3][0].atl, door_bufs[3][0].alt)
		$tilemap.set_cell(pos + Vector2i.RIGHT, 0, door_bufs[3][1].atl, door_bufs[3][1].alt)
		$tilemap.set_cell(pos + Vector2i.DOWN * 3 , 0, door_bufs[2][0].atl, door_bufs[2][0].alt)
		$tilemap.set_cell(pos  + Vector2i.DOWN * 3 + Vector2i.RIGHT, 0, door_bufs[2][1].atl, door_bufs[2][1].alt)
		door_pos += Vector2.RIGHT * 84
		door_pos += Vector2.UP * 35
	elif dir == Vector2.LEFT:
		$tilemap.set_cell(pos, 0, door_bufs[0][0].atl, door_bufs[0][0].alt)
		$tilemap.set_cell(pos + Vector2i.DOWN, 0, door_bufs[0][1].atl, door_bufs[0][1].alt)
		$tilemap.set_cell(pos + Vector2i.LEFT *3 , 0, door_bufs[1][0].atl, door_bufs[1][0].alt)
		$tilemap.set_cell(pos + Vector2i.LEFT *3 + Vector2i.DOWN, 0, door_bufs[1][1].atl, door_bufs[1][1].alt)
		door_pos += Vector2.DOWN * 84
		door_pos += Vector2.LEFT *20 
		door_dis = 490
		tp.dist = 750
		tp2.dist = 750
	else: # RIGHT
		$tilemap.set_cell(pos, 0, door_bufs[1][0].atl, door_bufs[1][0].alt)
		$tilemap.set_cell(pos + Vector2i.DOWN, 0, door_bufs[1][1].atl, door_bufs[1][1].alt)
		$tilemap.set_cell(pos + Vector2i.RIGHT *3 , 0, door_bufs[0][0].atl, door_bufs[0][0].alt)
		$tilemap.set_cell(pos + Vector2i.RIGHT *3 + Vector2i.DOWN, 0, door_bufs[0][1].atl, door_bufs[0][1].alt)
		door_pos += Vector2.DOWN * 84
		door_pos += Vector2.RIGHT *20 
		door_dis = 490
		tp.dist = 750
		tp2.dist = 750
		
	tp.dir = dir
	tp.position = door_pos
	tp2.dir = dir *-1
	tp2.position = door_pos + dir*door_dis


	add_child(tp)
	add_child(tp2)
	

func copy_region(from_pos: Vector2i):
	room_buf.clear()

	for x in range(room_size.x):
		room_buf.append([])
		for y in range(room_size.y):
			var pos = from_pos + Vector2i(x, y)

			var source_id = $tilemap.get_cell_source_id(pos)

			if source_id == -1:
				room_buf[x].append(null)
			else:
				room_buf[x].append({
					"source_id": source_id,
					"atlas_coords": $tilemap.get_cell_atlas_coords(pos),
					"alternative": $tilemap.get_cell_alternative_tile(pos)
				})
				
				
func paste_region(to_pos: Vector2i):
	if room_buf.is_empty():
		return

	for x in range(room_size.x):
		for y in range(room_size.y):

			var data = room_buf[x][y]
			var target = to_pos + Vector2i(x, y)

			if data == null:
				$tilemap.erase_cell(target)
			else:
				$tilemap.set_cell(
					target,
					data.source_id,
					data.atlas_coords,
					data.alternative
				)

func genmap():
	var current_room_coord = Vector2i(0,0)
	rooms_positions.append(current_room_coord)

	for r in range(1, rooms):
		var dx = 0
		var dy = 0
		var new_room_coord = current_room_coord
		while true:
			dx = 0
			dy = 0
			
			if randi_range(0,1) == 0:
				dx = randi_range(-1,1)
				dy = 0
			else:
				dx = 0
				dy = randi_range(-1,1)

			if dx == 0 and dy == 0:
				continue
				
			if randi_range(0,100) > 80:
				current_room_coord = rooms_positions[randi_range(0, len(rooms_positions)-1)]

			new_room_coord = current_room_coord + Vector2i(dx * room_size.x, dy * room_size.y)
			if new_room_coord in rooms_positions:
				continue
			break
			
		# place the new room next
		paste_region(new_room_coord)
		rooms_positions.append(new_room_coord)
		
		if r < rooms:
			# cur -> new, exit door + entry door
			if new_room_coord.y < current_room_coord.y:
				place_door(current_room_coord + Vector2i(floor(room_size.x/2 -1),1),Vector2.UP)
			elif new_room_coord.y > current_room_coord.y:
				place_door(new_room_coord + Vector2i(floor(room_size.x/2 -1),-2),Vector2.DOWN)
				
			if new_room_coord.x < current_room_coord.x:
				place_door(current_room_coord + Vector2i(1,floor(room_size.y/2 -1)),Vector2.LEFT)
			elif new_room_coord.x > current_room_coord.x:
				place_door(new_room_coord + Vector2i(-2,floor(room_size.y/2 -1)),Vector2.RIGHT)
		
		current_room_coord = new_room_coord
	
	var exit_node = exit.instantiate()
	exit_node.position = $tilemap.map_to_local(current_room_coord)*0.5 + Vector2(1150,900)
	add_child(exit_node)
	
func spawn_enemies(room_pos:Vector2i):
	var room_center = $tilemap.map_to_local(room_pos)*0.5 + Vector2(1150,900)
	
	var enemy = null
	var choice = randi_range(0,2)
	var count = 0
	
	if choice == 0:
		count = randi_range(2,5) + Globals.current_level*2
	elif choice == 1:
		count = 1 +Globals.current_level
		if count > 3:
			count = 3
	elif choice == 2:
		count = 1 + Globals.current_level
		if count > 3:
			count = 3
	
	
	for i in range(count):
		if choice == 0:
			enemy = ghost_enemy.instantiate()
			enemy.position = room_center + Vector2(randi_range(-1,1)*500,randi_range(-1,1)*400)
		elif choice == 1:
			enemy = turret_enemy.instantiate()
			enemy.position = room_center + Vector2(randi_range(-1,1)*500,randi_range(-1,1)*400)
		else:
			enemy = mage_enemy.instantiate()
			enemy.position = room_center
		
		if enemy.get_parent() != null:
			remove_child(enemy)
		add_child(enemy)
		
		if choice == 2:
			enemy.position = room_center + Vector2(randi_range(-1,1),randi_range(-1,1)) * 500

func spawn_shop(room_pos):
	var room_center = $tilemap.map_to_local(room_pos)*0.5 + Vector2(1150,900)
	var s = shop.instantiate()
	s.position = room_center
	add_child(s)
	
	
func _ready() -> void:
	# domain expansion: INFINITE TECHNICAL DEPT
	var ehe = [Vector2i(0,-2),Vector2i(0,-1),Vector2i(1,-2),Vector2i(1,-1),Vector2i(2,-2),Vector2i(3,-2),Vector2i(2,-1),Vector2i(3,-1)]
	door_bufs.append([{"alt": $tilemap.get_cell_alternative_tile(ehe[0]), "atl": $tilemap.get_cell_atlas_coords(ehe[0])},
					{"alt": $tilemap.get_cell_alternative_tile(ehe[1]), "atl": $tilemap.get_cell_atlas_coords(ehe[1])}])
	door_bufs.append([{"alt": $tilemap.get_cell_alternative_tile(ehe[2]), "atl": $tilemap.get_cell_atlas_coords(ehe[2])},
					{"alt": $tilemap.get_cell_alternative_tile(ehe[3]), "atl": $tilemap.get_cell_atlas_coords(ehe[3])}])
	door_bufs.append([{"alt": $tilemap.get_cell_alternative_tile(ehe[4]), "atl": $tilemap.get_cell_atlas_coords(ehe[4])},
					{"alt": $tilemap.get_cell_alternative_tile(ehe[5]), "atl": $tilemap.get_cell_atlas_coords(ehe[5])}])
	door_bufs.append([{"alt": $tilemap.get_cell_alternative_tile(ehe[6]), "atl": $tilemap.get_cell_atlas_coords(ehe[6])},
					{"alt": $tilemap.get_cell_alternative_tile(ehe[7]), "atl": $tilemap.get_cell_atlas_coords(ehe[7])}])
	
	for p in ehe:
		$tilemap.erase_cell(p)
	
	rooms = Globals.level_room_count[Globals.current_level]
	print(rooms)
	
	copy_region(Vector2i(0, 0))
	genmap()

	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var shop_room = rooms_positions[randi_range(1,len(rooms_positions)-2)]
	
	if not spawned_mobs:
		for pos in rooms_positions:
			if pos != Vector2i.ZERO:
				if shop_room == pos:
					spawn_shop(pos)
				else:
					spawn_enemies(pos)
		spawned_mobs = true
