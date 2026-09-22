extends GameBaseControl

func _ready() -> void:
	hide()

func _on_dungeon_01_pressed() -> void:
	gui._close()
	gui.openTransition(func():_goTo("res://Dungeons/01/Dungeon01.tscn"))

func _on_dungeon_02_pressed() -> void:
	gui._close()
	gui.openTransition(func():_goTo("res://Dungeons/02/Dungeon02.tscn"))

func _on_dungeon_03_pressed() -> void:
	gui._close()
	gui.openTransition(func():_goTo("res://Dungeons/03/Dungeon03.tscn"))

func _on_dungeon_04_pressed() -> void:
	gui._close()
	gui.openTransition(func():_goTo("res://Dungeons/04/Dungeon04.tscn"))

func _goTo(path : String) -> void : 
	var dungeon = $/root/World/Dungeon as Node3D
	dungeon.name = "old"
	dungeon.queue_free()
	dungeon = load(path).instantiate()
	dungeon.name = "Dungeon"
	world.add_child(dungeon)
	player.reset_orientation()

func _on_visibility_changed() -> void:
	$PanelContainer/MarginContainer/VBoxContainer/Dungeon01.visible = quest_book.auberge_01_trouver_kkchos_a_faire.is_done()
	$PanelContainer/MarginContainer/VBoxContainer/Dungeon02.visible = quest_book.auberge_02_trouver_mission.is_done()
	$PanelContainer/MarginContainer/VBoxContainer/Dungeon03.visible = quest_book.auberge_03_trouver_mission.is_done()
	
