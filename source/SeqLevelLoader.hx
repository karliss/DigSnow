package ;

import flixel.FlxG;
import flixel.FlxState;

class SeqLevelLoader extends FlxState
{
	private var LastLevel : String;

	public function new (_lastLevel:String=null)
	{
		LastLevel = _lastLevel;
		super();
	}

	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		FlxG.mouse.visible = true;
		
		var clevel : String;
		if (LastLevel == null)
		{
			clevel = LevelInfo.levels[0];
		}
		else
		{
			clevel = LevelInfo.next(LastLevel);
		}
		if (clevel == null)
		{
			FlxG.switchState(new MenuState());
		}
		else
		{
			FlxG.switchState(new PlayState(Resource.Get(clevel), 
				"Level " + clevel, 
				function (result : Bool) {
						if (result)
							FlxG.switchState(new SeqLevelLoader(clevel));
						else 
							FlxG.switchState(new MenuState());
					}));
		}

		super.create();
	}

	override public function destroy():Void
	{
		super.destroy();
	}

}