package;

import openfl.Assets;
import haxe.io.Path;
import haxe.xml.Parser;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.tile.FlxTilemap;
import flixel.addons.editors.tiled.TiledMap;
import flixel.addons.editors.tiled.TiledObject;
import flixel.addons.editors.tiled.TiledObjectGroup;
import flixel.addons.editors.tiled.TiledTileSet;

/**
 * ...
 * @author Samuel Batista
 */
class TiledLevel extends TiledMap
{
	// For each "Tile Layer" in the map, you must define a "tileset" property which contains the name of a tile sheet image 
	// used to draw tiles in that layer (without file extension). The image file must be located in the directory specified bellow.
	
	private var ground:Array<FlxTilemap>;
	public var tileLayers:Array<flixel.FlxBasic>;
	public var mainLayer : FlxTilemap;
	public var keyGroup : FlxGroup;

	public var udm : Array<Array<Int>>;
	public var udi : Int;
	
	public function new(tiledLevel:Dynamic)
	{
		super(tiledLevel);
		
		ground = new Array<FlxTilemap>();
		tileLayers = new Array<flixel.FlxBasic>();
		
		FlxG.camera.setBounds(0, 0, fullWidth, fullHeight, true);
		
		keyGroup = new FlxGroup();


		for (tileLayer in layers)
		{
	
			var anyId : Int = -1;
			for (id in tileLayer.tileArray)
			{
				if (id > 0)
				{
					anyId = id;
					//break;
				}
			}
			if (anyId < 0) continue;

			var tileSet:TiledTileSet = this.getGidOwner(anyId);
			
			if (tileSet == null)
				throw "Tileset  not found. Did you mispell the 'tilesheet' property in " + tileLayer.name + "' layer?";
				
			var imagePath 		= new Path(tileSet.imageSource);
			var processedPath 	= Resource.Get(imagePath.file + "." + imagePath.ext);
			
			var tilemap:FlxTilemap = new FlxTilemap();
			tilemap.widthInTiles = width;
			tilemap.heightInTiles = height;
			var firstId : Int = tileSet.firstGID;
			
			tilemap.loadMap(tileLayer.tileArray, processedPath, tileSet.tileWidth, tileSet.tileHeight, 0, firstId, firstId, firstId);

			if (tileLayer.name.indexOf("h_") == 0)
			{
				ground.push(tilemap);
				mainLayer = tilemap;
			}

			tileLayers.push(tilemap);
			
		}
		udm = [for (y in 0...mainLayer.heightInTiles) [for (x in 0...mainLayer.widthInTiles) 0]];
		udi = 0;
	}

	public function nextUd() : Int
	{
		udi++;
		if (udi > (1<<30))
		{
			udi = 1;
			for (y in 0...mainLayer.heightInTiles)
			{
				for (x in 0...mainLayer.widthInTiles)
				{
					udm[y][x] = 0;
				}
			}
		}
		return udi;
	}

	
	public function loadObjects(state:PlayState)
	{
		for (group in objectGroups)
		{
			for (o in group.objects)
			{
				loadObject(o, group, state);
			}
		}
	}
	
	private function loadObject(o:TiledObject, g:TiledObjectGroup, state:PlayState)
	{
		var x:Int = o.x;
		var y:Int = o.y;
			
		if (o.gid != -1)
		{
			y -= g.map.getGidOwner(o.gid).tileHeight;
		}
		var result:FlxSprite = null;
		switch (o.type.toLowerCase())
		{
			case "start":
				//var player = new Character(c_PATH_LEVEL_TILESHEETS + "player.json", x, y);

				var player = new Player("player.json", state, x, y);
				// new FlxSprite(x, y);
				//player.makeGraphic(16, 16, 0xffaa1111);
				player.maxVelocity.x = 160;
				player.maxVelocity.y = 300;
				player.acceleration.y = 400;
				player.drag.x = player.maxVelocity.x * 4;
				FlxG.camera.follow(player);
				//FlxG.camera.zoom =;
				state.player = player;
				state.add(player);
				
			case "exit":
				var exit = new FlxSprite(x, y);
				state.exit = exit;
				state.add(exit);
				result = exit;

			case "key":
				result = new FlxSprite(x, y);
				this.keyGroup.add(result);
				state.add(result);

			default:
				result = new FlxSprite(x, y);
				state.add(result);

				/*exit.loadGraphic(Resource.Get(tilest.))
			new FlxSprite( ?X : Float , ?Y : Float , ?SimpleGraphic : Dynamic )
			var exit = new FlxSprite(x, y, 
				exit.makeGraphic(16, 16, 0x5000ff11);
				
				state.add(exit);*/
		}
		if (o.gid > 0 && result != null)
		{
			var tileset = g.map.getGidOwner(o.gid);
			result.loadGraphic( Resource.Get(tileset.imageSource) , true, 16 , 16);
			result.frame = result.framesData.frames[o.gid-tileset.firstGID];
		}
	}
	
	public function collideWithLevel(obj:FlxObject, ?notifyCallback:FlxObject->FlxObject->Void, ?processCallback:FlxObject->FlxObject->Bool):Void
	{
		for (map in ground)
		{
			FlxG.overlap(map, obj, notifyCallback, processCallback != null ? processCallback : FlxObject.separate);
		}
		/* var first = true;
		if (collidableTileLayers != null)
		{
			for (map in collidableTileLayers)
			{

				// IMPORTANT: Always collide the map with objects, not the other way around. 
				//			  This prevents odd collision errors (collision separation code off by 1 px).
				FlxG.overlap(map, obj, notifyCallback, processCallback != null ? processCallback : FlxObject.separate);
				
			}
		}*/
		//return false;
	}

	public function getTileId(x:Float, y:Float) : Int
	{
		return mainLayer.getTile(Std.int(x/16), Std.int(y/16));
	}
}