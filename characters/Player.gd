extends KinematicBody

export(NodePath) onready var turret = get_node(turret) as Spatial

var velocity = Vector3.ZERO
var speed = 15.0
var ground_acc = 15.0
var air_acc = 2
var jump_power = 20
var jumping = false
var health = 100
var max_health = 125
var guns = []
var gun_index = 0
var items = []
var current_gun = null
var bullet_num = 0



func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)	
	pass

func initialize(id):
	pass

		
func _process(delta):
	pass

		
func _physics_process(delta):
	#aim_crosshair()
	var movement = _get_movement()
	var _acc = 0
	
	if is_on_floor():
		_acc = ground_acc
	else:
		_acc = air_acc
		
	velocity.x = lerp(velocity.x, movement.x * speed, _acc * delta)
	velocity.z = lerp(velocity.z, movement.z * speed, _acc * delta)
	#print(is_on_floor())

	if !is_on_floor():
		velocity.y += Globalvars.GRAVITY * delta
	elif is_on_floor() and !jumping:
		#print("setting")
		velocity.y = 0

	if !$Tween.is_active():
		pass

	var snap = -get_floor_normal()
	if jumping:
		snap = Vector3.ZERO
	velocity.y = move_and_slide_with_snap(velocity, snap, Vector3.UP, true).y
			

func _unhandled_input(event):

	if event is InputEventMouseMotion:
		_handle_camera_rotation(event)
		
func _handle_camera_rotation(event):
	if Input.get_mouse_mode() ==Input.MOUSE_MODE_CAPTURED:
#		if Input.is_action_pressed("shift"):
#			$CameraBase.rotate_y(deg2rad(-event.relative.x) * Globalvars.camera_sensitivity)			
		rotate_y(deg2rad(-event.relative.x) * Globalvars.camera_sensitivity)
		$CameraBase.rotate_x(deg2rad(-event.relative.y) * Globalvars.camera_sensitivity)
		$CameraBase.rotation.x = clamp($CameraBase.rotation.x, deg2rad(Globalvars.MIN_CAMERA_ANGLE), deg2rad(Globalvars.MAX_CAMERA_ANGLE))

func _get_movement():
	var dir = Vector3.DOWN
	
	jumping = false
	
	if Input.is_action_pressed("forward"):
		dir -= transform.basis.z
		
	if Input.is_action_pressed("backward"):
		dir += transform.basis.z
		
	if Input.is_action_pressed("left"):
		dir -= transform.basis.x
		
	if Input.is_action_pressed("right"):
		dir += transform.basis.x		

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_power
		jumping = true
		
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		
	if Input.is_action_just_pressed("shift"):
		do_action()
		#PFab.get_inventory()
#	if Input.is_action_just_pressed("right_mouse"):
#		$Tween.interpolate_property($Turret/Camera, "fov", 70, 30, .1)
#		$Tween.start()
#	if Input.is_action_just_released("right_mouse"):
#		$Tween.interpolate_property($Turret/Camera, "fov", $Turret/Camera.fov, 70, .1)
#		$Tween.start()
	
	return dir.normalized()

func do_action():
	$CameraBase/Action_ray.force_raycast_update()
	if $CameraBase/Action_ray.is_colliding():
		var c = $CameraBase/Action_ray.get_collider()
		for item in PFab.inventory:
			if c.name == item.ItemId:
				print("you have the item")
				return
		print("you dont have the item")
			
#func aim_crosshair():
#	var point = $Turret/Camera.unproject_position($Turret/targeting_ray.get_collision_point())
#	$crosshair.set_global_position(point)
#	#also get info on object
#	if $Turret/targeting_ray.is_colliding():
#		var c = $Turret/targeting_ray.get_collider()
#
#		if c.is_in_group("Eye") and c.visible and global_transform.origin.distance_to($Turret/targeting_ray.get_collision_point()) < 5:
#			$info.text = "Broken Bob Eye"
#			$info.visible = true
#
#		elif c.is_in_group("Keycard") and c.visible and global_transform.origin.distance_to($Turret/targeting_ray.get_collision_point()) < 5:
#			$info.text = "Keycard"
#			$info.visible = true
#
#		elif c.is_in_group("Keypad") and c.visible and global_transform.origin.distance_to($Turret/targeting_ray.get_collision_point()) < 5:
#			$info.text = "Key Needed"
#			$info.visible = true
#		else:
#			$info.visible = false
