extends PNJ

@onready var _food = $"../RDC/Bar/Food"

func _ready() -> void:
	$Character/Rig_Medium/Skeleton3D/AvianSwordsman_Cloak.hide()
	super._ready()

func interact() -> void:
	look_at_player()
	if quest_book.auberge_01_reprendre_des_forces.is_done() : 
		#$"LookingForQuest/Service de l'auberge".enable = bag.gold >= 5
		$"LookingForQuest/Service de l'auberge/Manger".enable = bag.gold >= 10

		$"LookingForQuest/Le Gouffre des Ombres".enable = tags.have(Tags.AUBERGE_PLAYER_KNOW_SHADOW_CHASM) and not quest_book.auberge_02_trouver_mission.is_done()
		$"LookingForQuest/Le Gouffre des Ombres/Next/Next".enable = quest_book.auberge_02_recevoir_prime.is_done()

		$"LookingForQuest/Mission Accomplie".enable = bag.have(Items.ItemName.SkullHead_Dungeon1)
		$"LookingForQuest/Mission Accomplie/Next/Next/Next/La potion étrange".enable = bag.have(Items.ItemName.FioleNecrolisAttivae)
		
		$"LookingForQuest/Dungeon02 Accomplie".enable = bag.have(Items.ItemName.SkullHead_Dungeon2) and quest_book.auberge_03.is_started()
		
		$"LookingForQuest/C'est l'anneau de Valthorion".enable = quest_book.auberge_03_identify_ring.is_done() and not quest_book.dungeon_03_restaurer_l_anneau.is_done()
		gui.openDialog($LookingForQuest)
	elif _food.visible :
		gui.openDialog($Bienvenue/ApportFood)
	else :
		gui.openDialog($Bienvenue)


func _on_Bienvenue_close() -> void:
	gui.openTransition(func(): _food.show(), func(): gui.openDialog($Bienvenue/ApportFood))

func _on_end_mission1_close() -> void:
	bag.unloot(Items.ItemName.SkullHead_Dungeon1)
	quest_book.auberge_02_recevoir_prime.done()
	bag.gold = bag.gold+8

func _on_manger_activate() -> void:
	var middle = func() : 
		bag.gold = bag.gold - 10
		_food.show()
	gui.openTransition(middle, func() : gui.openDialog($"LookingForQuest/Service de l'auberge/Manger/Next/Next/ApportFood"))

func _on_shadow_shasme_next_close() -> void:
	quest_book.auberge_02_trouver_mission.done()

func _on_dungeon_02_accomplie_next_close() -> void:
	quest_book.auberge_03_rapport.done()
	bag.unloot(Items.ItemName.SkullHead_Dungeon2)
	bag.gold = bag.gold+30
