extends Control

var carousel_resources: Array[Resource]
@export var carousel_resource_dir: String = "res://assets/UI/carousel_01"

var carousel_locked_rsrc: Resource
@export var carousel_locked_file_name: String = "locked.png"

var unlocked_elements: Array = [0]
var selected_idx: int = 0

func _ready() -> void:
	# load in carousel resources
	var rsrcs = ResourceLoader.list_directory(carousel_resource_dir)
	rsrcs.sort()
	for res in rsrcs:
		if res.ends_with(".png") && res != carousel_locked_file_name:
				carousel_resources.append(load(carousel_resource_dir + "/" + res))
				
	carousel_locked_rsrc = load(carousel_resource_dir + "/" + carousel_locked_file_name)	

func get_texture(index: int) -> Resource:
	if index in unlocked_elements:
		return carousel_resources[index]
	return carousel_locked_rsrc

func is_selected_unlocked() -> bool:
	return selected_idx in unlocked_elements

func update_textures(scroll_dir: int = 0):
	$TextureRectLeft.texture_normal = get_texture((selected_idx - 1) %  len(carousel_resources))
	$TextureRectRight.texture_normal = get_texture((selected_idx + 1) %  len(carousel_resources))
	$TextureRectMain.texture = get_texture(selected_idx)
	
	if scroll_dir == 0: # right scroll
		$TextureRectBack.texture = get_texture((selected_idx - 2) %  len(carousel_resources))
	else: # left
		$TextureRectBack.texture = get_texture((selected_idx + 2) %  len(carousel_resources))
		

func _on_texture_rect_left_pressed() -> void:
	if !$AnimationPlayer.is_playing():
		update_textures(0)
		$AnimationPlayer.play("scroll_right")
		selected_idx = (selected_idx - 1) % len(carousel_resources)


func _on_texture_rect_right_pressed() -> void:
	if !$AnimationPlayer.is_playing():
		update_textures(1)
		$AnimationPlayer.play("scroll_left")
		selected_idx = (selected_idx + 1) % len(carousel_resources)


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "scroll_left" || anim_name == "scroll_right":
		update_textures()
		$AnimationPlayer.play("RESET")
		$AnimationPlayer.advance(0) #play RESET immediatly
