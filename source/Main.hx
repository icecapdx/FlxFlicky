package;

import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import meta.*;
import openfl.Lib;
import openfl.display.Sprite;

class Main extends Sprite
{
	/*
		The main class for the game! Where all the magic happens and ties the game together.
		I HEAVILY don't recommend changing anything in here but if you KNOW what ur doing by all means go ahead.
	*/

	public static var gameWidth:Int = 1280; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
	public static var gameHeight:Int = 720; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
	public static var mainClassState:Class<FlxState> = Init; // Determine the main class state of the game
	public static var framerate:Int = 120; // How many frames per second the game should run at.
	public static var gameVersion:String = '0.1'; // the version of ur game, u can call thiss for whatever reason u have lol
	var skipSplash:Bool = true; // Whether to skip the flixel splash screen that appears in release mode.
	var infoCounter:InfoOverlay; // initialize the heads up display that shows information before creating it.

	public static function main():Void
	{
		Lib.current.addChild(new Main());
	}

	public function new()
	{
		super();

		// iirc html can't do 120 fps, nx/switch also can't so we'll stick to 60 for those two
		#if (html5 || switch)
		framerate = 60;
		#end

		// game bounds basically
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;

		// here we set up the game itself
		var game:FlxGame;
		game = new FlxGame(gameWidth, gameHeight, mainClassState, framerate, framerate, skipSplash);
		addChild(game); // and create it after!

		infoCounter = new InfoOverlay(10, 3, 0xFFFFFF, true);
		addChild(infoCounter);
	}

	/*  This is used to switch scenes!
	 */
	public static var lastState:FlxState;
	public static function switchState(curState:FlxState, target:FlxState)
	{
		// this doesn't really have much use unless u wanna track the last state for whatever reason
		// could prolly be useful for debugging tho
		lastState = curState;
		mainClassState = Type.getClass(target);
		FlxG.switchState(target);
	}

	public static function updateFramerate(newFramerate:Int)
	{
		if (newFramerate > FlxG.updateFramerate)
		{
			FlxG.updateFramerate = newFramerate;
			FlxG.drawFramerate = newFramerate;
		}
		else
		{
			FlxG.drawFramerate = newFramerate;
			FlxG.updateFramerate = newFramerate;
		}
	}
}