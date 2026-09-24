extends GameBase3D

func _ready() -> void:
	if quest_book.dungeon_01.start() : gui.openQuest()
	if not quest_book.dungeon_01_have_proof.is_done() : 
		$"BossRoom/Skeleton Golem".loot_obj = Items.ItemName.SkullHead_Dungeon1
	if quest_book.dungeon_01_have_potion.is_done() :
		$BossRoom/bookcase_single_decoratedB/potion_huge_green2.queue_free()
	if bag.have(Items.ItemName.PotionVieMineur) : 
		$"Entrance/Skeleton Minion 1".loot_obj = Items.ItemName.None
	bag.item_loot.connect(_on_item_loot)
	bag.item_drop.connect(_on_item_drop)
	
	options.apply()


func _on_skeleton_golem_dead() -> void:
	quest_book.dungeon_01_kill_boss.done()

func _on_item_loot(item : Item) -> void :
	if (item.item_name == Items.ItemName.SkullHead_Dungeon1) :
		quest_book.dungeon_01_have_proof.done()
	if item.item_name == Items.ItemName.FioleNecrolisAttivae :
		quest_book.dungeon_01_have_potion.done()

func _on_item_drop(item : Item) -> void :
	if (item.item_name == Items.ItemName.ClefCoffre) :
		quest_book.dungeon_01_treasur_found.done()
