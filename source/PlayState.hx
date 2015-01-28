package; 

import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.text.FlxText;
import flixel.group.FlxGroup;
import flixel.tile.FlxTilemap;
import flixel.system.FlxSound;
import flixel.ui.FlxVirtualPad;


class PlayState extends flixel.FlxState
{
	public var level:TiledLevel;
	
	public var score:FlxText;
	public var status:FlxText;
	public var nameText : FlxText;
	public var player:Player;
	//public var floor:FlxObject;
	public var exit:FlxSprite;

	private var name : String;
	
	private static var youDied:Bool = false;

	private var levelPath:String;
	private var onComplete : Bool -> Void;
	private var DefaultZoom : Float;

	private var _sndKey : flixel.system.FlxSound;
#if mobile
public var virtualPad:FlxVirtualPad;
#end

	public function new(_levelPath: String , _name : String, _onComplete:Bool->Void) 
	{
		this.levelPath = _levelPath;
		this.onComplete = _onComplete;
		this.name = _name;
		super();
	}
	
	override public function create():Void 
	{
		FlxG.mouse.visible = false;
		
		super.create();
		bgColor = 0xff444444;
		
		// Load the level's tilemaps
		//levelPath = Resource.Get("l0.tmx");
		level = new TiledLevel(levelPath);
		
		for (layer in level.tileLayers)
		{
			add(layer);
		}
		// Add tilemaps
		//add(level.foregroundTiles);
		
		// Load player objects
		level.loadObjects(this);
		
		// Create UI
		createGui();
		


		DefaultZoom = FlxG.camera.zoom;

		_sndKey = FlxG.sound.load(Resource.Get("sounds/key.wav"));
	}

	private inline function keysCollected() : Int
	{
		if (level.keyGroup.countDead() < 0) return 0;
		return level.keyGroup.countDead();
	}

	private function updateKeys()
	{
		if (level.keyGroup.length > 0)
		{
			score.text = "Keys: " + keysCollected() + "/" + level.keyGroup.length;
		}
		else
		{
			score.text = "";
		}
	}

	private function createGui()
	{
		score = new FlxText(2, 2, 80);
		score.scrollFactor.set(0, 0); 
		score.borderColor = 0xff000000;
		score.borderStyle = FlxText.BORDER_SHADOW;
		updateKeys();
		add(score);
		
		status = new FlxText(FlxG.width - 160 - 2, 2, 160);
		status.scrollFactor.set(0, 0);
		status.borderColor = 0xff000000;
		score.borderStyle = FlxText.BORDER_SHADOW;
		status.alignment = "right";
		add(status);

		nameText = new FlxText(FlxG.width / 2 - 50, 2, 100, name);
		nameText.scrollFactor.set(0, 0);
		nameText.borderColor = 0xff000000;
		nameText.borderStyle = FlxText.BORDER_SHADOW;
		status.alignment = "center";
		add(nameText);
		
#if mobile
	virtualPad = new FlxVirtualPad(FULL, NONE);
	virtualPad.alpha = 0.5;
	add(virtualPad);
#end
	}
	
	override public function destroy():Void
	{
#if mobile
		virtualPad = flixel.util.FlxDestroyUtil.destroy(virtualPad);
#end
	}
	
	override public function update():Void 
	{
		super.update();
		
		//FlxG.overlap(coins, player, getCoin);
		updateMap();	
		
		// Collide with foreground tile layer
		level.collideWithLevel(player);

		FlxG.overlap(level.keyGroup, player, getKey);
		FlxG.overlap(exit, player, touchExit);
		
		if (FlxG.keys.pressed.R)
		{
			loose();
		}
		if (FlxG.keys.justPressed.ESCAPE)
		{
			if (this.subState == null)
			{
				openSubState(new EscMenu(this));
			}
		}

		if (player.y > level.fullHeight)
		{
			loose();
		}
	}

