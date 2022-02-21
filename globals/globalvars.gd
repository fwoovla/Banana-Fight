extends Node


const MAX_CAMERA_ANGLE = 60
const MIN_CAMERA_ANGLE = -60

var camera_sensitivity = .2

var GRAVITY = -60

onready var screen_width = get_viewport().size.x
onready var screen_height = get_viewport().size.y

var left_hand_item
var right_hand_item

var is_paused = false

var welcome_sent = false
var show_new_level = false

var banana_item = preload("res://characters/items/banana.tscn")
var apple_item = preload("res://characters/items/Apple.tscn")

# player stats
var arm_speed = 1

var game_levels = ["res://levels/jungle/jungle1.tscn", "res://levels/jungle/jungle2.tscn"]

func sprite_returner(id :String):
	#print("Global: Fetching Sprite")
	return load("res://assets/sprites/" + id + ".png")
