package states;

import flixel.FlxObject;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import lime.app.Application;
import states.editors.MasterEditorMenu;
import options.OptionsState;

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '0.7.3'; // This is also used for Discord RPC
	public static var modVersion:String = 'WIP';
	public static var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;

	var optionShit:Array<String> = [
		'story_mode',
		'freeplay',
		'options',
		#if ACHIEVEMENTS_ALLOWED 'awards', #end
		'extras',
		'credits'
		//,'discord'
		#if MODS_ALLOWED ,'mods' #end
	];

	var colors:Array<FlxColor> = [
		0xff0000, //Story Mode
		0xffff00, //Freeplay
		0x00ff00, //Options
		0x00ffff, //Achievements
		0x000fff, //Extras
		0xff00ff, //Credits
		0x5865f2, //Discord(Unused)
		0xff5a5a, //Mods(Unused)
	];

	var texts:Array<String> = [
		'Play through the mods Story!', //Story Mode
		'Play every song(youve unlocked)!', //Freeplay
		'Personalise your experience!(and not make your potato pc explode)', //Options
		'If youre bored', //Achievements
		'Look at the art and cutscenes!', //Extras
		'The awesome people who made the mod!', //Credits
		'To go to the awesome discord server', //Discord(Unused)
		'Pretty self explanatory isnt it?', //Mods(Unused)
	];
	var desc:FlxText;

	var bg:FlxSprite;
	var magenta:FlxSprite;
	var camFollow:FlxObject;

	var box1:FlxSprite = new FlxSprite();
	var box2:FlxSprite = new FlxSprite();
	var box3:FlxSprite = new FlxSprite();
	var box4:FlxSprite = new FlxSprite();

	override function create()
	{
		#if MODS_ALLOWED
		Mods.pushGlobalMods();
		#end
		Mods.loadTopMod();

		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		var yScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);
		bg = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.scrollFactor.set(0, yScroll);
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.updateHitbox();
		bg.screenCenter();
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		magenta = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		magenta.antialiasing = ClientPrefs.data.antialiasing;
		magenta.scrollFactor.set(0, yScroll);
		magenta.setGraphicSize(Std.int(magenta.width * 1.175));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.color = 0xffffffff;
		add(magenta);

		box1.loadGraphic(Paths.image('CUBE'));
		box1.scrollFactor.set();
		box1.scale.x = FlxG.width;
		//box1.scale.y = 0.75;
		box1.color = FlxColor.BLACK;
		add(box1);

		box2.loadGraphic(Paths.image('CUBE'));
		box2.scrollFactor.set();
		box2.scale.y = FlxG.height;
		box2.color = FlxColor.BLACK;
		add(box2);

		box3.loadGraphic(Paths.image('CUBE'));
		box3.scrollFactor.set();
		box3.scale.x = FlxG.width;
		box3.color = FlxColor.BLACK;
		box3.y = FlxG.height - 100;
		add(box3);

		box4.loadGraphic(Paths.image('CUBE'));
		box4.scrollFactor.set();
		box4.scale.y = FlxG.height;
		box4.color = FlxColor.BLACK;
		box4.x = FlxG.width - 100;
		add(box4);

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		for (i in 0...optionShit.length)
		{
			//var offset:Float = 108 - (Math.max(optionShit.length, 4) - 4) * 80;
			var menuItem:FlxSprite = new FlxSprite(50, (i * (140 * 0.75)) + 50);
			menuItem.antialiasing = ClientPrefs.data.antialiasing;
			menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionShit[i]);
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItems.add(menuItem);
			var scr:Float = ((optionShit.length - 4) * 0.135) / 2;
			if (optionShit.length < 6)
				scr = 0;
			menuItem.scrollFactor.set(0, scr);
			menuItem.updateHitbox();
			//menuItem.screenCenter(X);
		}

		var psychVer:FlxText = new FlxText(0, 44, 0, "Psych Engine v" + psychEngineVersion, 12);
		psychVer.scrollFactor.set();
		psychVer.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		psychVer.screenCenter(X);
		add(psychVer);
		var fnfVer:FlxText = new FlxText(0, 24, 0, "Friday Night Funkin' v" + Application.current.meta.get('version'), 12);
		fnfVer.scrollFactor.set();
		fnfVer.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		fnfVer.screenCenter(X);
		add(fnfVer);
		var modVer:FlxText = new FlxText(0, 64, 0, "SMW Funky Melodies version: " + modVersion, 12);
		modVer.scrollFactor.set();
		modVer.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		modVer.screenCenter(X);
		add(modVer);

		desc = new FlxText(35, FlxG.height - 70, 0, "temp description", 24);
		desc.setFormat("VCR OSD Mono", 32, 0xFFFFFFFF, LEFT);
		desc.scrollFactor.set();
		add(desc);
		changeItem();

		#if ACHIEVEMENTS_ALLOWED
		// Unlocks "Freaky on a Friday Night" achievement if it's a Friday and between 18:00 PM and 23:59 PM
		var leDate = Date.now();
		if (leDate.getDay() == 5 && leDate.getHours() >= 18)
			Achievements.unlock('friday_night_play');

		#if MODS_ALLOWED
		Achievements.reloadList();
		#end
		#end

		super.create();

		FlxG.camera.follow(camFollow, null, 9);
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * elapsed;
			if (FreeplayState.vocals != null)
				FreeplayState.vocals.volume += 0.5 * elapsed;
		}

		if (!selectedSomethin)
		{
			if (controls.UI_UP_P)
				changeItem(-1);

			if (controls.UI_DOWN_P)
				changeItem(1);

			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}

			if (controls.ACCEPT)
			{
				FlxG.sound.play(Paths.sound('confirmMenu'));
				if (optionShit[curSelected] == 'donate')
				{
					CoolUtil.browserLoad('https://ninja-muffin24.itch.io/funkin');
				}else if (optionShit[curSelected] == 'discord')
				{
					CoolUtil.browserLoad('https://discord.gg/5hPD2M6M9m');
				}
				else
				{
					selectedSomethin = true;

					if (ClientPrefs.data.flashing)
						FlxFlicker.flicker(magenta, 1.1, 0.15, false);

					FlxFlicker.flicker(menuItems.members[curSelected], 1, 0.06, false, false, function(flick:FlxFlicker)
					{
						switch (optionShit[curSelected])
						{
							case 'story_mode':
								MusicBeatState.switchState(new StoryMenuState());
							case 'freeplay':
								MusicBeatState.switchState(new FreeplayState());

							#if MODS_ALLOWED
							case 'mods':
								MusicBeatState.switchState(new ModsMenuState());
							#end

							#if ACHIEVEMENTS_ALLOWED
							case 'awards':
								MusicBeatState.switchState(new AchievementsMenuState());
							#end

							case 'credits':
								MusicBeatState.switchState(new CreditsState());
							case 'options':
								MusicBeatState.switchState(new OptionsState());
								OptionsState.onPlayState = false;
								if (PlayState.SONG != null)
								{
									PlayState.SONG.arrowSkin = null;
									PlayState.SONG.splashSkin = null;
									PlayState.stageUI = 'normal';
								}
							case 'extras':
								//MusicBeatState.switchState(new ExtrasState());
								MusicBeatState.switchState(new MainMenuState());
						}
					});

					for (i in 0...menuItems.members.length)
					{
						if (i == curSelected)
							continue;
						FlxTween.tween(menuItems.members[i], {alpha: 0}, 0.4, {
							ease: FlxEase.quadOut,
							onComplete: function(twn:FlxTween)
							{
								menuItems.members[i].kill();
							}
						});
					}
				}
			}
			#if desktop
			if (controls.justPressed('debug_1'))
			{
				selectedSomethin = true;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
			#end
		}

		super.update(elapsed);
	}

	function changeItem(huh:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'));
		menuItems.members[curSelected].animation.play('idle');
		menuItems.members[curSelected].updateHitbox();
		//menuItems.members[curSelected].screenCenter(X);

		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.members[curSelected].animation.play('selected');
		menuItems.members[curSelected].centerOffsets();
		//menuItems.members[curSelected].screenCenter(X);
		desc.text = texts[curSelected];
		desc.screenCenter(X);
		bg.color = colors[curSelected];

		camFollow.setPosition(menuItems.members[curSelected].getGraphicMidpoint().x,
			menuItems.members[curSelected].getGraphicMidpoint().y - (menuItems.length > 4 ? menuItems.length * 8 : 0));
	}
}
