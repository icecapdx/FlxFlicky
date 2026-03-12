package meta.state;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;
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

    var noclip:Bool = false;
    var _savedGravity:Float = 0;

    override public function create()
    {
        setupCameras();

        // stage loading
		// TODO: Move to a stage class & have shit automatically handled there
		// stage bg
		var bg:FlxSprite = new FlxSprite();
		//bg.loadGraphic(Util.getImage("tilemaps/ssw_test_zone/background"));
		//add(bg);
        /*
        // Old tiled loading
        // background tiles
        backgroundMap = new FlxTilemap();
        backgroundMap.loadMapFromCSV(
            "assets/data/stages/simplemap_Background Layers.csv",
            "assets/images/tilemaps/ssw_test_zone/general_0.png", 16, 16);
        add(backgroundMap);
        // collision tiles
        collisionMap = new FlxTilemap();
        collisionMap.loadMapFromCSV(
            "assets/data/stages/simplemap_Collision Layers.csv",
            "assets/images/tilemaps/ssw_test_zone/general_0.png", 16, 16);
        collisionMap.setTileProperties(1, FlxDirectionFlags.ANY);
        add(collisionMap);
        // slope tiles
        // TODO: ACTUALLY HANDLE SLOPES :(
        // also idk why but they don't load
        var rawCSV = sys.io.File.getContent("assets/data/stages/simplemap_Slope Layers.csv");
        var fixedCSV = rawCSV.split("-1").join("0");
        slopeMap = new FlxTilemap();
        slopeMap.loadMapFromCSV(
            fixedCSV,
            "assets/images/tilemaps/ssw_test_zone/general_0.png", 16, 16);
        slopeMap.setTileProperties(1, FlxDirectionFlags.ANY);
        add(slopeMap);
        */
        // Updated ogmo3 loading
        var loader = new FlxOgmo3Loader(
            "assets/data/flickylevels.ogmo",
            "assets/data/stages/testlevel.json"
        );
        // background tiles
        backgroundMap = loader.loadTilemap(
            "assets/images/tilemaps/ssw_test_zone/general_0.png",
            "BG Layer"
        );
        add(backgroundMap);
        // collision tiles
        collisionMap = loader.loadTilemap(
            "assets/images/tilemaps/ssw_test_zone/general_0.png",
            "Tile Layer"
        );
        collisionMap.setTileProperties(1, FlxDirectionFlags.ANY);
        add(collisionMap);
        slopeMap = loader.loadTilemap(
            "assets/images/tilemaps/ssw_test_zone/general_0.png",
            "Slope Layer"
        );
        slopeMap.setTileProperties(1, FlxDirectionFlags.ANY);
        add(slopeMap);

        loader.loadEntities(entity -> {
            switch (entity.name)
            {
                case "Player":
                    sawnick = new Sonic(entity.x, entity.y);
                    sawnick.collisionMap = collisionMap;
                    add(sawnick);
            }
        }, "Entity Layer");

        _savedGravity = sawnick.stats.gravity;

        camGame.follow(sawnick, FlxCameraFollowStyle.LOCKON, 0.1);
        camGame.setScrollBoundsRect(0, 0, collisionMap.width, collisionMap.height, true);

        Discord.changePresence("I'm sonic'ing it...");

        super.create();
    }

    function setupCameras():Void
    {
        camGame = new FlxCamera(0, 0, FlxG.width, FlxG.height);
        camHUD  = new FlxCamera(0, 0, FlxG.width, FlxG.height);
        camHUD.bgColor.alpha = 0;

        FlxG.cameras.reset(camGame);
        FlxG.cameras.add(camHUD);
        camGame.zoom = 327; // haxeflixel bs, I have no idea why I gotta make it like this.

        FlxCamera.defaultCameras = [camGame];
    }

    override public function update(elapsed:Float)
    {
        // debug shin digz
        if (FlxG.keys.justPressed.Q)
        {
            noclip = !noclip;
            if (noclip)
            {
                _savedGravity = sawnick.stats.gravity;
                sawnick.stats.gravity = 0;
                sawnick.collisionMap = null;
                sawnick.isGrounded = false;
                sawnick.isRolling = false;
                sawnick.isBall = false;
                sawnick.isJumping = false;
                sawnick.xSpeed = 0;
                sawnick.ySpeed = 0;
            }
            else
            {
                sawnick.stats.gravity = _savedGravity;
                sawnick.collisionMap = collisionMap;
            }
        }

        if (FlxG.keys.justPressed.R)
            Main.switchState(this, new PlayState());

        if (noclip)
        {
            var speed:Float = FlxG.keys.pressed.SHIFT ? 600 : 300;
            var dx:Float = (FlxG.keys.pressed.RIGHT ? 1 : 0) - (FlxG.keys.pressed.LEFT ? 1 : 0);
            var dy:Float = (FlxG.keys.pressed.DOWN ? 1 : 0) - (FlxG.keys.pressed.UP ? 1 : 0);
            sawnick.xSpeed = dx * speed;
            sawnick.ySpeed = dy * speed;
            sawnick.isGrounded = false;
        }

        super.update(elapsed);
    }
}
