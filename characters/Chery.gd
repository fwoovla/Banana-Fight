extends Area2D



func _on_Chery_body_entered(body):
	if body.is_in_group("monkey"):
		body.get_chery()
		call_deferred("free")
		

