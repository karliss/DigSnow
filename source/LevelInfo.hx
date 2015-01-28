
package ;

class LevelInfo 
{
	static public var levels : Array<String> = [	

		"l1.tmx",
		"l2.tmx",
		"l3.tmx",
		"l4.tmx",
		"l5.tmx",
		"l6.tmx",
		"l7.tmx",
		"l8.tmx",

		"lxx_sandclock_1.tmx",
		"lxx_sandclock_3.tmx",
	    "lxx_sandclock_4.tmx",
		"lxx_sandclock_2.tmx",
		"lxx_tower.tmx",
		"lxx_sandclock_5.tmx",
		"lxx_tunnel.tmx",
		"lxx_cave.tmx",
		];

	static public function next(current:String)
	{
		for ( i in 0...(levels.length - 1))
		{
			if (levels[i] == current) return levels[i+1];
		}
		return null;
	}

}