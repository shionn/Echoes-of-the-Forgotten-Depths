extends GameBaseControl

func _ready() -> void:
	player.hitten.connect(_on_player_hit)


func _on_player_hit(damage: int) -> void:
	if (damage) : $AnimationPlayer.play("blink")
