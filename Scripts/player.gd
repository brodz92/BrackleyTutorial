extends CharacterBody2D

# Constants
const SPEED = 130.0
const JUMP_VELOCITY = -300.0

# Exported and onready variables
var maxHealth := 3
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_bar: ProgressBar = $HealthBar
@onready var timer: Timer = $Timer

# State variables
var health
var isDead = false

func _ready():
	health = maxHealth
	health_bar.max_value = maxHealth
	health_bar.value = maxHealth
	SignalBus.hurt_player.connect(on_hurt_player)  # Ensure SignalBus is a valid node path

func on_hurt_player():
	print("Took Damage")
	reduce_health()

func reduce_health():
	if health > 0:
		health -= 1
		health_bar.value = health
		print("Health = " + str(health))
		if health == 0:
			trigger_death()

func trigger_death():
	if !isDead:
		isDead = true
		timer.start()
		Engine.time_scale = 0.5
		animated_sprite.play("death")

func _on_timer_timeout():
	print("You died!")
	get_tree().change_scene_to_file("res://Scenes/game.tscn")
	Engine.time_scale = 1

func _physics_process(delta: float) -> void:
	handle_gravity(delta)
	handle_jump()
	handle_movement(delta)

func handle_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

func handle_jump():
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

func handle_movement(delta):
	var direction := Input.get_axis("move_left", "move_right")
	handle_animation(direction)
	if not isDead:
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
	else:
		velocity.x = move_toward(velocity.x, 0, 0)

	move_and_slide()

func handle_animation(direction: int):
	animated_sprite.flip_h = direction < 0
	if isDead:
		return
	if is_on_floor():
		if direction == 0:
			animated_sprite.play("Idle")
		else:
			animated_sprite.play("run")
	elif not is_on_floor():
		animated_sprite.play("jump")
