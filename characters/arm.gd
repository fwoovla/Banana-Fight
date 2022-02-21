extends Node2D

var item = PackedScene

var can_throw = true

func _ready():
	$Timer.wait_time = float(PFab.player_data.arm_speed.Value)

func initialize(_item):
	item = _item
	
func throw():
	if can_throw:
		can_throw = false
		$Timer.start(float(PFab.player_data.arm_speed.Value))
		var i = item.instance()
		Signals.emit_signal("add_bullet", i, $hand.global_transform)


func _on_Timer_timeout():
	can_throw = true
