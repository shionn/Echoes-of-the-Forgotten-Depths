extends GameBase3D

var _step : int = 0 

func _check_step(_wanted: int) -> void:
	$Audio.play()
	if _step == _wanted : _step = _step + 1
	else : _step = 0
	if _step == 3 : gui.openTransition(_open_secret)

func _open_secret() : 
	$"../WallOpen".show()
	$"../WallOpen/Open".play()
	self.queue_free()

func _on_brick_1_activate() -> void: _check_step(0)
func _on_brick_2_activate() -> void: _check_step(2)
func _on_brick_3_activate() -> void: _check_step(1)
