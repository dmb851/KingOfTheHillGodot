extends KinematicBody2D

const ENEMYDEATHEFFECT = preload("res://Action_RPG_Resources/Effects/EnemyDeathEffect.tscn")

export var ACCELERATION = 300
export var MAXSPEED = 50
export var FRICTION = 200
export var WANDER_TOLERANCE = 5

enum {
	IDLE,
	WANDER,
	CHASE
}
var state = IDLE

var velocity = Vector2.ZERO
var knockback = Vector2.ZERO

onready var sprite = $AnimatedSprite
onready var stats = $Stats
onready var playerDetectionZone = $PlayerDetectionZone
onready var hurtbox = $Hurtbox
onready var softCollision = $SoftCollision
onready var wanderController = $WanderController
onready var animationPlayer = $AnimationPlayer

func _ready():
	state = pick_random_state([IDLE, WANDER])

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, 200 * delta)
	knockback = move_and_slide(knockback)
	
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, 200 * delta)
			seek_player()
			
			if wanderController.get_time_left() == 0:
				change_wander_state()
			
		WANDER:
			seek_player()
			
			if wanderController.get_time_left() == 0:
				change_wander_state()
				
			accelerate_towards_point(wanderController.targetPosition, delta)
			
			if global_position.distance_to(wanderController.targetPosition) <= WANDER_TOLERANCE:
				change_wander_state()
				
		CHASE:
			var player = playerDetectionZone.player
			if player != null:
				accelerate_towards_point(player.global_position, delta)
				
			else:
				state = IDLE
				sprite.flip_h = velocity.x < 0

	
	if softCollision.is_colliding():
		velocity += softCollision.get_push_vector() * delta * 400
		
	velocity = move_and_slide(velocity)
	
func change_wander_state():
	state = pick_random_state([IDLE, WANDER])				
	wanderController.start_wander_timer(rand_range(1, 3))
	
func accelerate_towards_point(point, delta):
	var direction = global_position.direction_to(point)
	velocity = velocity.move_toward(direction * MAXSPEED, ACCELERATION * delta)

func seek_player():
	if playerDetectionZone.can_see_player():
		state = CHASE
		
func pick_random_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()

func _on_Hurtbox_area_entered(area):
	stats.health -= area.damage
	knockback = area.knockback_vector * 120
	hurtbox._create_hit_effect()
	hurtbox.start_invincibility(0.4)

func _on_Stats_no_health():
	queue_free()
	var enemyDeathEffect = ENEMYDEATHEFFECT.instance()
	get_parent().add_child(enemyDeathEffect)
	enemyDeathEffect.global_position = global_position


func _on_Hurtbox_invincibility_started():
	animationPlayer.play("Start")


func _on_Hurtbox_invincibility_ended():
	animationPlayer.play("Stop")
