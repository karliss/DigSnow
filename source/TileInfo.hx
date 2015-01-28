
package ;

class TileInfo 
{

	public static inline var START     = 2;
	public static inline var SPIKE     = 4;
	public static inline var SNOW1     = 51;
	public static inline var SNOW2     = 52;
	public static inline var SNOW3     = 75;
	public static inline var SNOW4     = 76;
	public static inline var SNOW_BALL = 78;
	public static inline var HARD_SNOW = 99;
	public static inline var ICE       = 54;
	
	public static inline function IsSolid(id: Int) : Bool
	{
		return IsHardSnow(id) || NormalSnow(id) || IsIce(id);
	}

	public static inline function IsSnowBall(id : Int) : Bool
	{
		return id == 78;
	}

	public static inline function NormalSnow(id : Int) : Bool
	{
		return id == SNOW1 || id == SNOW2 || id == SNOW3 || id == SNOW4;
	}

	public static inline function IsHardSnow(id : Int) : Bool
	{
		return id == HARD_SNOW;
	}

	public static inline function IsSnow(id : Int) : Bool
	{
		return IsSnowBall(id) || NormalSnow(id) || IsHardSnow(id);
	}

	public static inline function IsSpike (id : Int) : Bool
	{
		return id == SPIKE;
	}

	public static inline function IsIce(id : Int) : Bool
	{
		return IsSpike(id) || id == ICE;
	}

}