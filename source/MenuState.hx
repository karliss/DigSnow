package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxMath;
import flixel.util.loaders.TextureAtlasFrame;
import openfl.system.System;
/**
 * A FlxState which can be used for the game's menu.
 */
class MenuState extends FlxState
{
	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	private var _btnFullScreen : FlxButton;
	 
	override public function create():Void
	{
		FlxG.mouse.visible = true;

		/*super.create();
		var b1 : FlxButton = new FlxButton(FlxG.width/2, 20,  "Start", newGame);
		b1.x -= b1.width/2;
		add(b1);*/
		var t1 : FlxText = new FlxText(FlxG.width / 2, 10, 200, "Dig Snow | Global Game Jam 2015");
		t1.x -= t1.width / 2;
		add(t1);

		
		var b1 : FlxButton = new FlxButton(FlxG.width/2, 50,  "Start", function() {FlxG.switchState(new LevelSelector());});
		b1.x -= b1.width/2;
		add(b1);
		
#if desktop
		_btnFullScreen = new FlxButton(0, 70, FlxG.fullscreen ? "FULLSCREEN" : "WINDOWED", function() {
			    FlxG.fullscreen = !FlxG.fullscreen;
				_btnFullScreen.text = FlxG.fullscreen ? "FULLSCREEN" : "WINDOWED";
		});
		_btnFullScreen.x = FlxG.width / 2 - _btnFullScreen.width / 2;
		add(_btnFullScreen);
		
		var _btnExit = new FlxButton(FlxG.width / 2, 90, "Exit", function() { System.exit(0); } );
		_btnExit.x -= _btnExit.width / 2;
		add(_btnExit);
#end
		
		var t2 : FlxText = new FlxText(10, 110, FlxG.width - 20, "Controls: \n WASD/Arrows - move \n SPACE - Dig \n R - restart \n Alt+Enter - fullscreen(Desktop) \n 0/+/- - Control sound\n \n\n Created by : Karlis \n Tileset : Nauris");
		add(t2);
	}
	

	private function newGame():Void
	{
		FlxG.switchState(new SeqLevelLoader());
	}
	/**
	 * Function that is called when this state is destroyed - you might want to 
	 * consider setting all objects this state uses to null to help garbage collection.
	 */
	override public function destroy():Void
	{
		super.destroy();
	}

	/**
	 * Function that is called once every frame.
	 */
	override public function update():Void
	{
		super.update();
	}	
}