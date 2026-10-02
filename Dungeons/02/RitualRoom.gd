extends GameBase3D

@onready var _skull1 = $wall_inset3/Skull
@onready var _skull2 = $wall_inset4/Skull
@onready var _skull3 = $wall_inset5/Skull
@onready var _skull4 = $wall_inset6/Skull

func _ready() -> void:
	if quest_book.dungeon_02_trouver_passage_secret.is_done() :
		$Secret/Closed.queue_free()
		$Secret/Open.show()

func _on_skull_state_change() -> void:
	if _skull1.state and _skull2.state and _skull3.state and _skull4.state and $Secret/Closed.visible:
		gui.openTransition(_openSecret)
		gui._close()

func _openSecret() -> void:
	$Secret/Closed.queue_free()
	$Secret/Open.show()
	$Secret/AudioStreamPlayer3D.play()
	quest_book.dungeon_02_trouver_passage_secret.done()

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is PlayerG : tags.add(Tags.DUNGEON_02_VISIT_CULT_ROOM)
