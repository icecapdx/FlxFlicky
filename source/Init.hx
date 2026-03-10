package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.input.keyboard.FlxKey;
import meta.data.dependency.Discord;
import meta.state.PlayState;

enum SettingTypes
{
	Checkmark;
	Selector;
}

/*
    The initialization class/state!
    This handles setting things before the game even runs!
    Like api stuff, the TRUE first state, settings, etc etc!
    We also hold our api keys, discord id, etc etc here!
*/
class Init extends FlxState {

    // API STUFF!
	private inline static final DISCORD_RPC_ID:String = "1480436097795494021"; // change this to ur app id!

    // your game settings!
    public static var FORCED = 'forced';
	public static var NOT_FORCED = 'not forced';
    public static var gameSettings:Map<String, Dynamic> = [
		'Auto Pause' => [true, Checkmark, '', NOT_FORCED],
		'FPS Counter' => [true, Checkmark, 'Whether to display the FPS counter.', NOT_FORCED],
		'Memory Counter' => [
			true,
			Checkmark,
			'Whether to display approximately how much memory is being used.',
			NOT_FORCED
		],
		'Debug Info' => [false, Checkmark, 'Whether to display information like your game state.', NOT_FORCED],
		'Display Accuracy' => [true, Checkmark, 'Whether to display your accuracy on screen.', NOT_FORCED],
		'Disable Antialiasing' => [
			false,
			Checkmark,
			'Whether to disable Anti-aliasing. Helps improve performance in FPS.',
			NOT_FORCED
		],
		"Framerate Cap" => [120, Selector, 'Define your maximum FPS.', NOT_FORCED, ['']],
	];

    // The controls for the game! Change this if needed :)
    public static var gameControls:Map<String, Dynamic> = [
		'UP' => [[FlxKey.UP, W], 2],
		'DOWN' => [[FlxKey.DOWN, S], 1],
		'LEFT' => [[FlxKey.LEFT, A], 0],
		'RIGHT' => [[FlxKey.RIGHT, D], 3],
		'ACCEPT' => [[FlxKey.SPACE, Z, FlxKey.ENTER], 4],
		'BACK' => [[FlxKey.BACKSPACE, X, FlxKey.ESCAPE], 5],
		'PAUSE' => [[FlxKey.ENTER, P], 6],
		'RESET' => [[R, null], 7]
	];

    // A map for our settings
    public static var trueSettings:Map<String, Dynamic> = [];

    override public function create():Void
    {
        // we bind our save here first so we can actually save and load settings & anything else we need
        FlxG.save.bind("A-HaxeFlixel-Game", "dotfla"); // CHANGE TO WHAT UR GAME NAME IS AND THE STUDIO/DEV NAME OR WHATEVER

        // We have 2 custom functions here for loading our custom settings & controls if we have any!
		loadSettings();
		loadControls();

		FlxG.fixedTimestep = false; // This ensures that the game is not tied to the

		// starts discord rpc unless we're on html5 or switch
		#if (!html5 || !switch)
		Discord.initializeRPC(Init.DISCORD_RPC_ID);
		trace("discord rpc maybe??");
		#end

		gotoGameState();
    }

    private function gotoGameState():Void
    {
        Main.switchState(this, new PlayState());
    }

    public static function loadSettings():Void
    {
        for (setting in gameSettings.keys())
			trueSettings.set(setting, gameSettings.get(setting)[0]);

        		if (FlxG.save.data.settings != null)
		{
			var settingsMap:Map<String, Dynamic> = FlxG.save.data.settings;
			for (singularSetting in settingsMap.keys())
				if (gameSettings.get(singularSetting) != null && gameSettings.get(singularSetting)[3] != FORCED)
					trueSettings.set(singularSetting, FlxG.save.data.settings.get(singularSetting));
		}

		if (!Std.isOfType(trueSettings.get("Framerate Cap"), Int)
			|| trueSettings.get("Framerate Cap") < 30
			|| trueSettings.get("Framerate Cap") > 360)
			trueSettings.set("Framerate Cap", 30);

        saveSettings();
        finalUpdate();
    }

    public static function saveSettings():Void
	{
		FlxG.save.data.settings = trueSettings;
		FlxG.save.flush();

		finalUpdate();
	}

    public static function loadControls():Void
    {
        if ((FlxG.save.data.gameControls != null) && (Lambda.count(FlxG.save.data.gameControls) == Lambda.count(gameControls)))
			gameControls = FlxG.save.data.gameControls;

		saveControls();
    }

    public static function saveControls():Void
	{
		FlxG.save.data.gameControls = gameControls;
		FlxG.save.flush();
	}

    public static function finalUpdate()
	{
		//InfoHud.updateDisplayInfo(trueSettings.get('FPS Counter'), trueSettings.get('Debug Info'), trueSettings.get('Memory Counter'));

		#if (!html5 || !switch)
		Main.updateFramerate(trueSettings.get("Framerate Cap"));
		#end
	}
}