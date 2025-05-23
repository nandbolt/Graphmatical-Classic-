// States
levelComplete = false;
globalGraphing = false;
globalTiling = false;

// Layers
backgroundLayer = layer_get_id("Background");
collisionLayer = layer_get_id("CollisionTiles");

// Spawning
spawnPoint = instance_create_layer(24, 1064, "Instances", oSpawnFlag);
spawnPortal = noone;

// Background shader
uTime = shader_get_uniform(shdrWorleyNoise, "u_time");
uResolution = shader_get_uniform(shdrWorleyNoise, "u_resolution");
uOffset = shader_get_uniform(shdrWorleyNoise, "u_offset");

// Timer
startTime = 0;
endTime = 0;

// Physics
boxEngine = noone;

// Balls
ballsDestroyed = 0;
totalBalls = 0;

// Cubes
cubesCollected = 0;
totalCubes = 0;

#region Functions

/// @func	moveSpawnPoint({real} x, {real} y);
moveSpawnPoint = function(_x=24,_y=1064)
{
	spawnPoint.x = _x;
	spawnPoint.y = _y;
	if (instance_exists(spawnPortal))
	{
		spawnPortal.x = _x;
		spawnPortal.y = _y;
	}
}

/// @func respawnPlayer();
respawnPlayer = function()
{
	// Player
	instance_create_layer(spawnPoint.x, spawnPoint.y, "ForegroundInstances", oPlayer);
}

/// @func	completeLevel();
completeLevel = function()
{
	if (!levelComplete)
	{
		levelComplete = true;
		endTime = current_time / 1000 - startTime;
		
		// Create end menu
		instance_create_layer(0, 0, "Instances", oEndMenu);
		
		// Destroy player
		with (oPlayer)
		{
			emitBodyParticles();
			instance_destroy();
		}
	}
}

#endregion

// Hide collision layer
layer_set_visible(collisionLayer, false);

// Set background shader
layer_script_begin(backgroundLayer, layerWorleyShaderStart);
layer_script_end(backgroundLayer, layerWorleyShaderEnd);

// Setup spawn portal
if (room != rHubLevel && (room != rTutorialLevel || oGameManager.tutorialComplete))
{
	spawnPortal = instance_create_layer(spawnPoint.x, spawnPoint.y, "Instances", oPortal);
	with (spawnPortal)
	{
		// Hub
		nextLevel = rHubLevel;
		name = "Hub";
	}
}

// Create box engine
boxEngine = instance_create_layer(0, 0, "Instances", be_oBoxEngine);

// Init scene
cgTiles = new BETileContactGen();
cgBoxes = new BEBoxContactGen();
fgGravity = new BEGravityForceGen();
with (boxEngine)
{
	array_push(contactGens, other.cgTiles);
	array_push(contactGens, other.cgBoxes);
}