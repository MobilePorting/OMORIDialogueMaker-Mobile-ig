package;

import flixel.FlxGame;
import lime.utils.LogLevel;
import openfl.display.Sprite;

class Main extends Sprite
{
	public function new()
	{
                SUtil.uncaughtErrorHandler();
		super();
		openfl.utils._internal.Log.level = LogLevel.WARN;
		addChild(new FlxGame(0, 0, PlayState));
	}
}