	private inline function hInt(a : haxe.Int32 )
	{
		a = (a^0xdeadbeef) + (a<<4);
		a = a & (a>>10);
		a = a + (a<<7);
		a = a ^ (a >> 13);
		return a;
	}

	private function updateMap() : Void
	{
		var mp : FlxTilemap = level.mainLayer;
		var h : Int = mp.heightInTiles;
		var w : Int = mp.widthInTiles;
		var d : Int = level.nextUd();
		var change = function (fx:Int, fy:Int, tx:Int, ty:Int, tt:Int)
		{
			mp.setTile(tx, ty, tt);
			level.udm[ty][tx] = d;
			mp.setTile(fx, fy, 0);
		} 

		for (py in 1...(h-2))
		{
			for (px in 1...(w-2))
			{
				if (d-level.udm[py][px] < 10) continue;
				var type : Int = mp.getTile(px, py);
				if (TileInfo.IsSnowBall(type))
				{
					var leftFirst = (hInt(px+py*13498))%2 == 0;
					var idd = mp.getTile(px,py+1);
					if (idd ==0)
					{
						change(px, py, px, py+1, type);
					}
					else if (TileInfo.IsSpike(idd))
					{
						change(px, py, px, py+1, TileInfo.SNOW1);
					}
					else if (mp.getTile(px-1, py+1) ==0 &&
						     mp.getTile(px-1, py) ==0 && leftFirst)
					{
						change(px, py, px-1, py, type);
					}
					else if (mp.getTile(px+1, py+1) ==0  &&
						     mp.getTile(px+1, py) ==0)
					{
						change(px, py, px+1, py, type);
					}
					else if (mp.getTile(px-1, py+1) ==0 &&
						     mp.getTile(px-1, py) ==0 && leftFirst == false)
					{
						change(px, py, px-1, py, type);
					}
				}
				if (TileInfo.NormalSnow(type) && mp.getTile(px,py+1) == 0)
				{
					if (!((TileInfo.IsSolid(mp.getTile(px-1, py)) && 
						 TileInfo.IsSolid(mp.getTile(px-1, py+1))) ||
						 (TileInfo.IsSolid(mp.getTile(px+1, py)) && 
						 TileInfo.IsSolid(mp.getTile(px+1, py+1)))) )
					{
						change(px, py, px, py+1, type);
					}
				}
			}
		}
	}

	public function dig(X: Float, Y: Float, dir : Int) : Void
	{
		var cx : Int= Std.int(X/16);
		var cy : Int = Std.int(Y/16);
		var id : Int = level.mainLayer.getTile(cx, cy);
		if (TileInfo.NormalSnow(id) ||
			TileInfo.IsHardSnow(id)) {
 			level.mainLayer.setTile(cx, cy, 0);
		}
		else if (TileInfo.IsSnowBall(id))
		{
			if (level.mainLayer.getTile(cx + dir, cy) == 0)
			{
				level.mainLayer.setTile(cx+dir, cy, id);
				level.mainLayer.setTile(cx,cy, 0);
			}
		}
	}

	private function getKey(Key:FlxObject, Player:FlxObject)
	{
		_sndKey.play();
		Key.kill();
		updateKeys();
		if (level.keyGroup.countLiving() == 0)
		{
			status.text = "Find the exit";
		}
	}

	public function touchExit(Exit:FlxObject, Player:FlxObject)
	{

		if (keysCollected() == level.keyGroup.length)
		{
			win();
		}
		else
		{
			status.text = "Collect all keys";
		}
	}

	public function end()
	{
		if (onComplete != null)
		{
			onComplete(false);
		}
	}

	public function restart()
	{
		FlxG.switchState(new PlayState(levelPath, name, onComplete));
	}
	
	public function win():Void
	{
		status.text = "Level complete.";
		FlxG.sound.load(Resource.Get("sounds/win.wav")).play();
		player.kill();
		if (onComplete != null)
		{
			onComplete(true);
		}
	}

	public function loose() : Void
	{
		restart();
	}
	
}
