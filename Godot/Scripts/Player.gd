extends KinematicBody2D


export(float) var MaxRunSpeed = 600.0;
export(float) var MaxSpeed = 5000.0;
export(float) var Acceleration = 4000.0;
export(float) var JumpForce = 400;
export(float) var AirControl = 0.25;

export(float) var GroundFriction = 3000.0;
export(float) var Restitution = 0.2;
export(float) var MinBounceSpeed = 800;
export(float) var MaxBounceSpeed = 2000;

export(float) var LinearDamping = 0.05;
export(Vector2) var Gravity = Vector2(0, 982);

export(NodePath) var PlayerSpritePath;

onready var mPlayerSprite = get_node(PlayerSpritePath);

var mIsGrounded = false;
var mJumpAction = false;
var mHorizontalAxis = 0;

var mSpeed = 0.0;
var mDirection = Vector2(1, 0);
var mFaceRight = true;

var mLastAcceleration = Vector2(0, 0);
onready var mCheckpointLocation = get_global_pos();

func get_speed():
	return mSpeed;
func get_direction():
	return mDirection;
func get_velocity():
	return get_speed() * get_direction();

func set_direction(newDirection):
	if(newDirection.length_squared() > 0.01):
		mDirection = newDirection.normalized();
		if(newDirection.x > 0.05):
			mFaceRight = true;
		elif(newDirection.x < -0.05):
			mFaceRight = false;
func set_speed(newSpeed):
	mSpeed = min(abs(newSpeed), MaxSpeed);
	if(newSpeed < 0):
		mDirection *= -1;
		mFaceRight = !mFaceRight;
func set_velocity(newVelocity):
	set_speed(newVelocity.length());
	set_direction(newVelocity);


func _ready():
	set_process_input(true);
	set_process(true);
	set_fixed_process(true);
	

func _input(event):
	if(event.is_action_pressed("move_jump")):
		mJumpAction = true;
	
	if(event.is_action_pressed("give_up")):
		get_tree().reload_current_scene();
	
	if(event.is_action_pressed("respawn")):
		set_global_pos(mCheckpointLocation);
	
	if(event.is_action_pressed("ui_cancel")):
		get_tree().quit();

func _process(delta):
	mHorizontalAxis = (1 if Input.is_action_pressed("move_right") else 0) - (1 if Input.is_action_pressed("move_left") else 0);
	
	mPlayerSprite.set_flip_h(!mFaceRight);
	
	if(mIsGrounded):
		if(mSpeed > 10):
			if(mDirection.dot(Vector2(mHorizontalAxis, 0)) <= 0):
				mPlayerSprite.set_animation("RunEnd");
			else:
				mPlayerSprite.set_animation("RunCycle");
		else:
			mPlayerSprite.set_animation("IdlePose");
	else:
		if(get_velocity().y < 0):
			mPlayerSprite.set_animation("Ascend");
		else:
			mPlayerSprite.set_animation("Descend");
	
	
	
	

var mMoveSteps = 0;
func _fixed_process(delta):
	mMoveSteps = 0;
	
	set_speed(get_speed() * (1 - LinearDamping * delta));
	
	var newVelocity = get_velocity();
	
	# Player acceleration
	if(abs(newVelocity.x) <= MaxRunSpeed || sign(newVelocity.x) != sign(mHorizontalAxis)):
		newVelocity.x = clamp(newVelocity.x + mHorizontalAxis * Acceleration * (1.0 if mIsGrounded else (AirControl if sign(newVelocity.x) == sign(mHorizontalAxis) else AirControl * 2.0)) * delta, -MaxRunSpeed, MaxRunSpeed)
	
	# Gravity and jumping
	newVelocity += Gravity * delta;
	newVelocity.y -= JumpForce if mJumpAction && mIsGrounded else 0;
	mJumpAction = false;
	
	
	set_velocity(newVelocity);
	player_move(get_velocity() * delta);
	mIsGrounded = player_ground_test();
	
	# Friction
	if(mIsGrounded):
		set_speed(get_speed() - min(get_speed(), (1 - abs(mHorizontalAxis)) * GroundFriction * delta));
	


func player_move(moveVector):
	if(mMoveSteps > 10):
		return;
	mMoveSteps += 1;
	
	var moveRemainder = move(moveVector);
	if(is_colliding()):
		var surfaceNormal = get_collision_normal();
		
		var velocityFactor = get_velocity().dot(surfaceNormal);
		var remainderFactor = moveRemainder.dot(surfaceNormal);
		
		# Only multiply with restitution if the hit was faster than the MinBounceSpeed towards the normal of the surface.
		if(abs(velocityFactor) > MinBounceSpeed):
			velocityFactor *= (1 + Restitution);
			remainderFactor *= (1 + Restitution);
		
		set_velocity(get_velocity() - surfaceNormal * velocityFactor);
		
		if(abs(remainderFactor) > 0):
			player_move(moveRemainder - surfaceNormal * remainderFactor);

func player_ground_test():
	return test_move(Vector2(0, 1));

	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	