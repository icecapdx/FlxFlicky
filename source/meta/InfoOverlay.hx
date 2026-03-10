// Modified versison of the FPS class from OpenFL
package meta;

// import Main;
import flixel.FlxG;
import haxe.Timer;
import openfl.events.Event;
import openfl.system.System;
import openfl.text.TextField;
import openfl.text.TextFormat;

class InfoOverlay extends TextField
{
	public static var currentFPS(default, null):Int;
	public static var memoryUsage:Float;
	public static var displayFps = true;
	public static var displayMemory = true;
	public static var displayExtra = true;
	private var cacheCount:Int;
	private var currentTime:Float;
	private var times:Array<Float>;
	private var display:Bool;

	public function new(x:Float = 10, y:Float = 10, color:Int = 0x000000, hudDisplay:Bool = false)
	{
		super();

		display = hudDisplay;

		this.x = x;
		this.y = y;

		currentFPS = 0;
		selectable = false;
		mouseEnabled = false;
		defaultTextFormat = new TextFormat(Util.getFont("vcr.ttf"), 16, color);
		width = Main.gameWidth;
		height = Main.gameHeight;

		text = "FPS: \nState: \nMemory:";

		cacheCount = 0;
		currentTime = 0;
		times = [];
	}

	private override function __enterFrame(deltaTime:Float):Void
	{
		currentTime += deltaTime;
		times.push(currentTime);

		while (times[0] < currentTime - 1000)
		{
			times.shift();
		}

		text = "";
		if (displayFps)
		{
			if (Math.isNaN(FlxG.updateFramerate))
				currentFPS = Math.round((times.length + cacheCount) / 2);
			else
				currentFPS = FlxG.updateFramerate;
			text += "FPS: " + currentFPS + "\n";
			cacheCount = times.length;
		}
		if (displayExtra)
			text += "State: " + Main.mainClassState + "\n";
		if (displayMemory)
		{
			memoryUsage = Math.round(System.totalMemory / (1e+6));
			text += "Memory: " + memoryUsage + " mb";
		}
	}

	public static function getFrames():Float
	{
		return currentFPS;
	}

	public static function getMemoryUsage():Float
	{
		return memoryUsage;
	}

	public static function updateDisplayInfo(shouldDisplayFps:Bool, shouldDisplayExtra:Bool, shouldDisplayMemory:Bool)
	{
		displayFps = shouldDisplayFps;
		displayExtra = shouldDisplayExtra;
		displayMemory = shouldDisplayMemory;
	}
}