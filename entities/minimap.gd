extends TileMapLayer

var room_size := Vector2i(16, 10)
var min_coord := Vector2i.MAX
var level_tilemap = null

var prev_pin_coord: Vector2

func draw_map(map):
	for x in map[0].size():
		for y in map.size():
			if map[y][x] != null:
				set_cell(Vector2i(x, y), 0, Vector2i(3, 2))
			else:
				set_cell(Vector2i(x, y), 0, Vector2i(1, 1))

func draw_pin(global_pos: Vector2):
	if level_tilemap != null:
		set_cell(Vector2i(prev_pin_coord.x, prev_pin_coord.y), 0, Vector2i(3, 2))
		var on_tilemap_coord = level_tilemap.local_to_map(level_tilemap.get_parent().to_local(global_pos) * 2) * 1.0
		var coord = on_tilemap_coord / (room_size * 1.0) - min_coord * 1.0
		prev_pin_coord = coord
		set_cell(Vector2i(coord.x, coord.y), 0, Vector2i(2, 4))
		
