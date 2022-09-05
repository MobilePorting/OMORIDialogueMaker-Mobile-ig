package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;

using StringTools;

class DialogueDisplayObject extends FlxGroup
{
	public var messageNo:String;
	public var name:String;
	public var content:String;

	public var box:FlxSprite;
	public var upText:FlxText;
	public var contentText:FlxText;

	public var x:Float;
	public var y:Float;

	public function new(x:Float = 0, y:Float = 0, messageNo:String, name:String, content:String)
	{
		super();
		this.x = x;
		this.y = y;
		withData(messageNo, name, content);
	}

	public function withData(messageNo:String, name:String, content:String)
	{
		this.messageNo = messageNo;
		this.name = name;
		this.content = content;

		box = new FlxSprite(x, y).makeGraphic(200, 60, FlxColor.WHITE);
		upText = new FlxText(x + 2, y + 2, 200, ("No. " + messageNo + " - " + name).substring(0, 20), 14);
		upText.color = 0xff000000;
		contentText = new FlxText(upText.x, upText.y + 20, 200, content.substring(0, 30), 14);
		contentText.color = 0xff000000;
		add(box);
		add(upText);
		add(contentText);
	}

	public function pos(x:Float = 0, y:Float = 0)
	{
		this.x = x;
		this.y = y;
		box.setPosition(x, y);
		upText.setPosition(x + 2, y + 2);
		contentText.setPosition(upText.x, upText.y + 20);
	}
}
