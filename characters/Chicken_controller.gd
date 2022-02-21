extends KinematicBody2D

var coin = preload("res://items/MonkeyBux_coin.tscn")
var splode = preload("res://effects/Splode.tscn")

var speed  = 200
var new_move = true
var can_flap = true
var rand = RandomNumberGenerator.new()
var velocity = Vector2()
var rotation_dir = 0


func _ready():
	rand.randomize()
func get_input():
	rotation_degrees = rand.randf_range(0,360)

func _physics_process(delta):
	if new_move:
		$Timer.start()
		get_input()
		new_move = false
	
	if can_flap:
		can_flap = false
		$flap_timer.start(rand.randi_range(.2, .9))
		$Chicken/AnimationPlayer.play("flap")
		
	velocity = Vector2(speed, 0).rotated(rotation)
	#rotation += rotation_dir * rotation_speed * delta
	velocity = move_and_slide(velocity)
	
	
func on_hit():
	print("Chicken: HIT")
	if rand.randf() < .8:
		var c = coin.instance()
		Signals.emit_signal("add_bullet", c, global_transform)
		
	var s = splode.instance()
	get_parent().add_child(s)
	s.global_position = global_position
	#Signals.emit_signal("exp_added", 10)
	call_deferred("free")

func _on_Timer_timeout():
	$Timer.wait_time = rand.randf() * 2
	new_move = true

func _on_flap_timer_timeout():
	can_flap = true
