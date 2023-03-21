extends CharacterBody2D


@export var MAX_SPEED = 500.0
@export var ACCELERATION = 10.0
@export var DECCELERATION = 100.0
@export var DASH_SPEED = 1000
@export var DASH_TIME = 0.5
var direction := Vector2()
var dash := false
var SPEED := 0.0
var flagDash = false

enum state_type {Idle, Accelerate, Deccelerate, Max_Speed, Dash}
var state := state_type.Idle
var state_prec := state_type.Idle



# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta):
	direction.x = Input.get_axis("move_left", "move_right")
	direction.y = Input.get_axis("move_up", "move_down")
	direction = direction.normalized()
	
	dash = Input.is_action_just_pressed("dash")
	
	#Tentative de MAE
	#Faudra implémenter un état de décéllération/accélération quand on change pour la direction opposée
	match state:

		state_type.Idle:
			if (direction):
				if direction.x:
					velocity.x = move_toward(velocity.x, direction.x*MAX_SPEED, ACCELERATION)
				if direction.y:
					velocity.y = move_toward(velocity.y, direction.y*MAX_SPEED, ACCELERATION)

				state = state_type.Accelerate
		
		state_type.Accelerate:
			if direction.x:
				velocity.x = move_toward(velocity.x, direction.x*MAX_SPEED, ACCELERATION)
			if direction.y:
				velocity.y = move_toward(velocity.y, direction.y*MAX_SPEED, ACCELERATION)
			
			if (!direction.x && !direction.y):
				state = state_type.Deccelerate	
			if(velocity.length() >= MAX_SPEED):
				state = state_type.Max_Speed
			if(dash):
				state_prec = state
				state = state_type.Dash
				flagDash = true
				
		state_type.Deccelerate:
			velocity.x = move_toward(velocity.x, 0, DECCELERATION)
			velocity.y = move_toward(velocity.y, 0, DECCELERATION)
			
			if(velocity.length() == 0):
				state = state_type.Idle
			if(dash):
				state_prec = state
				state = state_type.Dash
				flagDash = true
				
			if (direction.x || direction.y):
				state = state_type.Accelerate
				
		state_type.Max_Speed:
			if (!direction.x && !direction.y):
				state = state_type.Deccelerate
			else:
				velocity.x = direction.x*MAX_SPEED
				velocity.y = direction.y*MAX_SPEED
			
			if(dash):
				state_prec = state
				state = state_type.Dash
				flagDash = true

				
		state_type.Dash:
			#Traitement au démarrage du dash
			if(flagDash): #On utilise ce flag pour ne pas créer des timers en boucle
				position.x += direction.x*DASH_SPEED
				position.y += direction.y*DASH_SPEED
				set_collision_mask_value(1, false)
				flagDash = false
				await get_tree().create_timer(DASH_TIME).timeout
				#Post traitement du dash
				set_collision_mask_value(1, true)
				if(state_prec == state_type.Accelerate || state_prec == state_type.Max_Speed):
					velocity.x = direction.x*MAX_SPEED
					velocity.y = direction.y*MAX_SPEED
					state = state_type.Max_Speed
				else:
					velocity.x = 0
					velocity.y = 0
					state = state_type.Idle
				
			
			
			
		_:
			print("Y'a une couille dans la MAE")
			state = state_type.Idle
	
	
	
	
	
	
	
	
#	if(dash):
#		set_collision_layer_value(1, false)
#		set_collision_mask_value(1, false)
#		SPEED *= 2
#
#
#
#	if direction.x:
#		velocity.x = move_toward(velocity.x, direction.x*MAX_SPEED, ACCELERATION)
#	else:
#		velocity.x = move_toward(velocity.x, 0, DECCELERATION)
#
#	if direction.y:
#		velocity.y = move_toward(velocity.y, direction.y*MAX_SPEED, ACCELERATION)
#		print(velocity.y)
#	else:
#		velocity.y = move_toward(velocity.y, 0, DECCELERATION)

	move_and_slide()
