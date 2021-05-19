extends KinematicBody2D

const PLAYERHURTSOUND = preload("res://Action_RPG_Resources/Player/PlayerHurtSound.tscn")

export var ACCELERATION = 500
export var MAXSPEED = 80 
export var ROLLSPEED = 120
export var FRICTION = 500

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
	swordHitbox.knockback_vector = roll_vector
	

func _physics_process(delta):
	match state:
		MOVE:
			move_state(delta)
		ROLL:
			roll_state(delta)
		ATTACK:
			attack_state(delta)
	
	
func move_state(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	
	if input_vector != Vector2.ZERO:
		roll_vector = input_vector
		swordHitbox.knockback_vector = input_vector
		animationTree.set("parameters/Idle/blend_position", input_vector)
		animationTree.set("parameters/Run/blend_position", input_vector)
		animationTree.set("parameters/Attack/blend_position", input_vector)
		animationTree.set("parameters/Roll/blend_position", input_vector)
		
		animationState.travel("Run")
		velocity = velocity.move_toward(input_vector * MAXSPEED, ACCELERATION * delta)
	else:
		animationState.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
		
	move()
	
	if Input.is_action_just_pressed("attack"):
		state = ATTACK
	
	if Input.is_action_just_pressed("roll"):
		state = ROLL
		
func move():
	velocity = move_and_slide(velocity)
	

func attack_state(_delta):
	velocity = Vector2.ZERO
	animationState.travel("Attack")
	
func attack_animation_finished():
	state = MOVE
	
func roll_state(_delta):
	velocity = roll_vector * ROLLSPEED
	animationState.travel("Roll")
	move()

func roll_animation_finished():
	velocity = velocity * .8
	state = MOVE


func _on_Hurtbox_area_entered(area):
	stats.health -= area.damage
	hurtbox.start_invincibility(.6)
	hurtbox._create_hit_effect()
	var player_hurt_sound = PLAYERHURTSOUND.instance()
	get_tree().current_scene.add_child(player_hurt_sound)
	
	


func _on_Hurtbox_invincibility_started():
	blink_animation_player.play("Start")
	



func _on_Hurtbox_invincibility_ended():
	blink_animation_player.play("Stop")
