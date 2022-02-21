extends TextureRect

func _ready():
	Signals.connect("item_consumed", self, "item_consumed")
	Signals.connect("item_purchased", self, "item_purchased")

func update():
	print("Shop: Update")
	if !Enjin.balance_dict.empty():
		$naner_icon/Label.text = "X " + str(Enjin.balance_dict["Nanner"].value) + " naners"
	$monkeybux_icon/Label.text = "X " + str(PFab.player_MB) + " MonkeyBux"
	
	#update lists
	$items/item_ItemList.clear()
	$upgrades/upgrade_ItemList.clear()
	
	for item in PFab.catalog:
		if item.Tags.has("upgrade"):
			$upgrades/upgrade_ItemList.add_item(item.DisplayName, Globalvars.sprite_returner(item.ItemClass))
		if item.Tags.has("throwable"):
			$items/item_ItemList.add_item(item.DisplayName, Globalvars.sprite_returner(item.ItemClass))		
	
	
func _on_back_pressed():
	get_parent().update()
	$AnimationPlayer.play("close")


func upgrade_arm_speed():
	print("Shop: Arm Speed Upgraded")
	PFab.player_data.arm_speed.Value = float(PFab.player_data.arm_speed.Value) -.1
	#print(PFab.player_data.arm_speed)
	Signals.emit_signal("new_message", "Arm Speed upgraded to: " + str(PFab.player_data.arm_speed.Value))
	PFab.set_user_data({"arm_speed":str(PFab.player_data.arm_speed.Value)})
	#Globalvars.arm_speed = float(PFab.player_data.arm_speed.Value)
	update()
	pass

func item_consumed(item:String):
	print("Shop: Item Consumed: " + item)
	PFab.get_inventory()
	print("item " + item + " consumed")
	if item == "arm_upgrade":
		upgrade_arm_speed()


func _on_item_ItemList_item_activated(index):
	print("Shop: Item Activated")
	var id = $items/item_ItemList.get_item_text(index)
	#print(id)
	for item in PFab.catalog:
		if item.DisplayName == id:
			#print("purchasing")
			PFab.purchase_item(item)

func _on_upgrade_ItemList_item_activated(index):
	print("Shop: Upgrade Activated")
	var id = $upgrades/upgrade_ItemList.get_item_text(index)
	#print(id)
	for item in PFab.catalog:
		if item.DisplayName == id:
			#print("purchasing")
			PFab.purchase_item(item)

func item_purchased():
	Signals.emit_signal("new_message", "Item Purchased!")
	update()
