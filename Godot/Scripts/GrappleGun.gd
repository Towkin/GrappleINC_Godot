extends Node2D

export(PackedScene) var HookScene;

var mHookInstance = null;
var mUseMouse = true;

var mAimDirection = Vector2(1, 0);
var mAimTarget = Vector2(0, 0);
var mValidTarget = false;
const MaxHookDistance = 400;

func _input(event):
	if(event.type == InputEvent.JOYSTICK_MOTION):
		mUseMouse = false;
	elif(event.type == InputEvent.MOUSE_MOTION):
		mUseMouse = true;
	elif(event.is_action_pressed("fire_hook")):
		fire_hook();
	elif(event.is_action_released("fire_hook")):
		release_hook();

func _ready():
	set_process_input(true);
	set_process(true);
	set_fixed_process(true);

func _process(delta):
	if(mUseMouse):
		mAimDirection = get_global_mouse_pos() - get_global_pos();
	else:
		var newDir = Vector2(Input.get_joy_axis(0, JOY_AXIS_2), Input.get_joy_axis(0, JOY_AXIS_3));
		if(newDir.length() > 0.5):
			mAimDirection = newDir;
		
	update();

func _fixed_process(delta):
	set_global_rot(mAimDirection.angle());
	
	var traceDir = mAimDirection.normalized();
	var traceLength = MaxHookDistance;
	
	var traceStart = get_global_pos();
	var traceEnd = get_global_pos() + (traceDir * traceLength);
	
	var trace = get_world_2d().get_direct_space_state().intersect_ray(traceStart, traceEnd, [], 1, 1);
	mValidTarget = !trace.empty();
	mAimTarget = (trace.position if(mValidTarget) else traceEnd);
	
	if(mHookInstance != null): 
		if((mHookInstance.get_global_pos() - get_global_pos()).length_squared() > MaxHookDistance * MaxHookDistance):
			release_hook();

const HitColor = Color(0.3, 0.6, 0.3, 0.4);
const MissColor = Color(0.6, 0.3, 0.3, 0.3);

func _draw():
	
	draw_set_transform_matrix(get_global_transform().inverse());
	draw_line(get_global_pos(), mAimTarget, HitColor if mValidTarget else MissColor, 2);
	
	if(mHookInstance != null): 
		draw_line(get_global_pos(), mHookInstance.get_global_pos(), Color(0.3, 0.2, 0.2), 5);

func fire_hook():
	if(mHookInstance != null):
		return;
	
	
	
	mHookInstance = HookScene.instance();
	get_tree().get_root().add_child(mHookInstance);
	mHookInstance.set_global_pos(get_global_pos());
	
	mHookInstance.mTarget = mAimTarget + (Vector2(0,0) if mValidTarget else mAimDirection * 99999);
	

func release_hook():
	if(mHookInstance == null):
		return;
	mHookInstance.mReturnTarget = self;