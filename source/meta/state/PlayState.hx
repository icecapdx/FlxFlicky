package meta.state;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.tile.FlxTilemap;
import flixel.util.FlxDirectionFlags;
import gameObjects.Sonic;
import meta.data.dependency.Discord;

class PlayState extends FlxState
{
    var backgroundMap:FlxTilemap;
    var collisionMap:FlxTilemap;
    var slopeMap:FlxTilemap;
	var sawnick:Sonic;
	var camGame:FlxCamera;
	var camHUD:FlxCamera;

	override public function create()
	{
		setupCameras();

		// stage loading
		// TODO: Move to a stage class & have shit automatically handled there
		// stage bg
		var bg:FlxSprite = new FlxSprite();
		//bg.loadGraphic(Util.getImage("tilemaps/ssw_test_zone/background"));
		//add(bg);
		// background tiles
		backgroundMap = new FlxTilemap();
        backgroundMap.loadMapFromCSV("assets/data/stages/simplemap_Background Layers.csv", "assets/images/tilemaps/ssw_test_zone/general_0.png", 16, 16);
        add(backgroundMap);

		// collision tiles
        collisionMap = new FlxTilemap();
        collisionMap.loadMapFromCSV("assets/data/stages/simplemap_Collision Layers.csv", "assets/images/tilemaps/ssw_test_zone/general_0.png", 16, 16);
        collisionMap.setTileProperties(1, FlxDirectionFlags.ANY);
        add(collisionMap);

		// slope tiles
		// TODO: ACTUALLY HANDLE SLOPES :(
		// also idk why but they don't load
        slopeMap = new FlxTilemap();
        slopeMap.loadMapFromCSV("assets/data/stages/simplemap_Slope Layers.csv", "assets/images/tilemaps/ssw_test_zone/general_0.png", 16, 16);
        add(slopeMap);

		// rpc shit for funsies, ignore
		final curStateName:String = Type.getClassName(Type.getClass(FlxG.state));
		Discord.changePresence('wait...itd be funny if I just... ' + curStateName);

		super.create();
	}

	function setupCameras():Void {
        camGame = new FlxCamera(0, 0, FlxG.width, FlxG.height);
    	camHUD = new FlxCamera(0, 0, FlxG.width, FlxG.height);
	    camHUD.bgColor.alpha = 0;

        FlxG.cameras.reset(camGame);
        FlxG.cameras.add(camHUD);
		camGame.zoom = 327; // haxeflixel bs, I have no idea why I gotta make it like this.

        FlxCamera.defaultCameras = [camGame];
    }

	override public function update(elapsed:Float)
	{
		// debug shin digz
		if (FlxG.keys.justPressed.R)
			Main.switchState(this, new PlayState());

		super.update(elapsed);
	}
}
