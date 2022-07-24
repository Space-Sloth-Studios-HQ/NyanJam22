extends Timer
class_name EffectTimer

signal remove_effect

var effect_type = 0

func get_effect_type():
	return effect_type

func set_effect_type(effect_type: String):
	self.effect_type = effect_type
	
func _ready():
	start()

func _on_IncreaseBPMEffect_timeout():
	emit_signal("remove_effect", self)
	stop()
