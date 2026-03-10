package meta.state;

import flixel.FlxG;
import flixel.FlxState;
import meta.data.dependency.Discord;

class PlayState extends FlxState
{
	override public function create()
	{
		super.create();
		final curStateName:String = Type.getClassName(Type.getClass(FlxG.state));
		Discord.changePresence('wait...itd be funny if I just... ' + curStateName);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
