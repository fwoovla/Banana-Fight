extends Node

signal create_return_code
signal login_return_code

var inventory = []
var catalog = []
var title_data = []
var player_id = ""
var player_name = ""
var player_data = {}
var player_MB = ""

#XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
func register_user(username, password):
	print("PlayFab: Creating Player")
	var dict_request = {"TitleId": PlayFabSettings.TitleId,
		"DisplayName": username.to_upper(),
		"Username": username,
		"Password": password,
		"RequireBothUsernameAndEmail": false}
	
	PlayFab.Client.RegisterPlayFabUser(
		dict_request,
		funcref(self, "create_request_completed")
	)
	
func create_request_completed(h_request: int, response_code: int, headers, json_parse_result: JSONParseResult):
	print("PlayFab: Player Created")
	#print("plyfab request complete")

	if json_parse_result.error == OK:
		var result = (Dictionary(json_parse_result.result))
		#print(result)
		if result.has("error"):
			Signals.emit_signal("new_message", result.errorMessage)
			emit_signal("create_return_code", false)
		if result.code == 200:
			var token = result.data.EntityToken
			emit_signal("create_return_code", true)
			initialize_player()
			#print(token)
			
#XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
func login(username, password):
	print("PlayFab: Login Attempt")
	var dict_request = {"TitleId": PlayFabSettings.TitleId,
		"Username": username,
		"Password": password}
	PlayFab.Client.LoginWithPlayFab(
		dict_request,
		funcref(self, "login_request_completed")
	)
			
func login_request_completed(h_request: int, response_code: int, headers, json_parse_result: JSONParseResult):
	print("PlayFab: Login Attempt Complete")
	if json_parse_result.error == OK:
		var result = (Dictionary(json_parse_result.result))
		#print(result)
		if result.has("error"):
			Signals.emit_signal("new_message", result.errorMessage)
			emit_signal("login_return_code", false)
		if result.code == 200:
			#print("result" + str(result))
			var token = result.data.EntityToken
			#print("token" + str(token))
			player_id = token.Entity.Id
			#print(player_id)
			#initialize_player()
			PlayFab.Client.GetUserData({}, funcref(self, "user_data_returned"))
			var dict_request = {}
			PlayFab.Client.GetTitleData(dict_request,  funcref(self, "Title_response"))			
			var dict_request2 = {}
			PlayFab.Client.GetCatalogItems(dict_request2,  funcref(self, "Catalog_response"))
			get_inventory()					
			emit_signal("login_return_code", true)
			#Signals.emit_signal("start_game")

func Title_response(h_request: int, response_code: int, headers, json_parse_result: JSONParseResult):
	print("PlayFab: Title Data Rcieved")
	if json_parse_result.error == OK:
		var result = (Dictionary(json_parse_result.result))
		print("-- " + str(result.data.Data))
		title_data = result.data.Data
				
#XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
			

		
#XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX	
func get_inventory():
	print("PlayFab: Getting Player Inventory")
	var dict_request = {}
	PlayFab.Client.GetUserInventory(dict_request, funcref(self, "Inventory_response"))
	
func Inventory_response(h_request: int, response_code: int, headers, json_parse_result: JSONParseResult):
	print("PlayFab: Player Inventory Found")
	if json_parse_result.error == OK:
		var result = (Dictionary(json_parse_result.result))
		#print(result)
		inventory = result.data.Inventory
		player_MB = result.data.VirtualCurrency.MB
		var text = ""
		for i in inventory:
			text = text + "\n" + i.DisplayName
			print(" --" + i.DisplayName)
			
#XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX	
func get_catalog():
	print("PlayFab: Getting Catalog")
	var dict_request = {}
	PlayFab.Client.GetCatalogItems(dict_request,  funcref(self, "Catalog_response"))		
	
func Catalog_response(h_request: int, response_code: int, headers, json_parse_result: JSONParseResult):
	print("PlayFab: Catalog Data Recieved")
	if json_parse_result.error == OK:
		var result = (Dictionary(json_parse_result.result))
		print(result.data.Catalog)
		catalog = result.data.Catalog
		var text = ""
		for i in catalog:
			text = text + "\n" + i.DisplayName
			print("- "+ i.DisplayName)
		#Signals.emit_signal("new_message", text)
		
#XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
func set_user_data(data):
	print("PlayFab: Setting Data")
	PlayFab.Client.UpdateUserData({"Data":data}, funcref(self, "data_updated"))	
	
func data_updated(h_request: int, response_code: int, headers, json_parse_result: JSONParseResult):
		if json_parse_result.error == OK:
			var result = (Dictionary(json_parse_result.result))
			print("PlayFab: Data Set Succesfull")
			PlayFab.Client.GetUserData({}, funcref(self, "user_data_returned"))
			#print(result)
		else:
			print("PlayFab: Setting Data Failed !!!!")


#XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
func initialize_player():
	print("PlayFab: Initializing Player Settings")
	var data = {"arm_speed":"1", "level":"1","experience":"0"}		
	#var data = {"Data": {"arm_speed":"1"}}
	PlayFab.Client.UpdateUserData({"Data":data}, funcref(self, "data_updated"))
	PlayFab.Client.GetUserData({}, funcref(self, "user_data_returned"))

func user_data_returned(h_request: int, response_code: int, headers, json_parse_result: JSONParseResult):
	if json_parse_result.error == OK:
		var result = (Dictionary(json_parse_result.result))
		player_data = result.data.Data
		
#XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
func purchase_item(item:Dictionary):
	print("PlayFab: Purchasing Item: -- " + str(item.ItemId) + " -- " + str(item.Tags))

	var data = {"ItemId":item.ItemId, "Price":item.VirtualCurrencyPrices.MB, "VirtualCurrency":"MB"}
	
	if item.Tags.has("upgrade"): #use right now
		PlayFab.Client.PurchaseItem(data, funcref(self, "imediate_consume"))
	else:
		PlayFab.Client.PurchaseItem(data, funcref(self, "purchase_complete"))

func purchase_complete(h_request: int, response_code: int, headers, json_parse_result: JSONParseResult):

	if json_parse_result.error == OK:
		var result = (Dictionary(json_parse_result.result))
		if result.has("error"):
			Signals.emit_signal("new_message", "Can't purchase item." )
			print("PlayFab: Purchasing Falied!!")
			return
			
		print("PlayFab: Purchasing Sucsess")

	get_inventory()
	Signals.emit_signal("item_purchased")

func imediate_consume(h_request: int, response_code: int, headers, json_parse_result: JSONParseResult):
	print("PlayFab: Ready to Consume Item")
	if json_parse_result.error == OK:
		var result = (Dictionary(json_parse_result.result))
		#print("purchase and consume result:  " +str(result))
		if result.has("error"):
			Signals.emit_signal("new_message", "Can't purchase item." )
			return
		get_inventory()
		Signals.emit_signal("item_purchased")
		
		var consume_data = {"ConsumeCount":1, "ItemInstanceId":result.data.Items[0].ItemInstanceId}
		PlayFab.Client.ConsumeItem(consume_data, funcref(self, "consume_complete"))

func consume_complete(h_request: int, response_code: int, headers, json_parse_result: JSONParseResult):
	if json_parse_result.error == OK:
		var result = (Dictionary(json_parse_result.result))
		#print("consume result:  " +str(result))
		var result_id = result.data.ItemInstanceId		
		#print(result_id)
		var item_id = ""
		#get_inventory()
		#print(inventory)
		print("PlayFab: Consumed Item")
		for i in inventory:
			#print("item   --- " + str(i.ItemId))
			if str(i.ItemInstanceId) == str(result_id):
				item_id = i.ItemId
				Signals.emit_signal("item_consumed", item_id)
		
#XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
func purchase_monkeybux(value : int):
	print("PlayFab: Buying MonkeyBux")
	if Enjin.balance_dict.has("Nanner"):
		if float(Enjin.balance_dict.Nanner.value) > 0:
			var data = {"Amount":value, "VirtualCurrency":"MB"}
			PlayFab.Client.AddUserVirtualCurrency(data, funcref(self, "mb_purchase_complete"))
			#PlayFab.Server.AddUserVirtualCurrency({"PlayFabID": player_id, "VirtualCurrency": "MB", "Amount": "100"});
			
func mb_purchase_complete(h_request: int, response_code: int, headers, json_parse_result: JSONParseResult):
	var result = (Dictionary(json_parse_result.result))
	print("PlayFab: Purchase Result")
	print("MB purchase result:  " +str(result))
	print("sending from: " + Enjin.player_wallet_address)
	
	if json_parse_result.error == OK:
		Enjin.Send_Nanner_To_Project(Enjin.player_wallet_address)
		
	get_inventory()
	
#XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX	
func get_monkeybux(value: int):
	print("PlayFab: Requesting MonkeyBux")	
	var data = {"Amount":value, "VirtualCurrency":"MB"}
	PlayFab.Client.AddUserVirtualCurrency(data, funcref(self, "got_monkeybux"))
	
func got_monkeybux(h_request: int, response_code: int, headers, json_parse_result: JSONParseResult):
	print("PlayFab: Recieving MonkeyBux")	
	var result = (Dictionary(json_parse_result.result))
	
	get_inventory()
