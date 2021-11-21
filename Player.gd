extends Area2D

signal hit

export var speed = 400 # How fast the player will move (pixels/sec).
var screen_size # Size of the game window.
onready var _anim_tree = $AnimationTree
var state_machine

func _ready():
	screen_size = get_viewport_rect().size
	state_machine = _anim_tree.get("parameters/playback")

func _process(delta):
	var velocity = Vector2.ZERO # The player's movement vector.
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1
	if Input.is_action_pressed("attack"):
		state_machine.travel("attack")
	if Input.is_action_pressed("bash"):
		state_machine.travel("bash")

	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		_anim_tree.set_condition("isIdle", velocity.length() <= 0)
		_anim_tree.set_condition("isMoving", velocity.length() > 0)
	else:
		_anim_tree.set_condition("isIdle", velocity.length() <= 0)
		_anim_tree.set_condition("isMoving", velocity.length() > 0)

	position += velocity * delta
	position.x = clamp(position.x, 0, screen_size.x)
	position.y = clamp(position.y, 0, screen_size.y)

	if velocity.x != 0:
		$AnimatedSprite.flip_v = false
		$AnimatedSprite.flip_h = velocity.x < 0


func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false


func _on_Player_body_entered(_body):
	hide() # Player disappears after being hit.
	emit_signal("hit")
	# Must be deferred as we can't change physics properties on a physics callback.
	$CollisionShape2D.set_deferred("disabled", true)