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
export(NodePath) var PlayerGrappleGunPath;

onready var mPlayerSprite = get_node(PlayerSpritePath);
onready var mGrappleGun = get_node(PlayerGrappleGunPath);

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
		if(get_velocity().y < 120):
			mPlayerSprite.set_animation("Ascend");
		else:
			mPlayerSprite.set_animation("Descend");
	
	
	
	

var mMoveSteps = 0;
func _fixed_process(delta):
	mMoveSteps = 0;
	
	set_speed(get_speed() * (1 - LinearDamping * delta));
	
	var velocityAdd = Vector2(0, 0);
	var curVelocity = get_velocity();
	
	# Player horisontal acceleration
	if(abs(curVelocity.x) <= MaxRunSpeed || sign(curVelocity.x) != sign(mHorizontalAxis)):
		var control = 1.0 if mIsGrounded else (AirControl if sign(curVelocity.x) == sign(mHorizontalAxis) else AirControl * 2.0);
		
		velocityAdd.x += clamp(curVelocity.x + mHorizontalAxis * Acceleration * control * delta, min(curVelocity.x, -MaxRunSpeed), max(curVelocity.x, MaxRunSpeed)) - curVelocity.x;
	
	# Gravity and jumping
	velocityAdd += Gravity * delta;
	velocityAdd.y -= JumpForce if mJumpAction && mIsGrounded else 0;
	mJumpAction = false;
	
	if(mGrappleGun.mHookInstance != null && mGrappleGun.mHookInstance.mHooked):
		var hookOffset = mGrappleGun.mHookInstance.get_global_pos() - get_global_pos();
		var hookDistance = hookOffset.length();
		var hookDirection = hookOffset / hookDistance;
		
		var pull = Input.is_action_pressed("pull_hook");
		
		#var MinNormalSpeed = 0;
		var MinNormalSpeed = 7.5 if pull else 0;
		var MaxNormalSpeed = 50;
		
		var normalForce = clamp(get_velocity().dot(hookDirection) * -1, MinNormalSpeed, MaxNormalSpeed);
		
		#var NormalForceFactor = 650;
		var NormalForceFactor = 650;
		var distanceFactor = lerp(0.15, 0.65, hookDistance / mGrappleGun.MaxHookDistance);
		
		velocityAdd += hookDirection * (normalForce * distanceFactor * NormalForceFactor * delta);
	
	set_velocity(curVelocity + velocityAdd);
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

const TestDepth = 4;
func player_ground_test():
	return test_move(Vector2(0, TestDepth));

	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	