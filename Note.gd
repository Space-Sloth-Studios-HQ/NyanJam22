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
const MINUTES_PER_SECOND = 0.01666666666666666667

func initialize(n = NoteType.LEFT, b: float = 0.0, bpm: float = 0.0, bpf: float = 0.0):
	note = n
	beat = b
	beats_per_minute = bpm
	beats_per_fall = bpf
	#print(beats_per_fall)
	#print("Adding note " + str(note) + " at beat " + str(beat))
	
func _ready():
	pass

func get_note():
	return note

func get_beat():
	return beat

func activate():
	is_active = true
	
func _process(delta):
	if is_active:
		var velocity = (delta * (MINUTES_PER_SECOND) * beats_per_minute * (target - start)) / beats_per_fall
		print(velocity)
		position.y += velocity
		
	
func _on_judgement_area_entered(area: Area2D):
	if self == area:
		queue_free()
