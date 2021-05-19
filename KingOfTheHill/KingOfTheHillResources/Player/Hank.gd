extends KinematicBody2D


export var ACCELERATION = 900
export var MAXSPEED = 200 
export var ROLLSPEED = 120
export var FRICTION = 900

enum{
	MOVE,
	ROLL,
	ATTACK
}

var state = MOVE
var velocity = Vector2.ZERO
var roll_vector = Vector2.DOWN
var stats = PlayerStats

onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")
onready var swordHitbox = $HitboxPivot/SwordHitbox
onready var hurtbox = $Hurtbox
onready var blink_animation_player = $BlinkAnimationPlayer



func _ready():
	randomize()
	stats.connect("no_health", self, "queue_free")
	animationTree.active = true

	

func _physics_process(delta):
	match state:
		MOVE:
			move_state(delta)

	
	
func move_state(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	
	if input_vector != Vector2.ZERO:
		roll_vector = input_vector

		animationTree.set("parameters/Idle2/blend_position", input_vector)
		animationTree.set("parameters/Run2/blend_position", input_vector)
		
		animationState.travel("Run2")
		velocity = velocity.move_toward(input_vector * MAXSPEED, ACCELERATION * delta)
	else:
		animationState.travel("Idle2")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
		
	move()
	
		
func move():
	velocity = move_and_slide(velocity)





func _on_Hurtbox_invincibility_ended():
	pass # Replace with function body.


func _on_Hurtbox_invincibility_started():
	pass # Replace with function body.


func _on_Hurtbox_area_entered(area):
	stats.health -= area.damage
	hurtbox.start_invincibility(.6)
	hurtbox._create_hit_effect()
	#var player_hurt_sound = PLAYERHURTSOUND.instance()
	#get_tree().current_scene.add_child(player_hurt_sound)
