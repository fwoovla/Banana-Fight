extends Area2D

var hit = preload("res://characters/items/hit1.tscn")

var speed = 600

func _physics_process(delta):
	position += transform.x * speed * delta


func _on_Timer_timeout():
	queue_free()


func _on_banana_area_entered(area):
	if !area.is_in_group("monkey"):
		if area.has_method("on_hit"):
			area.on_hit()
		var h = hit.instance()
		get_parent().add_child(h)
		h.global_position = global_position
		call_deferred("free")

func _on_banana_body_entered(body):
	if !body.is_in_group("monkey"):
		if body.has_method("on_hit"):
			body.on_hit()
		var h = hit.instance()
		get_parent().add_child(h)
		h.global_position = global_position
		call_deferred("free")
