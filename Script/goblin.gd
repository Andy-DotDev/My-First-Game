extends CharacterBody2D

var speed = 100

enum {
	IDLE,
	ATTACK,
	CHASE
}
var state: int = 0:
	set(value):
		state = value
		match state:
			IDLE:
				idle_state()
			ATTACK:
				attack_state()

@onready var animEnemy = $AnimationPlayer
@onready var sprite = $AnimatedSprite2D

var player
var direction
var damage = 20

func _ready() -> void:
	Signals.connect("player_position_update", Callable(self,"_on_player_position_update"))
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	if state == CHASE:
		chase_state()
	move_and_slide()

func _on_player_position_update(player_pos):
	player = player_pos

func _on_attack_range_body_entered(body: Node2D) -> void:
	state = ATTACK
func idle_state():
	animEnemy.play("idle")
	await get_tree().create_timer(0.5).timeout
	$AttackDirection/AttackRange/CollisionShape2D.disabled = false
	state = CHASE
func attack_state():
	animEnemy.play("Attack")
	await  animEnemy.animation_finished
	$AttackDirection/AttackRange/CollisionShape2D.disabled = true
	state = IDLE
	
func chase_state():
	direction = (player - self.position).normalized()
	if direction.x <0:
		sprite.flip_h = true
		$AttackDirection.rotation_degrees = 180
	else:
		sprite.flip_h = false
		$AttackDirection.rotation_degrees = 0
	


func _on_hit_box_area_entered(area: Area2D) -> void:
	Signals.emit_signal("enemy_attack", damage)
