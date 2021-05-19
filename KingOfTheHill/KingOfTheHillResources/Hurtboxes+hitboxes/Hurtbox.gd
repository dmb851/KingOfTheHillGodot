extends Area2D

const HITEFFECT = preload("res://Action_RPG_Resources/Effects/HitEffect.tscn")

var invincible = false setget set_invincible

onready var timer = $Timer
onready var collisionshape = $CollisionShape2D

signal invincibility_started
signal invincibility_ended

func set_invincible(value):
	invincible = value
	if invincible == true:
		emit_signal("invincibility_started")
	else:
		emit_signal("invincibility_ended")
		
func start_invincibility(duration):
	self.invincible = true
	timer.start(duration)
	

func _create_hit_effect():
	var effect = HITEFFECT.instance()
	var main = get_tree().current_scene
	main.add_child(effect)
	effect.global_position = global_position 
	


func _on_Timer_timeout():
	self.invincible = false

func _on_Hurtbox_invincibility_started():
	collisionshape.set_deferred("disabled", true)
	
func _on_Hurtbox_invincibility_ended():
	collisionshape.disabled = false
