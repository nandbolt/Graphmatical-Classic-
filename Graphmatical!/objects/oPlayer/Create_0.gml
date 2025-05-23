/// @desc	Init player

// States
canMove = true;
currentState = HumanState.NORMAL;

// Rigid body
rbInit();

// IKH
ikhInit();

// Inputs
inputMove = new Vector2();
inputJump = false;
inputJumpPressed = false;
inputCrouch = false;

// Movement
runStrength = 0.15;

// Jumping
jumpForce = new Vector2();
jumpStrength = 3;
driftStrength = 0.05;
jumpBuffer = 10;
jumpBufferCounter = 0;
coyoteBuffer = 10;
coyoteBufferCounter = 0;
smallJumpStrength = 0.1;
normalGravity = gravityStrength;

// Resistances
runGroundConstant = 0.1;
slideGroundConstant = 0.02;

// Editor
inputEditorPressed = false;
currentEditor = oPauser;

// Riding
ride = noone;

// Launcher
launcher = noone;

#region Functions

/// @func	jump();
jump = function()
{
	// Calculate jump
	jumpForce.x = 0;
	jumpForce.y = -jumpStrength;
	
	// Apply jump
	velocity.x += jumpForce.x;
	velocity.y += jumpForce.y;
	
	// Reset counters
	jumpBufferCounter = 0;
	coyoteBufferCounter = 0;
	grounded = false;
	onGraph = false;
	
	// Jump sfx
	audio_play_sound(sfxJump, 2, false);
}

/// @func	resetMoveInputs();
resetMoveInputs = function()
{
	inputMove.x = 0;
	inputMove.y = 0;
	inputJump = false;
	inputJumpPressed = false;
	inputCrouch = false;
}

/// @func	die();
die = function()
{
	// World scope
	with (oLevel)
	{
		// Set respawn timer
		alarm[0] = 30;
	}

	// Hurt sound
	audio_play_sound(sfxHurt, 2, false);
	
	// Emit a particle from every part of the body
	emitBodyParticles();

	// Destroy self
	instance_destroy();
}

/// @func	emitBodyParticles();
emitBodyParticles = function()
{
	// Emit a particle from every part of the body
	with (oParticleManager)
	{
		part_particles_create(partSystem, other.neckPosition.x, other.neckPosition.y - 2, partTypeDust, 1);				// Head
		part_particles_create(partSystem, other.neckPosition.x, other.neckPosition.y + 2, partTypeDust, 1);				// Body
		part_particles_create(partSystem, other.leftArm.elbowJoint.x, other.leftArm.elbowJoint.y, partTypeDust, 1);		// Left Elbow
		part_particles_create(partSystem, other.rightArm.elbowJoint.x, other.rightArm.elbowJoint.y, partTypeDust, 1);	// Right Elbow
		part_particles_create(partSystem, other.leftLeg.elbowJoint.x, other.leftLeg.elbowJoint.y, partTypeDust, 1);		// Left Knee
		part_particles_create(partSystem, other.rightLeg.elbowJoint.x, other.rightLeg.elbowJoint.y, partTypeDust, 1);	// Right Knee
	}
}

///	@func	toggleRide(ride);
///	@param	{Inst.Id}	ride	Your potential new ride.
///	@desc	Transitions the player to the riding state.
toggleRide = function(_ride)
{
	if (currentState == HumanState.RIDE)
	{
		// Get off ride
		currentState = HumanState.NORMAL;
		ride = noone;
		gravityStrength = normalGravity;
	}
	else
	{
		// Get on ride
		currentState = HumanState.RIDE;
		ride = _ride;
		gravityStrength = 0;
	}
}

#endregion

// Start spawn timer
alarm[0] = 60;