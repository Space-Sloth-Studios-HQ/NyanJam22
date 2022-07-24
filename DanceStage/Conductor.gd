extends Node2D
class_name Conductor

var on_beat = 0.0
var bpm = 0.0

var notes: Array = []
var current_note_idx = 0
var score: int = 0
var early_hit: int = 0
var great_hit: int = 0
var perfect_hit: int = 0
var late_hit: int = 0
var missed: int = 0
var hit_streak: int = 0
var dice_used: int = 0
var is_game_over: bool = false
var can_throw_dice: bool = true
var is_increased_beats_per_fall: bool = false
var is_decreased_beats_per_fall: bool = false
var dice_enabled: bool = false
var failed: bool = false

signal score_changed
signal hit_changed
signal missed_changed
signal dice_used_changed
signal hit_streak_changed
signal bpm_changed

export var nyan_file = "res://Assets/nyan_files/usseewa.nyan"
export var starting_note_positions = [Vector2(), Vector2(), Vector2(), Vector2()]
export var beats_per_fall: float = 4.0 # Default rate of beats per fall
export var miss_streak_threshold: int = -10
export var increase_bpm_effect: float = 0.15
export var decrease_bpm_effect: float = -0.15
export var increase_beats_per_fall: float = -1 # Increase constant of beats per fall 
export var decreased_beats_per_fall: float = 1 # Decrease constant of beats per fall

