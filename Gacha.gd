extends Node

const GACHA_ROLL_COST: int = 150

enum GachaType {Weapon, GachaSkin, Item}

enum GachaWeapons {SwordAndShield, GachaSpear}#, Hammer, Gun, Bomb} # 6.25%
enum GachaSkins {Hero}#, Girl, Eye, Skull} # 12.25%
enum GachaItems {}#Magnet, ChronosPocketwatch, ProfHat, Map, HPBonus} # 81.5%

const WEAPON_ODDS: float = 6.25
const SKIN_ODDS: float = 12.25
const ITEM_ODDS: float = 81.5

var gacha_max: int = GachaWeapons.size() + GachaItems.size() + GachaSkins.size()

func _ready() -> void:
	pass

func get_available_gacha(gacha_type: GachaType) -> Array:
	var output: Array = []
	if Persistant && Persistant.persistant_data:
		match gacha_type:
			GachaType.Weapon:
				output = GachaWeapons.values().filter(func(el): return not el in Persistant.persistant_data["gacha_weapons"])
			GachaType.GachaSkin:
				output = GachaSkins.values().filter(func(el): return not el in Persistant.persistant_data["gacha_skins"])
			GachaType.Item:
				output = GachaItems.values().filter(func(el): return not el in Persistant.persistant_data["gacha_items"])
	return output

func roll() -> Vector2i:# GachaType, int
	var available_weapons = get_available_gacha(GachaType.Weapon)
	var available_skins = get_available_gacha(GachaType.GachaSkin)
	var available_items = get_available_gacha(GachaType.Item)

	var gacha_type: GachaType = -1

	# will get stuck if all are empty!
	while true:
		var roll = randf_range(0.0, 100.0)
		if roll <= WEAPON_ODDS && !available_weapons.is_empty():
			return Vector2i(GachaType.Weapon, available_weapons[randi_range(0,available_weapons.size()-1)] )
		elif roll <= WEAPON_ODDS + SKIN_ODDS && !available_skins.is_empty():
			return Vector2i(GachaType.GachaSkin, available_skins[randi_range(0,available_skins.size()-1)] )
		elif !available_items.is_empty():
			return Vector2i(GachaType.Item, available_items[randi_range(0,available_items.size()-1)] )

	return Vector2i(-1, -1)

func all_collected() -> bool:
	var available_weapons = get_available_gacha(GachaType.Weapon)
	var available_skins = get_available_gacha(GachaType.GachaSkin)
	var available_items = get_available_gacha(GachaType.Item)
	
	return available_weapons.is_empty() && available_skins.is_empty() && available_items.is_empty()
	
