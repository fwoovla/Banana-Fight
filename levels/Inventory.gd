extends TextureRect


func _ready():
	pass


func _on_back_pressed():
	$AnimationPlayer.play("close")
