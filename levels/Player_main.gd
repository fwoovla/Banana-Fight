extends Control

var rand = RandomNumberGenerator.new()

func _ready():
	rand.randomize()
	$loading_panel/AnimationPlayer.play("loading")
	$loading_panel.show()
	yield(get_tree().create_timer(2), "timeout")
	$loading_panel.hide()
	$loading_panel/AnimationPlayer.stop(true
	)
	if !Globalvars.welcome_sent:
		Signals.emit_signal("new_message_image", load("res://assets/sprites/star_2.png"))
		#print(PFab.title_data)
		Signals.emit_signal("new_message", PFab.title_data["Welcome Message"])
		Globalvars.welcome_sent = true
		
	if Globalvars.show_new_level == true:
		Enjin.Give_Nanner(Enjin.player_wallet_address)
		Signals.emit_signal("new_message_image", load("res://assets/sprites/star_2.png"))
		Signals.emit_signal("new_message", "New Level: " + PFab.player_data.level.Value + ". You recieved a Nanner ")
		$main_panel/naner_icon/Particles2D.emitting = true
	update()
		
func update():
	print("Player Main: Update")
	if !Enjin.balance_dict.empty():
		$main_panel/naner_icon/Label.text = "X " + str(Enjin.balance_dict["Nanner"].value)
	#print("MB " +str(PFab.player_MB))
	$main_panel/MB_icon/Label.text = "X " + str(PFab.player_MB)
	$username.text = PFab.player_name + "  Level " + str(PFab.player_data.level.Value)
	$arm_speed_label.text = str(PFab.player_data.arm_speed.Value)
	$exp.text = str(PFab.player_data.experience.Value) + " EXP"
	
	$left_hand/left_select_panel/LH_ItemList.clear()
	$right_hand/right_select_panel/RH_ItemList.clear()
	
	for item in PFab.inventory:
		$left_hand/left_select_panel/LH_ItemList.add_item(item.DisplayName, Globalvars.sprite_returner(item.ItemClass))		
		$right_hand/right_select_panel/RH_ItemList.add_item(item.DisplayName, Globalvars.sprite_returner(item.ItemClass))

#	if Globalvars.left_hand_item != null and Globalvars.right_hand_item != null:
#		$left_hand/icon.texture = Globalvars.sprite_returner(Globalvars.left_hand_item.ItemClass)
#		$right_hand/icon.texture = Globalvars.sprite_returner(Globalvars.right_hand_item.ItemClass)

func _on_Quit_pressed():
	get_tree().quit()

func _on_Start_pressed():
	print("  --Arm Speed Value: " + str(PFab.player_data.arm_speed.Value))
	if Globalvars.left_hand_item == null or Globalvars.right_hand_item == null:
		Signals.emit_signal("new_message", "Equip your bananas!")
		return
		
	get_tree().change_scene(Globalvars.game_levels[rand.randi_range(0, Globalvars.game_levels.size()-1)])

func _on_left_hand_gui_input(event):
	$left_hand/left_select_panel.show()
	pass

func _on_left_select_panel_mouse_exited():
	$left_hand/left_select_panel.hide()

func _on_left_shoulder_select_panel2_mouse_exited():
	$left_shoulder/left_shoulder_select_panel2.hide()

func _on_left_shoulder_mouse_entered():
	$left_shoulder/left_shoulder_select_panel2.show()

func _on_right_shoulder_select_panel_mouse_exited():
	$right_shoulder/right_shoulder_select_panel.hide()

func _on_right_shoulder_mouse_entered():
	$right_shoulder/right_shoulder_select_panel.show()

func _on_right_select_panel_mouse_exited():
	$right_hand/right_select_panel.hide()

func _on_right_hand_mouse_entered():
	$right_hand/right_select_panel.show()

func find_item(i):
	var item
	if i.to_lower() == "banana":
		item = Globalvars.banana_item
	if i.to_lower() == "apple":
		item = Globalvars.apple_item
	return item
	
func _on_LH_ItemList_item_selected(index):
	print("Player Main: LH Item Selected")
	var text = $left_hand/left_select_panel/LH_ItemList.get_item_text(index)
	print(text)
	Globalvars.left_hand_item = find_item(text)
	$left_hand/icon.texture = $left_hand/left_select_panel/LH_ItemList.get_item_icon(index)


func _on_RH_ItemList_item_selected(index):
	print("Player Main: RH Item Selected")
	var text = $right_hand/right_select_panel/RH_ItemList.get_item_text(index)
	print(text)
	Globalvars.right_hand_item = find_item(text)
	$right_hand/icon.texture = $right_hand/right_select_panel/RH_ItemList.get_item_icon(index)


func _on_RS_ItemList_item_selected(index):
	print("Player Main: RS Item Selected")
	var text = $right_shoulder/right_shoulder_select_panel/RS_ItemList.get_item_text(index)
	print(text)
	#Globalvars.right_hand_item = find_item(text)
	$right_hand/icon.texture = $right_shoulder/right_shoulder_select_panel/RS_ItemList.get_item_icon(index)


func _on_Shop_pressed():
	$Shop.update()
	$Shop.show()
	$Shop/AnimationPlayer.play("open")


func _on_inventory_pressed():
	$Inventory/AnimationPlayer.play("open")


func _on_MB_icon_pressed():
	$main_panel/MB_icon/Buy_MB_panel.show()

func _on_yes_mb_pressed():
	PFab.purchase_monkeybux(50)
	$main_panel/MB_icon/Buy_MB_panel.hide()
	#Enjin.Give_NFT(Enjin.player_wallet_address)

func _on_no_mb_pressed():
	$main_panel/MB_icon/Buy_MB_panel.hide()
