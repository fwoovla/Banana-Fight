extends KinematicBody2D
class_name Monkey

export (int) var speed = 300

var velocity = Vector2.ZERO
var arms = []
var arm_counter = 0

func _ready():
	arms.append($left_arm)
	$left_arm.item = Globalvars.left_hand_item
	$left_arm/AnimationPlayer.playback_speed = 1 + (1 - float(PFab.player_data.arm_speed.Value))
	arms.append($right_arm)
	$right_arm.item = Globalvars.right_hand_item
	$right_arm/AnimationPlayer.playback_speed = 1 + (1 - float(PFab.player_data.arm_speed.Value))
	
	Signals.connect("coin_grabbed", self, "coin_grabbed")

func get_input():
	velocity.x = 0
	velocity.y = 0
	if Input.is_action_pressed("right"):
		velocity.x += speed
	if Input.is_action_pressed("left"):
		velocity.x -= speed
	if Input.is_action_pressed("up"):
		velocity.y -= speed
	if Input.is_action_pressed("down"):
		velocity.y += speed
		
	if Input.is_action_just_pressed("left_click"):
		if arm_counter >= arms.size():
			arm_counter = 0
		arms[arm_counter].get_node("AnimationPlayer").play("throw")
		arms[arm_counter].throw()
		arm_counter +=1
	

func _physics_process(delta):
	#if !Globalvars.is_paused:
	get_input()
	look_at(get_global_mouse_position())
	velocity = move_and_slide(velocity, Vector2.UP)

func coin_grabbed():
	$CanvasLayer/mb_sprite/AnimationPlayer.play("New Anim")
	$CanvasLayer/mb_label.text = str(int($CanvasLayer/mb_label.text) +1)

func get_chery():
	Signals.emit_signal("chery_grabbed")
