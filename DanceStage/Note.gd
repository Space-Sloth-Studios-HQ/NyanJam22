extends Area2D
class_name Note

enum NoteType {
	LEFT,
	RIGHT,
	UP,
	DOWN
}

export (NoteType) var note = NoteType.LEFT
var beat: float = 0.0
var beats_per_minute: float = 0.0
var beats_per_fall: float = 4.0
var start: int = -50
var target: int = 500
var is_active = false
var is_hittable = false
var multiplier: String = ""

onready var sprite = $Sprite
const MINUTES_PER_SECOND = 0.01666666666666666667

signal played

func _ready():
	sprite.frame = note

func initialize(n = 0, b: float = 0.0, bpm: float = 0.0, bpf: float = 0.0):
	note = n
	beat = b
	beats_per_minute = bpm
	beats_per_fall = bpf
	#print(beats_per_fall)
	#print("Adding note " + str(note) + " at beat " + str(beat))
	
func _on_conductor_bpm_changed(bpm):
	var scale = float(bpm / beats_per_minute)
	beats_per_minute = bpm
	
func set_conductor(conductor):
	conductor.connect("bpm_changed", self, "_on_conductor_bpm_changed")

func get_note():
	return note

func get_beat():
	return beat

func activate():
	is_active = true
	
func get_sprite():
	return $Sprite
	
func _process(delta):
	if is_active:
		var velocity = (delta * (MINUTES_PER_SECOND) * beats_per_minute * (target - start)) / beats_per_fall
		#print(velocity)
		position.y += velocity
		if is_hittable:
			if note == 0 and Input.is_action_just_pressed("far_left"):
				emit_signal("played", multiplier)
				queue_free()
			elif note == 1 and Input.is_action_just_pressed("middle_left"):
				emit_signal("played", multiplier)
				queue_free()
			elif note == 2 and Input.is_action_just_pressed("middle_right"):
				emit_signal("played", multiplier)
				queue_free()
			elif note == 3 and Input.is_action_just_pressed("far_right"):
				emit_signal("played", multiplier)
				queue_free()
			
	
func _on_early_judgement_area_entered(area: Area2D):
	if self == area:
		is_hittable = true
		multiplier = "early"
		
func _on_great_judgement_area_entered(area: Area2D):
	if self == area:
		is_hittable = true
		multiplier = "great"
		
func _on_perfect_area_entered(area: Area2D):
	if self == area:
		is_hittable = true
		multiplier = "perfect"
		
func _on_late_judgement_area_entered(area: Area2D):
	if self == area:
		is_hittable = true
		multiplier = "late"

func _on_judgement_area_exited(area: Area2D):
	if self == area:
		is_hittable = false
