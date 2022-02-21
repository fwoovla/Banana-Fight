extends Control


func _ready():
	pass # Replace with function body.


func _on_back_pressed():
	hide()


func _on_Button_pressed():
	var linking_code = ""
	Enjin.CreatePlayer($username.text)
	linking_code = Enjin.GetPlayerLinkingCode($username.text)
	if linking_code == "wallet found":
		Signals.emit_signal("new_message", "Player has existing Enjin account.")
		#hide()
		
	$Qr_inage/Label.text = linking_code
	var qr_url = Enjin.GetLinkingQr($username.text)
	$QR_request.request(qr_url)


func _on_QR_request_image_loaded(image):
	print("Enjin Create: Recieved QR Image")
	$Qr_inage.texture = image
	
	$username.hide()
	$Button.hide()
	
	$Qr_inage.show()
