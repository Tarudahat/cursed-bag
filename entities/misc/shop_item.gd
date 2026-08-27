extends Area2D

var player_in_range: bool = false

@export var item: DungeonItems.Items = DungeonItems.Items.BOUNCE_POT


var yn_dialog

func _ready() -> void:
	$interaction_icon.visible = false
	if Globals.player_ui:
		yn_dialog = Globals.player_ui.get_node("PlayerUI/YesNoDialog")
		if yn_dialog:
			yn_dialog.get_node("YesButton").pressed.connect(_on_yes)
			yn_dialog.get_node("NoButton").pressed.connect(_on_no)
	
	$Sprite2D.texture = DungeonItems.get_item_texture(item)

func _process(delta: float) -> void:
	if player_in_range:
		if Input.is_action_just_pressed("interact"):
			yn_dialog.visible = true

func _on_yes():
	yn_dialog.visible = false
	if Globals.player_node.gems >= DungeonItems.item_cost[item] && !Globals.player_node.is_inventory_full():
		Globals.player_node.gems -= DungeonItems.item_cost[item]
		Globals.player_node.add_item(item)
	
func _on_no():
	yn_dialog.visible = false

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		player_in_range = true
		$interaction_icon.visible = player_in_range

func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		player_in_range = false
		$interaction_icon.visible = player_in_range
