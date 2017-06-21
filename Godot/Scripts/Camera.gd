extends Camera2D

export(NodePath) var Target;
var mTargetPawn = null;


const AverageSpeedLerp = 0.025;
var mAverageSpeed = 0;
var mAverageVelocity = Vector2(0, 0);

# The minimum and maximum zoom amount.
const MinZoom = 0.4;
const MaxZoom = 0.7;
const ZoomLerp = 0.10;
const MinZoomStep = 0.001;

# Zooming out starts at MinSpeedZoom, and stops at MaxSpeedZoom.
const MinSpeedZoom = 500;
const MaxSpeedZoom = 2500;

# The future prediciton timing on x and y axis.
const MoveTiming = Vector2(0.35, 0.075);
const MoveLerp = 0.10;
const MinMoveStep = 1;


const CameraOffset = Vector2(0, -0.1667);
const DefaultResolution = Vector2(1920, 1080);
const DefaultAspect = DefaultResolution.x / DefaultResolution.y;

# These are still not implemented, this was difficult.
const MaxAspect = 5760 / 1080; # 48:9
const MinAspect = 1024 / 768; # 4:3

var mDisplaySizeFactor = 1;


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
	
	mAverageSpeed = lerp(mAverageSpeed, mTargetPawn.get_speed(), AverageSpeedLerp);
	
	var velocityOffset = mTargetPawn.get_velocity() - mAverageVelocity;
	if((velocityOffset.length() * AverageSpeedLerp) < MinMoveStep):
		mAverageVelocity += velocityOffset.clamped(MinMoveStep);
	else:
		mAverageVelocity += velocityOffset * AverageSpeedLerp;
	
	var positionOffset = windowSize * get_zoom() * CameraOffset;
	var moveOffset = mAverageVelocity * MoveTiming;
	
	set_global_pos(mTargetPawn.get_global_pos() + positionOffset + moveOffset);
	
	var zoomTarget = mDisplaySizeFactor * lerp(MinZoom, MaxZoom, clamp((mAverageSpeed - MinSpeedZoom) / (MaxSpeedZoom - MinSpeedZoom), 0, 1));
	var zoomOffset = zoomTarget - get_zoom().x;
	
	if(abs(zoomOffset) * ZoomLerp < MinZoomStep):
		zoomOffset = clamp(zoomOffset, - MinZoomStep, MinZoomStep);
	else:
		zoomOffset *= ZoomLerp;
	
	set_zoom(Vector2(get_zoom().x + zoomOffset, get_zoom().y + zoomOffset));



