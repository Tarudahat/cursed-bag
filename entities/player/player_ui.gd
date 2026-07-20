extends Control

func _ready() -> void:
	Globals.minimap = $minimap
	$BossBar.visible = false
	
	$PanelContainer/GEM_BAR.set_size(Vector2(0.01, 0.01), false)
	$PanelContainer/HP_BAR.set_size(Vector2(0.01, 0.01), false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Globals.player_node != null:
		$minimap.draw_pin(Globals.player_node.global_position)
		
		if Globals.boss != null:
			$BossBar.visible = true
			$BossBar.max_value = Globals.boss.max_hp
			$BossBar.value = Globals.boss.hp
		else:
			$BossBar.value = 0.0
		
		var curse_cap = Globals.player_node.curse_cap
		var gems = Globals.player_node.gems
		var hp = Globals.player_node.hp
		var hp_max = Globals.player_node.max_hp
			
		var a = curse_cap - gems
		if a <= 0:
			a = float(curse_cap) / 10
		$PanelContainer/GEM_BAR.text = str(int(gems))
		$PanelContainer/HP_BAR.text = \
		str(int(hp)) + "/" + str(int(round(hp_max * (float(a) / curse_cap))))
			
		$curbar.value = gems * 0.78
		$curbar.max_value = curse_cap * 0.78
