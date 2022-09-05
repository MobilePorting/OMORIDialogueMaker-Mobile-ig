package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.ui.FlxInputText;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import lime.utils.Assets;
import sys.io.File;
import textermod.FlxInputTextRTL;

using StringTools;

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
	var dialogueSprites:FlxTypedGroup<DialogueDisplayObject>;
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

	var nextPage:FlxButton;
	var prevPage:FlxButton;
	var pageText:FlxInputText;

	var yamlInstance:YamlInstance;
	var curRenderedDDOs:Int = 0;
	var page:Int = 0;

	var scrollVel = 180;

	public function new()
	{
		super();
		yamlInstance = {};
	}

	override public function create()
	{
		bgColor = #if (!debug) FlxColor.WHITE #else FlxColor.GRAY #end;
		createUI();
		dialogueSprites = new FlxTypedGroup<DialogueDisplayObject>();
		add(dialogueSprites);
		super.create();
	}

	var num:Int = 0;
	var secondaryNum:Int = 1;

	function createUI()
	{
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
			if (numText.text == '' || numText.text.startsWith('-'))
				return;
			for (i in dialogueArray)
			{
				if (i.messageNo == numText.text)
				{
					i = {
						messageNo: numText.text,
						name: nameText.text,
						content: textInput.text,
						faceset: facesetText.text,
						faceindex: faceindexText.text
					}

					trace('yehhhh', i);

					for (boob in dialogueSprites.members)
					{
						if (boob.messageNo == i.messageNo)
						{
							boob.withData(i.messageNo, i.name, i.content);
						}
					}

					return;
				}
			}

			dialogueArray.push({
				messageNo: numText.text,
				name: nameText.text,
				content: textInput.text,
				faceset: facesetText.text,
				faceindex: faceindexText.text
			});

			var ddo = new DialogueDisplayObject(500, 0, numText.text, nameText.text, textInput.text);
			dialogueSprites.add(ddo);

			trace('added to dialogue arraya', dialogueArray.length);
			if (!FlxG.keys.pressed.SHIFT)
			{
				num++;
				numText.text = Std.string(num);
				secondaryNum = 1;
			}
			else
			{
				secondaryNum++;
				numText.text = Std.string(num + '-' + secondaryNum);
			}

			updatePageDisplay();
		});

		removeButton = new FlxButton(addButton.x + addButton.width + 20, addButton.y, "Remove", () ->
		{
			var dontFreeYourMemoryYet:String;

			for (d in dialogueArray)
			{
				if (d.messageNo == numText.text)
				{
					dontFreeYourMemoryYet = d.messageNo;
					dialogueArray.remove(d);
					trace("Deleted");
					if (!FlxG.keys.pressed.SHIFT)
					{
						if (num > 0)
						{
							num--;
							numText.text = Std.string(num);
						}
					}
					else
					{
						if (secondaryNum > 1)
						{
							secondaryNum--;
							numText.text = Std.string(num + '-' + secondaryNum);
						}
					}

					for (c in dialogueSprites.members)
					{
						if (c.messageNo == dontFreeYourMemoryYet)
						{
							dialogueSprites.remove(c, true);
						}
					}

					updatePageDisplay();
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

	function updatePageDisplay(number:Float = 60)
	{
		for (i in 0...dialogueSprites.length)
		{
			var d = dialogueSprites.members[i];
			// trace(i);
			if (i == 0)
			{
				d.pos(500, number);
			}
			else
			{
				d.pos(500, dialogueSprites.members[i - 1].box.y + 80);
			}
		}
	}

	function write()
	{
		for (b in dialogueArray)
		{
			trace(b.faceindex, b.faceset, b.name);
			yamlInstance.write(b.messageNo, b.content.replace('​', ''), b.name, b.faceset, b.faceindex);
		}
		File.saveContent('assets/data/lol.yaml', '');
		File.saveContent('assets/data/lol.yaml', yamlInstance.content);
	}

	override public function update(elapsed:Float)
	{
		var focused = textInput.hasFocus || nameText.hasFocus || numText.hasFocus || facesetText.hasFocus || faceindexText.hasFocus;

		if (FlxG.keys.justPressed.S && FlxG.keys.pressed.S && !focused)
		{
			write();
		}

		for (a in dialogueArray)
		{
			if (a.messageNo == numText.text)
			{
				addButton.text = "Update";
				trace("se.xsex.sex");
				break;
			}
			else
			{
				addButton.text = "Add";
				break;
			}
		}

		if (FlxG.keys.justPressed.DOWN && !focused)
		{
			updatePageDisplay(dialogueSprites.members[0].y + 580);
		}
		else if (FlxG.keys.justPressed.UP && !focused)
		{
			updatePageDisplay(dialogueSprites.members[0].y - 580);
		}
		for (stuff in dialogueSprites.members)
		{
			if (FlxG.mouse.overlaps(stuff))
			{
				stuff.box.x = 480;
				stuff.upText.x = 484;
				stuff.contentText.x = 484;
			}
			else
			{
				stuff.box.x = 500;
				stuff.upText.x = 504;
				stuff.contentText.x = 504;
			}
		}

		if (numText.hasFocus && FlxG.keys.justPressed.ANY)
		{
			if (!numText.text.contains('-') || numText.text != '')
				num = Std.parseInt(numText.text);
		}

		#if debug
		if (FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.R)
			FlxG.resetState();
		#end
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
		if (character.length != 0)
			charStr = '<' + character + '> ';
		if (faceset.length != 0)
		{
			toAppend += "\n  faceset: " + faceset;
		}
		if (faceindex.length != 0)
		{
			toAppend += "\n  faceindex: " + faceindex;
		}

		toAppend += "\n  text: \\n" + charStr + text + "\n";

		content += toAppend;
	}
}
