@abstract class_name PlayerG
extends GameBaseCharacterBody3D

enum State { ATTACK, SPELL, MOVE, IDLE, HIT, DEATH }

@onready var _character = $Character as Node3D
@onready var _animation = $Character/AnimationPlayer as AnimationPlayer
@onready var _mainHandAtkTimer = $MainHandAtkTimer as Timer
@onready var _offHandAtkTimer = $OffHandAtkTimer as Timer

const _movement_speed: float = 4.0
const _max_range: float = 20
const _atk_range: float = 2

signal lvl_up()
signal hitten(damage)

var _state : State = State.MOVE
var _attacked_monster : Monster

var lvl = 1
var pv = 1
var xp = 0 :
	set(value) :
		xp = value
		# requiere 75*2*lvl pour passer au lvl suivant<
		if xp > lvl * (lvl+1) * 75 :
			lvl = lvl + 1
			gui.consoleLog("Vous passer lvl %d"%lvl)
			lvl_up.emit()

func _ready() -> void:
	_animation.animation_finished.connect(_on_animation_finished)
	_mainHandAtkTimer.timeout.connect(_on_main_hand_atk_timer)
	_offHandAtkTimer.timeout.connect(_on_off_hand_atk_timer)
	load_game()
	_look_like_camera()
	
func _physics_process(_delta: float) -> void:
	#_character.rotation.y = get_viewport().get_camera_3d().rotation.y+PI
	match _state :
		State.MOVE:
			if Input.is_action_just_released("interact") :
				if world.target_monster and world.target_monster.state == Monster.State.DEATH :
					pass # do loot
				if world.target_monster and world.target_monster.is_atkable() && not gui.is_open():
					_attacked_monster = world.target_monster
					var _range = get_atk_range() + 1  if _attacked_monster.is_large() else get_atk_range()
					if distance_to(_attacked_monster) < _range  :
						_start_atk()
			else : 
				_handle_move_input()
		State.HIT: stop_move()
		State.DEATH: stop_move()
		State.SPELL: stop_move()

	if is_on_floor() : velocity.y = 0
	else : velocity += get_gravity() * _delta
	move_and_slide()

func _handle_move_input() -> void:
	var input_dir := Input.get_vector("move_left", "move_right", "move_front", "move_back")
	if input_dir and gui.can_move():
		var cam_basis := get_viewport().get_camera_3d().get_global_transform().basis
		var direction := cam_basis * Vector3(input_dir.x, 0, input_dir.y)
		direction.y = 0
		direction = direction.normalized();
		if direction:
			velocity.x = direction.x * _movement_speed
			velocity.z = direction.z * _movement_speed
			_character.rotation.y = atan2(direction.x,direction.z)
			_start_animation("Walking_A")
		else:
			stop_move()
			_start_animation("Idle_A")
	else:
		stop_move()
		_start_animation("Idle_A")

func stop_move() -> void :
	velocity.x = 0
	velocity.z = 0

func receive_atk(nb_atk: int, monster:Monster) -> void:
	var nb_def = Dices.d6(get_def(), 5)
	var deg = nb_atk - nb_def
	if nb_atk > 0 :
		gui.consoleLog("%s obtient %d 💀, vous obtenez %d 🛡" % [monster.name, nb_atk, nb_def])
	else :
		gui.consoleLog("%s obtient %d 💀" % [monster.name, nb_atk])
		
	if deg > 0 :
		$HumanYell3.play()
		hitten.emit(deg)
		pv = max(pv - deg, 0)
		if pv > 0:
			_start_animation("Hit_A")
			_state = State.HIT
		else :
			_start_animation("Death_A")
			_state = State.DEATH

func _start_atk() -> void:
	var duration = _start_animation(get_atk_animation())
	_mainHandAtkTimer.start(duration*get_atk_main_hand_timer_factor())
	if is_atk_dual_Hand() : _offHandAtkTimer.start(duration*get_atk_off_hand_timer_factor())
	_look_like_camera()
	_state = State.ATTACK
	stop_move()

func _on_main_hand_atk_timer() -> void:
	var nb_atk = get_atk_main_hand()
	_attacked_monster.receive_atk(nb_atk)
	$Swing3.play()

func _on_off_hand_atk_timer() -> void:
	var nb_atk = get_atk_off_hand()
	_attacked_monster.receive_atk(nb_atk)
	$Swing3.play()

func start_cast_spell(spell : Spell) -> void:
	_look_like_camera()
	if spell.available() : 
		_attacked_monster = world.target_monster # est-ce quye ca serai pas mieux de le faire dans le spell ? 
		_state = State.SPELL
		spell.start_cast()

func _start_animation(anim_name:String) -> float:
	var duration = _get_animation(anim_name).length
	var animation =  "RigMedium/" + anim_name
	_animation.play(animation)
	return duration

func _get_animation(anim_name:String) -> Animation:
	var animation =  "RigMedium/" + anim_name
	return _animation.get_animation(animation)

func _on_animation_finished(_anim_name : String) -> void:
	#print("animation end %s %d"%[_anim_name, _state])
	match _state :
		State.SPELL :
			_state = State.MOVE
		State.ATTACK:
			_state = State.MOVE
		State.HIT :
			_state = State.MOVE

func reset_orientation() -> void:
	_character.rotation.y = PI/2
	$Camera3D.rotation.y = -PI/2
	$Camera3D.rotation.x = 0
	global_position.x = 0
	global_position.z = 0

func _look_like_camera() -> void:
	_character.rotation.y = get_viewport().get_camera_3d().rotation.y+PI

func save_game() -> void : 
	if isDead() : 
		gui.consoleLog("Sauvegarde impossible")
		return
	var save_data = {
		"lvl" : lvl,
		"pv" : pv,
		"xp" : xp,
		"gold" : bag.gold,
		"tags" : tags._tags,
		"quests" : quest_book._quests,
		"bag": bag.to_save()
	}
	var json_string = JSON.stringify(save_data, "\t")
	var file = FileAccess.open("user://%s.save"%[get_player_classe()], FileAccess.WRITE)
	file.store_line(json_string)
	file.close()
	gui.consoleLog("Partie sauvegardée")

func load_game() -> void : 
	var file_name = "user://%s.save"%[get_player_classe()]
	if FileAccess.file_exists(file_name) :
		var file = FileAccess.open(file_name, FileAccess.READ)
		var save_data = JSON.parse_string(file.get_as_text())
		lvl = save_data["lvl"]
		pv = save_data["pv"]
		xp = save_data["xp"]
		bag.gold = save_data.get("gold", 0)
		for tag in save_data["tags"] : tags._tags.append(tag)
		for item in save_data["bag"] : bag._items.append(item)
		quest_book._quests = save_data["quests"]
		gui.consoleLog("Partie chargée")
		file.close()




func isDead() -> bool: return _state == State.DEATH or pv <= 0

@abstract func get_def() -> int
@abstract func get_max_pv() -> int
@abstract func get_atk_range() -> float
@abstract func get_atk_animation() -> String
@abstract func is_atk_dual_Hand() -> bool
@abstract func get_atk_main_hand() -> int
@abstract func get_atk_main_hand_timer_factor() -> float
@abstract func get_atk_off_hand() -> int
@abstract func get_atk_off_hand_timer_factor() -> float
@abstract func get_spells() -> Array[Spell]
@abstract func get_player_classe() -> String
