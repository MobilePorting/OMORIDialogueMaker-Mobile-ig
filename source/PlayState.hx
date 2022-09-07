package;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.ui.FlxInputText;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.utils.Assets;
import openfl.events.Event;
import openfl.filesystem.File;
import openfl.net.FileFilter;
import openfl.net.FileReference;
import sys.FileSystem;
import textermod.FlxInputTextRTL;
import yaml.Yaml;
import yaml.YamlType.AnyYamlType;
import yaml.type.YString;
import yaml.util.ObjectMap.AnyObjectMap;

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

	var saveButton:FlxButton;
	var loadButton:FlxButton;
	var newButton:FlxButton;
	var autosaveButton:FlxButton;

	var yamlInstance:YamlInstance;
	var curRenderedDDOs:Int = 0;
	var page:Int = 0;

	var scrollVel = 180;

	var savePath:String;

	// regex patterns
	var SINE = ~/(?<=sin\().*?(?=\))/g;
	var SHAKE = ~/(?<=shake\().*?(?=\))/g;

	public function new()
	{
		super();
		FlxG.save.bind("vidyagirl", "OmoriDialogueMaker");
		yamlInstance = {};
	}

	override public function create()
	{
		bgColor = FlxColor.GRAY;
		createUI();
		dialogueSprites = new FlxTypedGroup<DialogueDisplayObject>();
		add(dialogueSprites);

		new FlxTimer().start(30, _ ->
		{
			if (dialogueArray.length > 0)
				FlxG.save.data.autosave = dialogueArray;
		}, 0);

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
			var exists = false;
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

					for (boob in dialogueSprites.members)
					{
						if (boob.messageNo == i.messageNo)
						{
							boob.withData(i.messageNo, i.name, i.content);
						}
					}

					exists = true;
				}
			}

			if (exists)
			{
				return;
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

		saveButton = new FlxButton(addButton.x, addButton.y + addButton.height * 2, "Save", saveAs);
		loadButton = new FlxButton(removeButton.x, saveButton.y, "Load", load);
		newButton = new FlxButton(removeButton.x, loadButton.y + loadButton.height * 2, "New File", () ->
		{
			var bg = new FlxSprite().makeGraphic(300, 240);
			bg.screenCenter();
			bg.color = 0xff909090;
			var t = new FlxText("Are you sure?", 14);
			t.color = 0xff000000;
			t.setPosition(bg.x + bg.width / 2 - t.width, bg.y + bg.height / 2);
			var yea = new FlxButton(t.x, t.y + 14 * 2, "Yes", () ->
			{
				FlxG.resetState();
			});
			var no:FlxButton;
			no = new FlxButton(yea.x + yea.width + 20, yea.y, "No", () ->
			{
				remove(bg);
				remove(t);
				remove(yea);
				remove(no);
				bg.destroy();
				t.destroy();
				yea.destroy();
				no.destroy();
			});

			add(bg);
			add(t);
			add(yea);
			add(no);
		});

		autosaveButton = new FlxButton(addButton.x, newButton.y, "Load Autosave", () ->
		{
			dialogueArray = FlxG.save.data.autosave;
			reloadPageDisplay();
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
		add(saveButton);
		add(loadButton);
		add(newButton);
		add(autosaveButton);
	}

	function preProcess(content:String, ignoreNewLines:Bool = false)
	{
		var sines = getMatches(SINE, content);
		var shakes = getMatches(SHAKE, content);

		trace(sines, shakes);

		if (!ignoreNewLines)
			content = content.replace("\n", "");

		for (i in sines)
		{
			content = content.replace('sin($i)', '\\sinv[1]$i\\sinv[0]');
		}

		for (i in shakes)
		{
			content = content.replace('shake($i)', '\\quake[1]$i\\quake[0]');
		}

		return content;
	}

	function load()
	{
		var fr:FileReference = new FileReference();
		fr.addEventListener(Event.SELECT, l_onSelect);
		fr.addEventListener(Event.CANCEL, l_onCancel);
		var filters:Array<FileFilter> = [new FileFilter("YAML files", "*.yaml")];
		fr.browse(filters);
	}

	function l_onSelect(ev:Event)
	{
		var fr:FileReference = cast(ev.target, FileReference);
		fr.addEventListener(Event.COMPLETE, l_onLoad, false, 0, true);
		fr.load();
	}

	function l_onLoad(ev:Event)
	{
		var fr:FileReference = cast(ev.target, FileReference);
		fr.removeEventListener(Event.COMPLETE, l_onLoad);
		dialogueArray = [];
		for (d in dialogueSprites)
		{
			d.destroy();
			dialogueSprites.remove(d);
		}
		parse(fr.data.toString());
		reloadPageDisplay();
	}

	function l_onCancel(ev:Event) {}

	function parse(data:String)
	{
		var pattern = ~/(?<=message_).*(?=:)/g;
		var char_pattern = ~/<(.*?)>/g;
		var matches = getMatches(pattern, data);
		var parsed:AnyObjectMap = Yaml.parse(data);
		for (m in matches)
		{
			var msg = parsed.get("message_" + m);
			var text:String = msg.get("text");

			var faceset:String = msg.get("faceset");
			var faceindex:String = msg.get("faceindex");
			var name:String = getMatches(char_pattern, msg.get("text"))[0].replace("<", "").replace(">", "");
			text = text.replace(name, "");
			text = text.replace("\\n<>", "");

			var thing:Dialogue = {
				messageNo: m,
				content: text,
				faceset: faceset,
				faceindex: faceindex,
				name: name
			};

			dialogueArray.push(thing);
		}
	}

	function getMatches(ereg:EReg, input:String, index:Int = 0):Array<String>
	{
		var matches = [];
		while (ereg.match(input))
		{
			matches.push(ereg.matched(index));
			input = ereg.matchedRight();
		}
		return matches;
	}

	function reloadPageDisplay(number:Float = 60)
	{
		for (i in 0...dialogueArray.length)
		{
			var d = dialogueArray[i];
			var b = new DialogueDisplayObject(0, 0, d.messageNo, d.name, d.content);
			if (i == 0)
			{
				b.pos(500, number);
			}
			else
			{
				b.pos(500, dialogueSprites.members[i - 1].box.y + 80);
			}

			dialogueSprites.add(b);
		}
	}

	function updatePageDisplay(number:Float = 60)
	{
		for (i in 0...dialogueSprites.length)
		{
			var d = dialogueSprites.members[i];
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

	function saveAs()
	{
		for (b in dialogueArray)
		{
			b.content = preProcess(b.content);
			yamlInstance.write(b.messageNo, b.content.replace('​', ''), b.name, b.faceset, b.faceindex);
		}

		new FileReference().save(yamlInstance.content, "dialogue.yaml");
	}

	function write()
	{
		for (b in dialogueArray)
		{
			yamlInstance.write(b.messageNo, b.content.replace('​', ''), b.name, b.faceset, b.faceindex);
		}
	}

	override public function update(elapsed:Float)
	{
		var focused = textInput.hasFocus || nameText.hasFocus || numText.hasFocus || facesetText.hasFocus || faceindexText.hasFocus;

		if (FlxG.keys.justPressed.S && FlxG.keys.pressed.CONTROL && !focused)
		{
			saveAs();
		}

		if (FlxG.keys.justPressed.L && FlxG.keys.pressed.CONTROL && !focused)
		{
			load();
		}

		if (FlxG.keys.justPressed.UP && !focused)
		{
			updatePageDisplay(dialogueSprites.members[0].y + 580);
		}
		else if (FlxG.keys.justPressed.DOWN && !focused)
		{
			updatePageDisplay(dialogueSprites.members[0].y - 580);
		}

		for (stuff in dialogueSprites.members)
		{
			if (FlxG.mouse.overlaps(stuff))
			{
				if (FlxG.mouse.justPressed)
				{
					for (d in dialogueArray)
					{
						if (d.messageNo == stuff.messageNo)
						{
							nameText.text = stuff.name;
							numText.text = stuff.messageNo;
							textInput.text = stuff.content;
							facesetText.text = d.faceset;
							faceindexText.text = d.faceindex;
						}
					}
				}

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
		if (character != null && character.length != 0)
		{
			if (!character.startsWith("\\")) // MACROS
				charStr = '<' + character + '> ';
			else
				charStr = character;
		}
		if (faceset != null && faceset.length != 0)
		{
			toAppend += "\n  faceset: " + faceset;
		}
		if (faceindex != null && faceindex.length != 0)
		{
			toAppend += "\n  faceindex: " + faceindex;
		}

		toAppend += "\n  text: \\n" + charStr + text + "\n";

		content += toAppend;
	}
}
