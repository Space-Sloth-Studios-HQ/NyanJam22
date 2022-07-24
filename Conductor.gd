extends Node2D


var on_beat = 0.0
var bpm = 0.0

var notes: Array = []
var current_note_idx = 0
export var nyan_file = "res://Assets/nyan_files/usseewa.nyan"
export var starting_note_positions = [Vector2(), Vector2(), Vector2(), Vector2()]
export var beats_per_fall: float = 4.0

const MINUTES_PER_SECOND = 0.01666666666666666667
onready var music_stream_player = get_node("MusicStreamPlayer")
onready var judgement_area_1 = get_node("JudgementArea2D_1")
onready var judgement_area_2 = get_node("JudgementArea2D_2")
onready var judgement_area_3 = get_node("JudgementArea2D_3")
onready var judgement_area_4 = get_node("JudgementArea2D_4")
onready var note_node: Resource = load("res://Note.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	var load_success = load_song()
	if not load_success: return
	music_stream_player.play()


func load_song():
	var file = File.new()
	file.open(nyan_file, File.READ)
	#var content = file.get_as_text()
	bpm = float(file.get_line())
	while not file.eof_reached():
		var note_line = file.get_line()
		var note_line_arr = note_line.split(",")
		if not note_line_arr.size() == 1: # The fuck is this 1?
			var note_node_instance: Note = note_node.instance()
			note_node_instance.initialize(note_line_arr[0], float(note_line_arr[1]), bpm, beats_per_fall)
			var sprite: Sprite = note_node_instance.get_child(0)
			if note_line_arr[0] == "0":
				judgement_area_1.connect("area_entered", note_node_instance, "_on_judgement_area_entered")
				note_node_instance.position = starting_note_positions[0]
				sprite.frame = 0
			if note_line_arr[0] == "1":
				judgement_area_2.connect("area_entered", note_node_instance, "_on_judgement_area_entered")
				note_node_instance.position = starting_note_positions[1]
				sprite.frame = 1
			if note_line_arr[0] == "2":
				judgement_area_3.connect("area_entered", note_node_instance, "_on_judgement_area_entered")
				note_node_instance.position = starting_note_positions[2]
				sprite.frame = 2
			if note_line_arr[0] == "3":
				judgement_area_4.connect("area_entered", note_node_instance, "_on_judgement_area_entered")
				sprite.frame = 3
				note_node_instance.position = starting_note_positions[3]
			notes.append(note_node_instance)	
	file.close()
	return true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if music_stream_player.playing:
		on_beat = bpm * MINUTES_PER_SECOND * music_stream_player.get_playback_position()
		#print(on_beat)
		if current_note_idx < notes.size():
			var current_note = notes[current_note_idx]
			if abs(current_note.get_beat() - on_beat - beats_per_fall) < 1e-1:
				print("Adding current_note " + str(current_note.position))
				current_note.activate()
				add_child(current_note)
				current_note_idx += 1
				
