package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.ui.FlxInputText;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import lime.utils.Assets;
import textermod.FlxInputTextRTL;

typedef Dialogue =
{
	var messageNo:String;
	var name:String;
	var faceset:String;
	var faceindex:String;
	var content:String;
}

class PlayState extends FlxState
{
	var dialogueArray:Array<Dialogue> = [];

	var numTextLabel:FlxText;
	var nameTextLabel:FlxText;
	var facesetTextLabel:FlxText;
	var faceindexTextLabel:FlxText;
	var textInputLabel:FlxText;

	var numText:FlxInputText;
	var nameText:FlxInputText;
	var facesetText:FlxInputText;
	var faceindexText:FlxInputText;
	var textInput:FlxInputTextRTL;
	var addButton:FlxButton;
	var removeButton:FlxButton;

	var yamlInstance:YamlInstance;

	public function new()
	{
		super();
		yamlInstance = {};
		yamlInstance.write("0", "Hey, SUNNY.", "AUBREY", "Test", "1");
	}

	override public function create()
	{
		bgColor = #if (!debug) FlxColor.WHITE #else FlxColor.GRAY #end;
		createUI();
		super.create();
	}

	var num:Int = 0;
	var secondaryNum:Int = 0;

	function createUI()
	{
		var centerX = 480;
		var centerY = 320;

		nameTextLabel = new FlxText(40, centerY + 40, "Name", 14);
		nameTextLabel.color = 0xff000000;
		nameText = new FlxInputText(40, centerY + 60, 200, "", 14);

		numTextLabel = new FlxText(nameText.x + nameText.width + 14, centerY + 40, "Num", 14);
		numTextLabel.color = 0xff000000;
		numText = new FlxInputText(numTextLabel.x, centerY + 60, 46, "0", 14);
		numText.customFilterPattern = ~/[^0-9\-]*/g;

		textInput = new FlxInputTextRTL(40, centerY + 90, Std.int(nameText.width + numText.width + 14), "", 14);

		facesetTextLabel = new FlxText(textInput.x + textInput.width + 10, textInput.y - 30, 0, "Face set", 14);
		facesetTextLabel.color = 0xff000000;
		facesetText = new FlxInputText(facesetTextLabel.x, textInput.y, 140, "", 14);

		faceindexTextLabel = new FlxText(facesetTextLabel.x, facesetText.y + 30, 0, "Face index", 14);
		faceindexTextLabel.color = 0xff000000;
		faceindexText = new FlxInputText(facesetTextLabel.x, faceindexTextLabel.y + 30, 46, "", 14);
		faceindexText.filterMode = FlxInputText.ONLY_NUMERIC;

		addButton = new FlxButton(faceindexText.x, faceindexText.y + 50, "Add", () ->
		{
			dialogueArray.push({
				messageNo: numText.text,
				name: nameText.text,
				content: textInput.text,
				faceset: facesetText.text,
				faceindex: faceindexText.text
			});
			trace('added to dialogue arraya', dialogueArray.length);
		});

		removeButton = new FlxButton(addButton.x + addButton.width + 20, addButton.y, "Remove", () ->
		{
			for (d in dialogueArray)
			{
				if (d.messageNo == numText.text)
				{
					dialogueArray.remove(d);
					trace("Deleted");
					break;
				}
			}
		});

		add(nameTextLabel);
		add(nameText);

		add(numTextLabel);
		add(numText);

		add(textInput);

		add(facesetTextLabel);
		add(facesetText);

		add(faceindexTextLabel);
		add(faceindexText);

		add(addButton);
		add(removeButton);
	}

	override public function update(elapsed:Float)
	{
		if (FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.R)
			FlxG.resetState();
		super.update(elapsed);
	}
}

@:structInit
class YamlInstance
{
	public var content:String = '';

	public function new(?content:String = '')
	{
		this.content = content;
	}

	public function write(messageNo:String, text:String, ?character:String, ?faceset:String, ?faceindex:String)
	{
		var toAppend = "message_" + messageNo + ":";
		var charStr = '';
		if (character != null || character.length < 1)
			charStr = '<' + character + '> ';
		if (faceset != null || faceset.length < 1)
		{
			toAppend += "\n\tfaceset: " + faceset;
		}
		if (faceindex != null || faceset.length < 1)
		{
			toAppend += "\n\tfaceindex: " + faceindex;
		}

		toAppend += "\n\ttext: " + charStr + text + "\n";

		content += toAppend;
	}
}
