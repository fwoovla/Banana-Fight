extends Control


signal Pfab_registered

func _ready():
	PFab.connect("create_return_code", self, "create_complete")
	#connect("Pfab_registered", self, "create_enjin_account")
	pass # Replace with function body.


func _process(delta):
	if $username.text != "" and $password.text != "" and $password2.text != "":
		$Create_but.disabled = false


func _on_Create_but_pressed():
	if $password.text == $password2.text:
		if PFab.register_user($username.text, $password.text):
			emit_signal("Pfab_registered", $username.text)
	else:
		#print("passwords do not match")
		Signals.emit_signal("new_message", "passwords do not match")


func create_complete(error):
	print("Pfab Create: Create Player Attempt: " + error)
	var linking_code
	if error == false:
		return
	if Enjin.FindPlayer($username.text):
		#print("player found")
		linking_code = Enjin.GetPlayerLinkingCode($username.text)
		if linking_code == "wallet found":
			Signals.emit_signal("new_message", "Player has existing Enjin account.")
			#hide()
			return
		var qr_url = Enjin.GetLinkingQr($username.text)
		#print(qr_url)
		$QR_request.request(qr_url)
		#Signals.emit_signal("new_message", "Please link your wallet: " + linking_code)		
	else:
		Enjin.CreatePlayer($username.text)
		linking_code = Enjin.GetPlayerLinkingCode($username.text)
		if linking_code == "wallet found":
			Signals.emit_signal("new_message", "Player has existing Enjin account.")
			#hide()
			return
		var qr_url = Enjin.GetLinkingQr($username.text)
		$QR_request.request(qr_url)
		$qr_image/Label.text = "Please link your wallet:  " + linking_code
		#hide()

#func login_enjin_account(error):
#	print("Pfab Create: Player  Attempt: " + error)
#	if error == false:
#		return
#	Enjin.FindPlayer($username.text)

func _on_Mess_Back_but_pressed():
	$Message.hide()


func _on_Back_but_pressed():
	hide()


func _on_QR_request_request_completed(result, response_code, headers, body):
	pass # Replace with function body.



func _on_QR_request_image_loaded(image):
	$qr_image.texture = image
	
	$username.hide()
	$password.hide()
	$password2.hide()
	$Label2.hide()
	$Label3.hide()
	$Label4.hide()
	$Create_but.hide()
	
	$qr_image.show()
