extends CharEntity
class_name CharEnemy

var gem = preload("res://entities/misc/gem.tscn")
var agro: bool = false

@export var value = 10
@export var default_death = true

var atk = 5
var speed = 500

func _ready() -> void:
	super() # init hp and timers
	auto_free_on_death = false

func damage(amount: int) -> void:
	if can_get_hit:
		can_get_hit = false
		dmg_timer.start()
		hp -= amount
		emit_signal("got_hit", hp)
		
		if hp <= 0:
			emit_signal("died")
			if default_death:
				for i in value:
					var gem_inst = gem.instantiate()
					gem_inst.position = position + Vector2(randi_range(-10, 10), randi_range(-10, 10))
					gem_inst.value = 1
					get_parent().add_child.call_deferred(gem_inst)
				self.queue_free()


var wander_target: Vector2 
var wander_rnd_range: int = 620
var secundary_wander_target: Vector2

func next_wander_target() -> void:
	secundary_wander_target = wander_target
	wander_target = global_position + Vector2(randf_range(-wander_rnd_range, wander_rnd_range), randf_range(-wander_rnd_range, wander_rnd_range))
	if Globals.level_node:
		var iteration: int = 0
		var tilemap = Globals.level_node.get_node("tilemap")
		var tiledata = tilemap.get_cell_tile_data(Globals.level_node.global_to_tilemap(wander_target))
		
		while tiledata && tiledata.get_custom_data("is_wall") && iteration < 5:
			wander_target = global_position + Vector2(randf_range(-wander_rnd_range, wander_rnd_range), randf_range(-wander_rnd_range, wander_rnd_range))
			tiledata = tilemap.get_cell_tile_data(Globals.level_node.global_to_tilemap(wander_target))
			iteration += 1
