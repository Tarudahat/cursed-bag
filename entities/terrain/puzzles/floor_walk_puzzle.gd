extends Area2D

var played_in_range: bool = false
var player_node: Player = null
var tilemap: TileMapLayer = null

var puzzle_tiles: Dictionary
# Vector2i - floor_type
var last_tile_pos: Vector2i = Vector2i.ZERO
var puzzle_finished: bool = false

enum FloorType {NORMAL, O, X}

signal puzzle_failed
signal puzzle_succeeded

func _ready() -> void:
	gen_floor_maze(45)

func gen_floor_maze(max_iters: int = 5):
	if Globals.level_node && Globals.player_node:
		var iters: int = 0
		var level: Level = Globals.level_node
		tilemap = level.get_node("tilemap")
		var tilemap_player_entry: Vector2i = level.global_to_tilemap(global_position)
		var tile_pos: Vector2i = tilemap_player_entry
		var initial_room = level.global_to_room(global_position)

		
		const direct_neighbour_offsets: Array[Vector2i] = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]
		var checked_direction: Array[Vector2i] = []

		while iters < max_iters:
			while checked_direction.size() < direct_neighbour_offsets.size():
				var neighbour_dir = direct_neighbour_offsets[randi_range(0, 3)]
				if !neighbour_dir in checked_direction:
					checked_direction.append(neighbour_dir)
					var neighbour_tiledata: TileData = tilemap.get_cell_tile_data(tile_pos + neighbour_dir)

					if neighbour_tiledata && !neighbour_tiledata.get_custom_data("is_wall") && initial_room == level.global_to_room(level.tilemap_to_global(tile_pos + neighbour_dir)):
						var floor_type: FloorType = neighbour_tiledata.get_custom_data("floor_type")

						# place tile down here, update current tile pos
						tile_pos += neighbour_dir

						match floor_type:
							FloorType.NORMAL:
								tilemap.set_cell(tile_pos, 0, Vector2i(2, 3)) # O
								puzzle_tiles[tile_pos] = FloorType.O
							FloorType.O:
								tilemap.set_cell(tile_pos, 0, Vector2i(3, 3)) # X
								puzzle_tiles[tile_pos] = FloorType.X
							FloorType.X:
								tilemap.set_cell(tile_pos, 0, Vector2i(2, 3)) # O
								puzzle_tiles[tile_pos] = FloorType.O
						

						checked_direction.clear()
						break
			iters += 1
	else:
		push_warning("Globals.level_node, Globals.player_node not initialised!")

func all_puzzle_tiles(answer_type: FloorType) -> bool:
	return puzzle_tiles.keys().all(func(tile_pos): return tilemap.get_cell_tile_data(tile_pos).get_custom_data("floor_type") == answer_type)

func reset_puzzle_tiles() -> void:
	for tile_pos in puzzle_tiles:
		match puzzle_tiles[tile_pos]:
			FloorType.O:
				tilemap.set_cell(tile_pos, 0, Vector2i(2, 3)) # O
			FloorType.X:
				tilemap.set_cell(tile_pos, 0, Vector2i(3, 3)) # X

func _process(_delta: float) -> void:
	if !puzzle_finished:
		if played_in_range && Globals.level_node && tilemap && !player_node.in_air:
			var tile_pos = Globals.level_node.global_to_tilemap(Globals.player_node.global_position)
			var tiledata = tilemap.get_cell_tile_data(tile_pos)
			if tiledata:
				var floor_type: FloorType = tiledata.get_custom_data("floor_type")

				if tile_pos != last_tile_pos:
					match floor_type:
						FloorType.O:
							tilemap.set_cell(tile_pos, 0, Vector2i(3, 3)) # X
						FloorType.X:
							tilemap.set_cell(tile_pos, 0, Vector2i(2, 3)) # O
						FloorType.NORMAL:
							reset_puzzle_tiles()
							emit_signal("puzzle_failed")

					if all_puzzle_tiles(FloorType.X):
						puzzle_finished = true
						emit_signal("puzzle_succeeded")

				last_tile_pos = tile_pos

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		played_in_range = true
		player_node = body


func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		played_in_range = false
