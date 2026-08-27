extends Node2D

var shop_item_resource = preload("res://entities/misc/shop_item.tscn")

func _ready() -> void:
	if Globals.current_level_node:
		var room_size: Vector2i = Globals.current_level_node.room_size - Vector2i(4,4)
		var room_center: Vector2i = Globals.current_level_node.global_to_tilemap(global_position)
		
		# how many free tiles?
		var free_tiles = []
		for x in room_size.x:
			for y in room_size.y:
				var tile_pos: Vector2i = room_center - room_size/2 + Vector2i(x,y)
				if !Globals.current_level_node.is_in_wall_or_hole(Globals.current_level_node.tilemap_to_global(tile_pos)):
					free_tiles.append(tile_pos)

		# place down a few shop items at the free spots
		var shop_item_count = randi_range(3,5)
		var shop_tiles = []
		
		while shop_tiles.size() < shop_item_count:
			var rnd_idx = randi_range(0, free_tiles.size() - 1)
			var rnd_tile = free_tiles[rnd_idx]
			if !rnd_tile in shop_tiles:
				shop_tiles.append(rnd_tile)
		
		var seen_items = []
		for shop_item_idx in shop_item_count:
			var shop_inst = shop_item_resource.instantiate()
			shop_inst.global_position = Globals.current_level_node.tilemap_to_global(shop_tiles[shop_item_idx])
			
			print(shop_inst.global_position)
			
			var item = randi_range(0, DungeonItems.Items.size()-1)
			while item in seen_items:
				item = randi_range(0, DungeonItems.Items.size()-1)
	
			seen_items.append(item)
			shop_inst.item = item as DungeonItems.Items
			
			get_parent().add_child(shop_inst)
