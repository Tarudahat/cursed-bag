extends StaticBody2D
class_name StaticEnemy

var gem = preload("res://entities/Gem.tscn")

@export var hp = 10
@export var value = 10
@export var default_death = true

@export var inv_time = 1.0
@onready var dmg_timer : Timer 

var can_get_hit = true

signal got_hit(hp,value)
signal inv_end
signal died
var gem_inst = null

func _ready() -> void:
	dmg_timer = Timer.new()
	dmg_timer.wait_time = inv_time
	add_child(dmg_timer)
	dmg_timer.timeout.connect(_on_dmg_timer_timeout)
	gem_inst = gem.instantiate()

func damage(amount: int) -> void:
	if can_get_hit:
		can_get_hit = false
		dmg_timer.start()
		hp -= amount
		emit_signal("got_hit", hp, value)
		
		if hp < 0:
			emit_signal("died")
			if default_death:
				gem_inst.position = position + Vector2(randi_range(-10,10), randi_range(-10,10))
				gem_inst.value = value
				get_parent().add_child.call_deferred(gem_inst)
				self.queue_free()


func _on_dmg_timer_timeout() -> void:
	can_get_hit = true
	emit_signal("inv_end")
