extends CharacterBody2D

# Constants
const SPEED = 110.0
const JUMP_VELOCITY = -300.0

# Exported and onready variables
var maxHealth := 3
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_bar: ProgressBar = $HealthBar
@onready var death_timer: Timer = $DeathTimer
@onready var invul_timer: Timer = $InvulTimer
@onready var hurt_sound: AudioStreamPlayer2D = $HurtSound

# State variables
var health
var isDead = false
var last_direction = 1
var is_invulnerable = false

func _ready():
	health = maxHealth
	health_bar.max_value = maxHealth
	health_bar.value = maxHealth
	SignalBus.hurt_player.connect(on_hurt_player)
	SignalBus.kill_player.connect(on_kill_player)

func on_kill_player():
	trigger_death()

func on_hurt_player():
	if !is_invulnerable:
		if health > 0:
			health -= 1
			health_bar.value = health
			animated_sprite.play("hurt")
			hurt_sound.play()
			if health == 0:
				trigger_death()
			else:
				is_invulnerable = true
				invul_timer.start()
			
				
	else:
		return

func _on_invul_timer_timeout() -> void:
	is_invulnerable = false

func trigger_death():
	if !isDead:
		isDead = true
		death_timer.start()
		Engine.time_scale = 0.5
		animated_sprite.play("death")

func _on_timer_timeout():
	print("You died!")
	get_tree().reload_current_scene()
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
	if direction != 0:
		last_direction = direction
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
	if animated_sprite.animation == "hurt" and animated_sprite.is_playing():
		return
	if isDead:
		return
	if direction == 0:
		animated_sprite.flip_h = last_direction < 0
	else:
		animated_sprite.flip_h = direction < 0

	if is_on_floor():
		if direction == 0:
			animated_sprite.play("Idle")
		else:
			animated_sprite.play("run")
	elif not is_on_floor():
		animated_sprite.play("jump")




