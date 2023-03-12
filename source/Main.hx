package;

import flixel.FlxGame;
import lime.utils.LogLevel;
import openfl.display.Sprite;

class Main extends Sprite
{
        private var gameWidth:Int = 960;
	private var gameHeight:Int = 640;

	public function new()
	{
                SUtil.uncaughtErrorHandler();
		super();
		openfl.utils._internal.Log.level = LogLevel.WARN;
                final stageWidth:Int = Lib.current.stage.stageWidth;
		final stageHeight:Int = Lib.current.stage.stageHeight;
		final ratioX:Float = stageWidth / gameWidth;
		final ratioY:Float = stageHeight / gameHeight;
		final zoom:Float = Math.min(ratioX, ratioY);
		gameWidth = Math.ceil(stageWidth / zoom);
		gameHeight = Math.ceil(stageHeight / zoom);
		addChild(new FlxGame(gameWidth, gameHeight, PlayState, zoom));
	}
}
