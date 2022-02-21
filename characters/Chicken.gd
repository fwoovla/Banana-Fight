extends Area2D

var coin = preload("res://items/MonkeyBux_coin.tscn")
var splode = preload("res://effects/Splode.tscn")

var speed  = 1
var new_move = true
var rand = RandomNumberGenerator.new()


func _physics_process(delta):
	if new_move:
		$Timer.start()
		new_move = false
		rotate(rand_range(0, 2*PI))
	global_position.x = global_position.x * speed * delta
		

func on_hit():
	print("Chicken: HIT")
	var c = coin.instance()
	Signals.emit_signal("add_bullet", c, global_transform)
	var s = splode.instance()
	get_parent().add_child(s)
	s.global_position = global_position
	queue_free()


func _on_Timer_timeout():
	$Timer.wait_time = randf() * 5
	new_move = true
