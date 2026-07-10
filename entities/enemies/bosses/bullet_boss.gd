extends Boss


var bullet_node = preload("res://entities/enemies/bullet.tscn")
@export var bullet_count = 8
@export var dmg = 10
enum Patterns {WALL, SPIRAL, UN}
var wave_count = 64
var wave = 1
var can_shoot_wave = true
var can_shoot = true
var ang = 0

func _ready():
	super()
	Globals.boss = self

	$Sprite2D.material.set_shader_parameter("enabled", false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func perform_shot_pattern(pattern: Patterns):
	if can_shoot && can_shoot_wave:
		for i in range(bullet_count):
			var blast = bullet_node.instantiate()
			blast.direction = Vector2(cos(ang), sin(ang))
			blast.position = position + blast.direction*10
			blast.dmg = dmg
			get_parent().add_child(blast)
			
			match pattern:
				Patterns.WALL: 
					ang -= sin(wave*0.005)
				Patterns.SPIRAL:
					ang -= 0.8
				Patterns.UN:
					ang -= randfn(sqrt(wave), sin(wave))
			
		$shoot_wave_cooldown.start()
		can_shoot_wave = false
		wave += 1 
		if wave == wave_count:
			can_shoot = false
			$shoot_pattern_cooldown.start()
			wave = 0

func _process(delta: float) -> void:
	perform_shot_pattern(1)

func _on_shoot_pattern_cooldown_timeout() -> void:
	can_shoot = true

func _on_shoot_wave_cooldown_timeout() -> void:
	can_shoot_wave = true
	
func _on_got_hit(hp, val) -> void:
	$Sprite2D.material.set_shader_parameter("enabled", true)

func _on_inv_end() -> void:
	$Sprite2D.material.set_shader_parameter("enabled", false)
	
