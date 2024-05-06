extends CharacterBody2D

var health
var maxHealth = 3
const SPEED = 130.0
const JUMP_VELOCITY = -300.0
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_bar: ProgressBar = $HealthBar
@onready var timer: Timer = $Timer


func _ready():
	#var sigBus = get_node("/root/SignalBus")
	SignalBus.hurt_player.connect(on_hurt_player)
	SignalBus.dead_player.connect(on_dead_player)
	health = maxHealth
	health_bar.max_value = maxHealth
	health_bar.value = maxHealth
	timer.wait_time = 0.5
	

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")
 
func on_hurt_player():
	print("Took Damage")
	reduce_health()
	

func reduce_health():
	health -= 1
	health_bar.value = health
	print("Health = " + str(health))
	if health == 0:
		SignalBus.emit_signal("dead_player")

func on_dead_player():
	timer.start()
	Engine.time_scale = 0.5

func _on_timer_timeout() -> void:
	print("You died!")
	#get_tree().reload_current_scene()

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("move_left", "move_right")
	
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
	
	if is_on_floor():
		if direction == 0:
			animated_sprite.play("Idle")
		else:
			animated_sprite.play("run")
	elif !is_on_floor():
		animated_sprite.play("jump")
	elif health == 0:
		Engine.time_scale = 0.5
		animated_sprite.play("death")
	
	
	
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()






