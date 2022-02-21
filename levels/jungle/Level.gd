extends Node2D

var coins_grabbed = 0
var exp_won = 0
var chery_num = 0

func _ready():
	Signals.connect("add_bullet", self, "add_bullet")
	Signals.connect("coin_grabbed", self, "coin_grabbed")
	Signals.connect("exp_added", self, "exp_added")
	Signals.connect("chery_grabbed", self, "chery_grabbed")
	
	
func add_bullet(b, pos):
	add_child(b)
	b.global_transform = pos


func _on_exit_body_entered(body:Node2D):
	if body.is_in_group("monkey"):
		$Win_panel/mb_label.text = str(coins_grabbed)
		$Win_panel/exp_label.text = str(chery_num) + " x 10 = " + str(chery_num * 10) + " XP!"
		exp_won += int(PFab.player_data.experience.Value)
		$Win_panel/AnimationPlayer.play("open")
		#get_tree().change_scene("res://levels/Lobby2D.tscn")

func exp_added(value: int):
	exp_won += value

func coin_grabbed():
	coins_grabbed +=1
	$HUD/mb_label.text = str(int($HUD/mb_label.text) + 1)
	$HUD/AnimationPlayer.play("coin")

func chery_grabbed():
	chery_num +=1
	$HUD/AnimationPlayer.play("chery")
	$HUD/chery_label.text =  str(int($HUD/chery_label.text) + 1)

func end_level():
	var level = int(PFab.player_data.level.Value)
	exp_won += chery_num * 10
	if exp_won > int(PFab.player_data.level.Value) * 100:
		level +=1
		Globalvars.show_new_level = true
	PFab.get_monkeybux(coins_grabbed)
	PFab.set_user_data({"experience": exp_won, "level": level})
	get_tree().change_scene("res://levels/Lobby2D.tscn")


func _on_win_ok_pressed():
	end_level()
