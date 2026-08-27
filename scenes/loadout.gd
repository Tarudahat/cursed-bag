extends Control

func _ready() -> void:
	$CharaCarousel.unlocked_elements = Persistant.persistant_data["gacha_skins"] 
	$WeaponCarousel.unlocked_elements = Persistant.persistant_data["gacha_weapons"] 
	
	$CharaCarousel.update_textures()
	$WeaponCarousel.update_textures()

func _on_button_start_pressed() -> void:
	if $CharaCarousel.is_selected_unlocked() && $WeaponCarousel.is_selected_unlocked():
		Persistant.persistant_data["active_weapon"] = $WeaponCarousel.selected_idx
		
		Globals.current_level = -1
		Globals.next_level()
		self.queue_free()


func _on_button_back_pressed() -> void:
	Globals.title_screen()
	self.queue_free()
