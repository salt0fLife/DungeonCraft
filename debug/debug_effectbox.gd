extends Area3D
@export var effect_to_apply: Lookup.statusEffectType
@export var time = 5.0

func _ready():
	$Label3D.text = Lookup.status_effect_names[effect_to_apply]



func _on_body_entered(body):
	#print(body)
	body.apply_status_effect(effect_to_apply,time)
	pass # Replace with function body.
