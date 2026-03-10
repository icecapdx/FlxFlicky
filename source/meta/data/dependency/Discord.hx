package meta.data.dependency;

#if (!html5 || !switch)
import discord_rpc.DiscordRpc;
#end
import lime.app.Application;

class Discord
{
	#if (!html5 || !switch)
	public static function initializeRPC(rpcID:String)
	{
		DiscordRpc.start({
			clientID: rpcID,
			onReady: onReady,
			onError: onError,
			onDisconnected: onDisconnected
		});
		Application.current.window.onClose.add(shutdownRPC);
	}

	static function onReady()
	{
		DiscordRpc.presence({
			details: "",
			state: null,
			largeImageKey: 'icon',
			largeImageText: "A Haxeflixel Game"
		});
	}

	static function onError(_code:Int, _message:String)
	{
		trace('Error! $_code : $_message');
	}

	static function onDisconnected(_code:Int, _message:String)
	{
		trace('Disconnected! $_code : $_message');
	}

	public static function changePresence(details:String = '', state:Null<String> = '', ?smallImageKey:String, ?hasStartTimestamp:Bool, ?endTimestamp:Float)
	{
		var startTimestamp:Float = (hasStartTimestamp) ? Date.now().getTime() : 0;

		if (endTimestamp > 0)
			endTimestamp = startTimestamp + endTimestamp;

		DiscordRpc.presence({
			details: details,
			state: state,
			largeImageKey: 'icon',
			largeImageText: "A Haxeflixel Game",
			smallImageKey: smallImageKey,
			startTimestamp: Std.int(startTimestamp / 1000),
			endTimestamp: Std.int(endTimestamp / 1000)
		});

		trace('Discord RPC Updated. Arguments: $details, $state, $smallImageKey, $hasStartTimestamp, $endTimestamp');
	}

	public static function shutdownRPC()
	{
		DiscordRpc.shutdown();
	}
	#end
}