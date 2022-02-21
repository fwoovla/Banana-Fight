extends Area2D


func _on_MonkeyBux_coin_body_entered(body: Node2D):
	if body.is_in_group("monkey"):
		Signals.emit_signal("coin_grabbed")
		$AnimationPlayer.play("grabbed")
	


func _on_AnimationPlayer_animation_finished(anim_name):
	queue_free()
