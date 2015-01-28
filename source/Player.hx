
package ;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.util.FlxTimer;
import flixel.system.FlxSound;
import flixel.ui.FlxButton;


class Player extends Character
{
	private var digging : Bool;
	private var digT : FlxTimer;
	private var game : PlayState;
	private var onGround : Bool;

	private var DIG_SPEED : Float = 0.5;

	private var _sndDie : flixel.system.FlxSound;
	private var _sndStep : flixel.system.FlxSound;
	private var _sndDig : flixel.system.FlxSound;


	public function new(FileName:String, Game:PlayState, X:Float = 0, Y:Float = 0) { 
		super(FileName, Game.level, X, Y);

		digging = false;
		digT = new FlxTimer(DIG_SPEED);
		digT.cancel();

		this.game = Game; 

		_sndDie = FlxG.sound.load(Resource.Get("sounds/die.wav"));
		_sndStep = FlxG.sound.load(Resource.Get("sounds/snow.wav"), 0.2);
		_sndDig = FlxG.sound.load(Resource.Get("sounds/snow2.wav"));
	}

	override public function  destroy() : Void
	{
		_sndDie = flixel.util.FlxDestroyUtil.destroy(_sndDie);
		_sndStep = flixel.util.FlxDestroyUtil.destroy(_sndStep);
		super.destroy();
	}

	private function stopDig()
	{
		digging = false;
		digT.cancel();
		SetAnimation("idle");
	}

	public override function update() : Void 
	{
		var _up:Bool;
		var _left:Bool;
		var _down:Bool;
		var _right:Bool;
		
		_up = FlxG.keys.anyPressed(["UP", "W"]);
		_down = FlxG.keys.anyPressed(["DOWN", "S", "SPACE"]);
		_left = FlxG.keys.anyPressed(["LEFT", "A"]);
		_right = FlxG.keys.anyPressed(["RIGHT", "D"]);

		#if mobile
		_up = _up || game.virtualPad.buttonA.status == FlxButton.PRESSED;
		_down = _down || game.virtualPad.buttonB.status == FlxButton.PRESSED;
		_left  = _left || game.virtualPad.buttonLeft.status == FlxButton.PRESSED;
		_right = _right || game.virtualPad.buttonRight.status == FlxButton.PRESSED;
		#end
		
		acceleration.x = 0;
		var nextOnGround : Bool = isTouching(FlxObject.FLOOR);
		if (!onGround && nextOnGround) _sndStep.play();
		onGround = nextOnGround;

		if (!dying)
		{
			if (digT.finished && digging){
				game.dig(x + dir * 11 , y, dir);	
				digT.reset();
				_sndDig.play();
			}

			if (Math.abs(this.velocity.x) < 1 && Math.abs(this.velocity.y) < 1)
			{
				if (_down) {
					if (!digging ) {
						digging = true;
						SetAnimation("dig");
						digT.reset();
					}
				} else if (digging) {
					stopDig();
				}
			} else if (digging){
				stopDig();
			}


			if (isTouching(FlxObject.FLOOR) && Math.abs(this.velocity.x) > 10)
			{
				_sndStep.play();
			}
			if (_left)
			{
				acceleration.x = -maxVelocity.x * 4;
				
			}
			else if (_right)
			{
				acceleration.x = maxVelocity.x * 4;
			}

			if (_up && isTouching(FlxObject.FLOOR))
			{
				velocity.y = -maxVelocity.y / 2;
			}
		}

		super.update();
	}

	public override function die() :Void
	{
		if (dying) return; // Cant die twice 
		_sndDie.play(true);
		dying = true;
		SetAnimation("die");
		new FlxTimer(2, function(timer:FlxTimer) {kill(); game.loose();});
	}
}