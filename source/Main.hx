package;

import flixel.FlxGame;
import lime.utils.LogLevel;
import openfl.display.Sprite;
import openfl.Lib;
import openfl.display.StageScaleMode;

class Main extends Sprite
{
        var app = {
		width: 960,
		height: 640,
		initState: PlayState,
		zoom: -1.0,
		fps: 60,
		noSplash: false,
		forceFullScreen: false
	};

	public function new()
	{
                SUtil.uncaughtErrorHandler();
		super();
		openfl.utils._internal.Log.level = LogLevel.WARN;
                var stageWidth:Int = Lib.current.stage.stageWidth;
                var stageHeight:Int = Lib.current.stage.stageHeight;
		if (app.zoom == -1.0)
		{
			var ratioX:Float = stageWidth / app.width;
			var ratioY:Float = stageHeight / app.height;
			app.zoom = Math.min(ratioX, ratioY);
			app.width = Math.ceil(stageWidth / app.zoom);
			app.height = Math.ceil(stageHeight / app.zoom);
		}
		addChild(new FlxGame(app.width, app.height, app.initState, #if (flixel < "5.0.0") app.zoom, #end app.fps, app.fps, app.noSplash, app.forceFullScreen));
                Lib.current.stage.align = "tl";
		Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;
	}
}
