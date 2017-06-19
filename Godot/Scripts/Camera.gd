extends Camera2D

export(NodePath) var Target;
var mTargetPawn = null;

const ZoomAtMinSpeed = 300;
const ZoomAtMaxSpeed = 1500;

const AverageSpeedLerp = 0.025;
var mAverageSpeed = 0;
var mAverageVelocity = Vector2(0, 0);

const MinZoom = 0.4;
const MaxZoom = 0.9;
const ZoomLerp = 0.10;

const CameraOffset = Vector2(0, -0.1667);
const DefaultResolution = Vector2(1920, 1080);
const DefaultAspect = DefaultResolution.x / DefaultResolution.y;

# These are still not implemented, this was difficult.
const MaxAspect = 5760 / 1080; # 48:9
const MinAspect = 1024 / 768; # 4:3

var mDisplaySizeFactor = 1;

const MoveTiming = Vector2(0.25, 0.025);
const MoveLerp = 0.10;
#const MaxTargetDistance = 200;

func _ready():
	set_process(true);
	
	mTargetPawn = get_node(Target);




func _process(delta):
	var windowSize = get_viewport_rect().size;
	var windowAspect = windowSize.x / windowSize.y;
	
	# Window is wider than default
	if(windowAspect > DefaultAspect):
		mDisplaySizeFactor = DefaultResolution.y / windowSize.y;
	
	# Window is more narrow than default
	else:
		mDisplaySizeFactor = DefaultResolution.x / windowSize.x;
	
	if(mTargetPawn == null):
		return;
	
	mAverageVelocity.x = lerp(mAverageVelocity.x, mTargetPawn.get_velocity().x, AverageSpeedLerp);
	mAverageVelocity.y = lerp(mAverageVelocity.y, mTargetPawn.get_velocity().y, AverageSpeedLerp);
	mAverageSpeed = lerp(mAverageSpeed, mTargetPawn.get_speed(), AverageSpeedLerp);
	
	var targetPos = mTargetPawn.get_global_pos() + mAverageVelocity * MoveTiming + windowSize * get_zoom() * CameraOffset;
	var movePos = Vector2(lerp(get_global_pos().x, targetPos.x, MoveLerp), lerp(get_global_pos().y, targetPos.y, MoveLerp));
	#if((movePos - targetPos).length() > MaxTargetDistance):
	#	movePos = targetPos + (targetPos - movePos).clamped(MaxTargetDistance);
	
	set_global_pos(movePos);
	
	var zoomTarget = mDisplaySizeFactor * lerp(MinZoom, MaxZoom, clamp((mAverageSpeed - ZoomAtMinSpeed) / (ZoomAtMaxSpeed - ZoomAtMinSpeed), 0, 1));
	
	set_zoom(Vector2(lerp(get_zoom().x, zoomTarget, ZoomLerp), lerp(get_zoom().y, zoomTarget, ZoomLerp)));
