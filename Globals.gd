extends Node

var current_level = 0
var level_room_count = [5, 7, 12, 15, 25]
var lvl = preload("res://scenes/level.tscn")
var gmov = preload("res://scenes/gameover.tscn")
var tit = preload("res://scenes/titlescreen.tscn")
var win = preload("res://scenes/win.tscn")

var player_gems = -1
var player_current_hp = -1
var perm_shield = false
var curse_cap = -1
var minimap = null
var player_node = null
var boss = null

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func get_lvl_inst():
	return lvl.instantiate()

var current_level_node = null

func next_level():
	boss = null
	minimap = null
	player_node = null

	if not Sounds.music.is_playing():
		Sounds.music.play()
	current_level += 1
	
	if get_tree().get_root().has_node("titlescreen"):
		get_tree().get_root().get_node("titlescreen").queue_free()
		
	# Remove old level
	if current_level_node:
		current_level_node.queue_free()
	
	# Instantiate new level
	current_level_node = get_lvl_inst()
	get_tree().get_root().add_child.call_deferred(current_level_node)


func game_over():
	Sounds.music.stop()
	perm_shield = false
	# get the parent of level
	if current_level_node:
		current_level_node.queue_free()
			
	get_tree().get_root().add_child.call_deferred(gmov.instantiate())


func title_screen():
	get_tree().get_root().add_child.call_deferred(tit.instantiate())
	
func win_screen():
	perm_shield = false
	# get the parent of level
	var levelll = null
	for c in get_tree().get_root().get_children():
		print(c.get_name())
		if c.get_name().contains("level") || c.is_class("Level"):
			levelll = c
			
	get_tree().get_root().add_child.call_deferred(win.instantiate())
	if (levelll != null):
		levelll.queue_free()
