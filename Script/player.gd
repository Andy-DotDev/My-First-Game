extends CharacterBody2D

enum {
	RUN,
	ATTACK,
	ATTACK2,
	SLIDE,
	DAMAGE,
	DEATH
}

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

@onready var anim = $AnimatedSprite2D
@onready var animPlayer = $AnimationPlayer

var health = 100
var state= RUN
var combo = false
var move = false
var player_pos

func _ready() -> void:
	Signals.connect("enemy_attack",Callable(self,"_on_damage_received"))

func _physics_process(delta: float) -> void:
	match  state:
		RUN:
			run_state()
		ATTACK:
			attack_state()
		ATTACK2:
			attack2_state()
		SLIDE:
			slide_state()
		DAMAGE:
			damage_state()
		DEATH:
			death_state()
	if not is_on_floor():
		velocity += get_gravity() * delta
		
		
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		animPlayer.play("Jump")

	if velocity.y > 0:
		animPlayer.play("Fall")
	move_and_slide()
	
	player_pos = self.position
	
	Signals.emit_signal("player_position_update", player_pos)
func attack_state():
	if Input.is_action_just_pressed("attack") and combo == true:
		state = ATTACK2
	velocity.x = 0
	animPlayer.play("Attack")
	await animPlayer.animation_finished
	state = RUN
func run_state():
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
		move = true
		if velocity.y == 0:
			animPlayer.play("Run")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		move = false
		if velocity.y ==0:
			animPlayer.play("idle")
	if direction == -1:
		anim.flip_h = true
		
	elif direction == 1:
		anim.flip_h = false
		
	if Input.is_action_just_pressed("attack"):
		state = ATTACK
	if Input.is_action_just_pressed("slide") and move == true:
		state = SLIDE
func attack2_state():
	animPlayer.play("Attack2")
	await animPlayer.animation_finished
	state = RUN
func combo1 ():
	combo = true
	await  animPlayer.animation_finished
	combo = false
func slide_state():
	animPlayer.play("Slide")
	await  animPlayer.animation_finished
	state= RUN
func death_state():
	velocity.x = 0
	animPlayer.play("Death")
	await animPlayer.animation_finished
	queue_free()
	get_tree().change_scene_to_file.call_deferred("res://Scene/menu.tscn")
func damage_state():
	velocity.x = 0
	animPlayer.play("Hit")
	await animPlayer.animation_finished
	state = RUN

func _on_damage_received(enemy_damage):
	health -= enemy_damage
	if health <= 0:
		health = 0
		state = DEATH
	else:
		state = DAMAGE

	print(health)