const MINUTES_PER_SECOND = 0.01666666666666666667
onready var music_stream_player = get_node("MusicStreamPlayer")
onready var judgement_area_1: JudgementArea = get_node("JudgementAreas/JudgementArea2D_1")
onready var judgement_area_2: JudgementArea = get_node("JudgementAreas/JudgementArea2D_2")
onready var judgement_area_3: JudgementArea = get_node("JudgementAreas/JudgementArea2D_3")
onready var judgement_area_4: JudgementArea = get_node("JudgementAreas/JudgementArea2D_4")
onready var effects = get_node("EffectTimers")
onready var dice_cooldown_ui = get_node("UI/DiceCooldownUI")
onready var dice_cooldown_timer = get_node("UI/DiceCooldownUI/DiceCooldownTimer")
onready var dice_used_label = get_node("UI/DiceUsedLabel")
onready var note_node: Resource = load("res://DanceStage/Note.tscn")
onready var effect_timer: Resource = load("res://Effects/EffectTimer.tscn")
onready var results_screen: Resource = load("res://Screens/ResultsScreen.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	var load_success = load_song()
	if not load_success: return
	music_stream_player.play()
	dice_cooldown_timer.connect("timeout", self, "_on_dice_cooldown_timeout")

	if not dice_enabled:
		dice_used_label.visible = false
		dice_cooldown_ui.visible = false
		dice_cooldown_timer.stop()

func _on_dice_cooldown_timeout():
	can_throw_dice = true
	
func set_dice_enabled(enabled: bool):
	self.dice_enabled = enabled


func _on_note_played(multiplier_type: String):
	var multiplier = 1
	if multiplier_type == "early":
		multiplier = 0.75
		early_hit += 1
	elif multiplier_type == "great":
		multiplier = 1
		great_hit += 1
	elif multiplier_type == "perfect":
		multiplier = 1.5
		perfect_hit += 1
	elif multiplier_type == "late":
		multiplier = 0.75
		late_hit += 1
	score += int(10 * multiplier)
	hit_streak += 1
	emit_signal("score_changed", score)
	emit_signal("hit_streak_changed", hit_streak)

func load_song():
	var file = File.new()
	file.open(nyan_file, File.READ)
	#var content = file.get_as_text()
	bpm = float(file.get_line())
	while not file.eof_reached():
		var note_line = file.get_line()
		var note_line_arr = note_line.split(",")
		if not note_line_arr.size() == 1: # The fuck is this 1?
			var note_node_instance = note_node.instance()
			note_node_instance.initialize(int(note_line_arr[0]), float(note_line_arr[1]), bpm, beats_per_fall)
			#var sprite: Sprite = note_node_instance.get_sprite()
			if note_line_arr[0] == "0":
				connect_judgement_area(judgement_area_1, note_node_instance, starting_note_positions[0])
#				sprite.frame = 0
			if note_line_arr[0] == "1":
				connect_judgement_area(judgement_area_2, note_node_instance, starting_note_positions[1])
#				sprite.frame = 1
			if note_line_arr[0] == "2":
				connect_judgement_area(judgement_area_3, note_node_instance, starting_note_positions[2])
#				sprite.frame = 2
			if note_line_arr[0] == "3":
				connect_judgement_area(judgement_area_4, note_node_instance, starting_note_positions[3])
#				sprite.frame = 3
			note_node_instance.connect("played", self, "_on_note_played")
			notes.append(note_node_instance)	
	file.close()
	return true

func connect_judgement_area(judgement_area: JudgementArea, note_node_instance, pos: Vector2):
	judgement_area.get_early_area().connect("area_entered", note_node_instance, "_on_early_judgement_area_entered")
	judgement_area.get_great_area().connect("area_entered", note_node_instance, "_on_great_judgement_area_entered")
	judgement_area.get_perfect_area().connect("area_entered", note_node_instance, "_on_perfect_area_entered")
	judgement_area.get_late_area().connect("area_entered", note_node_instance, "_on_late_judgement_area_entered")
	judgement_area.get_late_area().connect("area_exited", note_node_instance, "_on_judgement_area_exited")
	note_node_instance.position = pos

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not is_game_over:
		if music_stream_player.playing:
			on_beat = bpm * MINUTES_PER_SECOND * music_stream_player.get_playback_position()
			#print(on_beat)
			if current_note_idx < notes.size():
				var current_note = notes[current_note_idx]
				#print("Current note " + str(current_note_idx) + " at beat " + str(current_note.get_beat()))
				if abs(current_note.get_beat() - on_beat - beats_per_fall) < 1e-1:
					#print("Adding current_note " + str(current_note.position))
					current_note.activate()
					current_note.set_conductor(self)
					add_child(current_note)
					current_note_idx += 1
				elif current_note.get_beat() < on_beat - beats_per_fall:
					# Seek next available note
					#print("\tSeeking next available note " + str(current_note_idx))
					while current_note_idx < notes.size() and (current_note.get_beat() < on_beat - beats_per_fall):
						current_note_idx += 1
						current_note = notes[current_note_idx]
			
			if hit_streak <= miss_streak_threshold:
				failed = true
				is_game_over = true
				
		if dice_enabled and can_throw_dice:
			dice_used += 1
			can_throw_dice = false
			dice_cooldown_timer.start()
			var effect_rng = int(rand_range(0, 2))
			if effect_rng == 0:
				_create_increase_bpm_effect()
			if effect_rng == 1:
				_create_decrease_bpm_effect()
#			if effect_rng == 2: 
#				_create_increase_fall_rate_effect()
#			if effect_rng == 3: 
#				_create_decrease_fall_rate_effect()
			
			emit_signal("dice_used_changed", dice_used)
	else:
		print("Hmmm")
		var results_screen_instance = results_screen.instance()
		var parent = get_parent()
		parent.add_child(results_screen_instance)
		results_screen_instance.set_counts(missed, perfect_hit, great_hit, late_hit, early_hit, score, failed)
		parent.remove_child(self)
		music_stream_player.stop()
		dice_cooldown_timer.stop()
		
func _create_increase_bpm_effect():
	var effect_timer_instance: EffectTimer = effect_timer.instance()
	effect_timer_instance.connect("remove_effect", self, "_on_remove_effect")
	effect_timer_instance.effect_type = 0
	_scale_music_speed(increase_bpm_effect)
	effects.add_child(effect_timer_instance)
	
func _create_decrease_bpm_effect():
	var effect_timer_instance: EffectTimer = effect_timer.instance()
	effect_timer_instance.connect("remove_effect", self, "_on_remove_effect")
	effect_timer_instance.effect_type = 1
	_scale_music_speed(decrease_bpm_effect)
	effects.add_child(effect_timer_instance)
	
func _create_increase_fall_rate_effect():
	var effect_timer_instance: EffectTimer = effect_timer.instance()
	effect_timer_instance.connect("remove_effect", self, "_on_remove_effect")
	effect_timer_instance.effect_type = 2
	beats_per_fall += increase_beats_per_fall
	effects.add_child(effect_timer_instance)
	
func _create_decrease_fall_rate_effect():
	var effect_timer_instance: EffectTimer = effect_timer.instance()
	effect_timer_instance.connect("remove_effect", self, "_on_remove_effect")
	effect_timer_instance.effect_type = 3
	beats_per_fall += decreased_beats_per_fall
	effects.add_child(effect_timer_instance)
		
func _on_remove_effect(effect: EffectTimer):
	# Undo effect and remove from queue
	var effect_type = effect.get_effect_type()
	if effect_type == 0: # Undo Increase BPM
		print("Removing increase bpm effect")
		_scale_music_speed(-1 * increase_bpm_effect)
	if effect_type == 1: # Undo Decrease BPM
		print("Removing decrease bpm effect")
		_scale_music_speed(-1 * decrease_bpm_effect)
	if effect_type == 2:
		print("Removing increase fall rate effect")
		beats_per_fall -= increase_beats_per_fall
	if effect_type == 3:
		print("Removing increase fall rate effect")
		beats_per_fall -= decreased_beats_per_fall
	effect.queue_free()
	pass

func _scale_music_speed(scale: float):
	music_stream_player.pitch_scale += scale
	emit_signal("bpm_changed", bpm * (1 + scale))
	#bpm *= 1 + scale

func _on_OOB_Area2D_area_entered(note: Area2D):
	missed += 1
	if hit_streak > 0: 
		hit_streak = 0
	else:
		hit_streak -= 1
	emit_signal("missed_changed", missed)
	emit_signal("hit_streak_changed", hit_streak)
	note.queue_free()


func _on_MusicStreamPlayer_finished():
	is_game_over = true
