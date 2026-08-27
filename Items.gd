extends Node

enum Items {HEAL_POT, BEAR_TRAP, BULLET_ABSORBER, HOVER_WALK, ANTIDOTE, BOMB, BOUNCE_POT}
const item_cost: Dictionary = {
	Items.HEAL_POT: 0,
	Items.BEAR_TRAP: 0,
	Items.BULLET_ABSORBER: 0,
	Items.HOVER_WALK: 0,
	Items.ANTIDOTE: 0,
	Items.BOMB: 0,
	Items.BOUNCE_POT: 0,
}

# item texture resources
var empty_item_slot_texture: Resource = preload("res://assets/UI/item_slot_empty.png")

var item_resources: Dictionary[String, Resource]
const item_resources_dir: String = "res://assets/UI/items"

# item entity resources; e.g. beartrap entity
var item_entity_resources: Dictionary[String, Resource]
const item_entity_resources_dir: String = "res://entities/item_entities/"


func _ready() -> void:
	# load item textures
	for res in ResourceLoader.list_directory(item_resources_dir):
		if !res in Items.keys():
			push_warning("resource name: " + res + " not found in dir: " + item_resources_dir)
		if res.ends_with(".png"):
				item_resources[res.get_basename()] = load(item_resources_dir + "/" + res)
				
	# load item entities
	for res in ResourceLoader.list_directory(item_entity_resources_dir):
		if res.ends_with(".tscn"):
			item_entity_resources[res.get_basename()] = load(item_entity_resources_dir + "/" + res)

func get_item_texture(item: Items) -> Resource:
	var item_enum_name: String = DungeonItems.Items.keys()[item]
	return DungeonItems.item_resources[item_enum_name]

func spawn_item_entity(item: Items, entity_pos: Vector2 = Globals.player_node.global_position) -> void:
	print(item_entity_resources)
	var item_entity_instance = item_entity_resources[Items.keys()[item]].instantiate()
	if Globals.level_node:
		item_entity_instance.global_position = entity_pos
		Globals.level_node.add_child(item_entity_instance)
		
func use_item(item: Items, entity:CharEntity = null):
	match item:
		Items.HEAL_POT:
			if entity:
				entity.heal(50)
		Items.HOVER_WALK:
			if entity:
				entity.apply_status_effect(CharEntity.StatusEffect.HOVER, 15)
		Items.BOUNCE_POT:
			if entity:
				entity.apply_status_effect(CharEntity.StatusEffect.BOUNCER, 15)
		Items.ANTIDOTE:
			if entity:
				for effect in entity.active_status_effects:
					entity.clear_status_effect(effect)
		Items.BEAR_TRAP, Items.BULLET_ABSORBER, Items.BOMB:
			spawn_item_entity(item)
		_:
			pass
