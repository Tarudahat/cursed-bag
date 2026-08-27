extends CharEnemy

var rocket = preload("res://entities/enemies/rocket.tscn")

var player_in_range: bool = false

var can_shoot: bool = true

var shots_shot: int = 0
const max_shots: int = 5

func _ready() -> void:
	super()

func _physics_process(delta: float) -> void:
	char_entity_move_and_slide()

func _process(delta: float) -> void:
	if shots_shot < max_shots && player_in_range:
		if can_shoot && Globals.player_node != null:
			var rocket_inst = rocket.instantiate()
			rocket_inst.global_position = global_position
			rocket_inst.target_position = Globals.player_node.global_position
			rocket_inst.owner_entity = self
			get_parent().add_child(rocket_inst)
			shots_shot += 1
			can_shoot = false
			$ShotCD.start()
	elif $CycleCD.time_left == 0.0:
		$CycleCD.start()

func _on_got_hit(hp: Variant) -> void:
	$Sprite2D.material.set_shader_parameter("enabled", true)

func _on_inv_end() -> void:
	$Sprite2D.material.set_shader_parameter("enabled", false)

func _on_area_2d_body_entered(body: Node2D) -> void:
	player_in_range = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	player_in_range = false


func _on_cycle_cd_timeout() -> void:
	shots_shot = 0

func _on_shot_cd_timeout() -> void:
	can_shoot = true
