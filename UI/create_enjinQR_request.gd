extends HTTPRequest


var url = "" #for babs i think

signal image_loaded(ImageTexture)

func _ready():
	set_download_file("res://assets/textures/qr.png")

func _on_QR_request_request_completed(result, response_code, headers, body):
	var image = Image.new()
	var err = image.load("res://assets/textures/qr.png")
	if err != OK:
		print("error")
		return
	var texture = ImageTexture.new()
	texture.create_from_image(image, 0)
	emit_signal("image_loaded", texture)
