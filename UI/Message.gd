extends Panel


func _ready():
	Signals.connect("new_message", self, "new_message")
	Signals.connect("new_message_image", self, "new_image")

func new_message(text):
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$Label.text = text
	show()
	
func new_image(image):
	$Image.texture = image

func _on_Mess_Back_but_pressed():
	$Image.texture = null
	hide()
