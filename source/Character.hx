package ;

import flixel.addons.display.FlxExtendedSprite;
import flixel.FlxObject;
import haxe.Json;

class Character extends FlxExtendedSprite
{
	private var animType : String = "";
	private var dir : Int ;
	private var world : TiledLevel;
	private var dying : Bool;

	public function new(FileName:String, world:TiledLevel, X:Float = 0, Y:Float = 0) {
		super(X, Y);
		var jsondata = Json.parse(openfl.Assets.getText(Resource.Get(FileName)));
		this.width = Std.parseInt(jsondata.width);
		this.height = Std.parseInt(jsondata.height);
		this.dying = false;

		this.world = world;

		var image_path = Resource.Get(jsondata.image);

		this.loadGraphic(image_path , false, 16 , 16);	
		this.width = 4;
		this.height = 13;
		this.offset.set(6, 3);

		for (anim in Reflect.fields(jsondata.animation)) {
			var d = Reflect.field(jsondata.animation, anim);
			var speed:Int = Std.parseInt(d.speed);
			var looped = d.looped == "true";
			animation.add(anim, d.f, speed, looped);
		}

		animation.play("idle");
		dir = 1;

		drag.x = maxVelocity.x * 4;
		drag.y = maxVelocity.y * 4;
	}

	public override function update() : Void 
	{
		if (this.velocity.x < 0) dir = -1;
		if (this.velocity.x > 0) dir = 1;
		this.flipX = dir != 1;

		if (!dying)
		{
			if (Math.abs(this.velocity.x) > 10) SetAnimation("walk");
			else if (animType == "walk") SetAnimation("idle");
		}

		checkFloor();

		super.update();
	}

	private function checkFloor() : Void
	{
		if (isTouching(FlxObject.FLOOR))
		{
			var t1 : Int = world.getTileId(x, y+2+this.height);
			var t2 : Int = world.getTileId(x + this.width - 1, y + 2 + this.height);
			if (TileInfo.IsSpike(t1) || TileInfo.IsSpike(t2)) {
				velocity.x = 0;
				die();
			}
		}
		var ts : Int = world.getTileId(x+this.width/2, y+this.height/2);
		if (ts != 0) {
			die();
		}
	}

	public function die() : Void
	{
		this.kill();
	}

	public function SetAnimation(newAnim:String, force : Bool = false) : Void
	{
		if (animType != newAnim || force)
		{
			animation.play(newAnim);
			animType = newAnim;
		}
	}
}