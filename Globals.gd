extends Node

var current_level = 0
var level_room_count = [3, 7, 12, 15, 25]
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
var level_node = null
var player_ui = null
var boss = null

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func get_lvl_inst():
	return lvl.instantiate()

var current_level_node = null

func bezier_curve(start: Vector2, mid: Vector2, end: Vector2, t_lerp: float) -> Vector2:
	t_lerp = clampf(t_lerp, 0.0, 1.0)
	var lerp0 = lerp(start, mid, t_lerp)
	var lerp1 = lerp(mid, end, t_lerp)
	return lerp(lerp0, lerp1, t_lerp)

func next_level():
	boss = null
	#minimap = null
	player_node = null
	level_node = null

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
	if player_ui != null:
		player_ui.queue_free()
	Sounds.music.stop()
	perm_shield = false
	# get the parent of level
	if current_level_node:
		current_level_node.queue_free()
			
	get_tree().get_root().add_child.call_deferred(gmov.instantiate())


func title_screen():
	get_tree().get_root().add_child.call_deferred(tit.instantiate())
	
func win_screen():
	if player_ui != null:
		player_ui.queue_free()
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
