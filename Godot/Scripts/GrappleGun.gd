extends Node2D

export(PackedScene) var HookScene;

var mHookInstance = null;

const MaxHookDistance = 500;

func _input(event):
	if(event.is_action_pressed("fire_hook")):
		fire_hook();
		
	if(event.is_action_released("fire_hook")):
		release_hook();

func _ready():
	set_process_input(true);
	set_process(true);
	set_fixed_process(true);

func _process(delta):
	if(mHookInstance != null): 
		update();

func _fixed_process(delta):
	if(mHookInstance != null): 
		if((mHookInstance.get_global_pos() - get_global_pos()).length_squared() > MaxHookDistance * MaxHookDistance):
			release_hook();

func _draw():
	draw_set_transform_matrix(get_global_transform().inverse());
	if(mHookInstance != null): 
		draw_line(get_global_pos(), mHookInstance.get_global_pos(), Color(0.3, 0.2, 0.2), 5);

func fire_hook():
	if(mHookInstance != null):
		return;
	
	
	
	mHookInstance = HookScene.instance();
	get_tree().get_root().add_child(mHookInstance);
	mHookInstance.set_global_pos(get_global_pos());
	
	var traceDir = (get_global_mouse_pos() - get_global_pos()).normalized();
	var traceLength = MaxHookDistance;
	
	var traceStart = get_global_pos() + (traceDir * 15);
	var traceEnd = get_global_pos() + (traceDir * traceLength);
	
	var trace = get_world_2d().get_direct_space_state().intersect_ray(traceStart, traceEnd);
	
	mHookInstance.mTarget = trace.position if(!trace.empty()) else traceEnd + traceDir * 99999;
	

func release_hook():
	if(mHookInstance == null):
		return;
	mHookInstance.mReturnTarget = self;