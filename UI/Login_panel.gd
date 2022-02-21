extends Control

signal open_create_panel

func _ready():
	var f = File.new()
	f.open("res://settings/TitleData.json", File.READ)
	var res = JSON.parse(f.get_as_text())
	f.close()

	PlayFabSettings.TitleId = res.result["titleId"]
	PlayFabSettings.DeveloperSecretKey = res.result["developerSecretKey"]
	
	$password.secret = true
	
	Signals.connect("start_game", self, "start_game")
	PFab.connect("login_return_code", self, "login_complete")

func _process(delta):
	if $username.text !="" and $password.text !="":
		$login_but.disabled = false


func _on_Button_pressed():
	get_tree().quit()


func _on_login_but_pressed():
	var username = $username.text
	var password = $password.text
	
	PFab.login(username, password)

func login_complete(error):
	print("Login: Login Complete" + str(error))
	if error == false:
		return
	if Enjin.FindPlayer($username.text):
		PFab.player_name = $username.text
		var linking_code = Enjin.GetPlayerLinkingCode($username.text)
		if linking_code == "wallet found":
			var wallet = Enjin.GetPlayerWallet($username.text)
			Enjin.GetPlayerBalances(wallet)
				
			print("       Good To Go!  Starting Game!")
			hide()
			#get_tree().change_scene("res://levels/Lobby2D.tscn")
			Signals.emit_signal("start_game")
			print("****  Player Enjin Balances: ---------- " + str(Enjin.balance_dict.keys()))
			return
		var qr_url = Enjin.GetLinkingQr($username.text)
		#print(qr_url)
		$QR_request.request(qr_url)
		Signals.emit_signal("new_message", "Please link your wallet: " + linking_code)
	else:
		Signals.emit_signal("new_message", "Please link your wallet:")
		$Create_enjin_panel/username.text = $username.text
		$Create_enjin_panel.show()
	

func _on_create_but_pressed():
	$Cerate_playfab_panel.show()

func start_game():
	print("Login: Starting Game")
	#yield(get_tree().create_timer(1), "timeout")
	get_tree().change_scene("res://levels/Lobby2D.tscn")
