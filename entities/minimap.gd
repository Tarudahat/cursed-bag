extends TileMapLayer

func draw_map(map):
	for x in map[0].size():
		for y in map.size():
			if map[y][x] != null:
				set_cell(Vector2i(x, y), 0, Vector2i(3, 2))
			else:
				set_cell(Vector2i(x, y), 0, Vector2i(1, 1))
