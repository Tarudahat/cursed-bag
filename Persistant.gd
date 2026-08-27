extends Node

const game_save_location: String = "user://save_game.json"
const settings_save_location: String = "user://save_settings.json"

var persistant_data: Dictionary = {	
	"gacha_skins": [0],
	"gacha_weapons": [0],
	"gacha_items": [],
	
	"gem_count": 10000, # SET BACK
	"active_skin": 0,
	"active_weapon": 0, 
	"active_tools": [-1,-1,-1],
}

var settings: Dictionary = {
	"weapon_target_method": 0,
}

func _ready() -> void:
	load_from_json(game_save_location, persistant_data)
	load_from_json(settings_save_location, settings)

func save_to_json(file_location: String, dict: Dictionary):
	var file = FileAccess.open(file_location, FileAccess.WRITE)
	var json_str = JSON.stringify(dict)
	file.store_line(json_str)
	
func load_from_json(file_location: String, dict: Dictionary):
	var file = FileAccess.open(file_location, FileAccess.READ)
	if file:
		var json_str = file.get_line()
		var parsed_data = JSON.parse_string(json_str)
		if parsed_data:
			dict = parsed_data
