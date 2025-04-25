extends CharacterBody2D

var chase = false

var speed = 100


@onready var anim = $AnimatedSprite2D
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	var player = $"../Player/Player"
	var direction = (player.position - self.position).normalized()
	
	if chase ==true:
		velocity.x = direction.x * speed
		anim.play("Run")
	else:
		velocity.x = 0
		anim.play("idle")
		
	if direction.x < 0:
		anim.flip_h = true
	else:
		anim.flip_h = false
	move_and_slide()
	


func _on_detector_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		
		chase = true


func _on_detector_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		
		chase = false
