extends TileMapLayer

var room_size := Vector2i(16, 10)
var min_coord := Vector2i.MAX

var prev_pin_coord: Vector2 = Vector2(-1, -1)

func draw_map(map):
	for x in map[0].size():
		for y in map.size():
			if map[y][x] != null:
				set_cell(Vector2i(x, y), 0, Vector2i(3, 2))
			else:
				set_cell(Vector2i(x, y), 0, Vector2i(1, 1))

func draw_pin(global_pos: Vector2):
	if Globals.level_node != null:
		if prev_pin_coord != Vector2(-1, -1):
			set_cell(Vector2i(prev_pin_coord.x, prev_pin_coord.y), 0, Vector2i(3, 2))
		var coord = Globals.level_node.global_to_tilemap(global_pos) * 1.0 / (room_size * 1.0) - min_coord * 1.0
		prev_pin_coord = coord
		set_cell(Vector2i(coord.x, coord.y), 0, Vector2i(2, 4))
