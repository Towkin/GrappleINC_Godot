extends Node2D

const HookSpeed = 3000;
const ReturnSpeed = 3000;

var mTarget = Vector2();
var mHooked = false;

var mReturnTarget = null;

# Returns true if arrived.
func move_towards(point, speed):
	translate((point - get_global_pos()).clamped(speed));
	return ((get_global_pos() - point).length_squared() < 1);

func _ready():
	set_fixed_process(true);

func _fixed_process(delta):
	if(mReturnTarget != null):
		if(move_towards(mReturnTarget.get_global_pos(), ReturnSpeed * delta)):
			mReturnTarget.mHookInstance = null;
			mReturnTarget.update();
			self.free();
	elif(!mHooked):
		mHooked = move_towards(mTarget, HookSpeed * delta);
	