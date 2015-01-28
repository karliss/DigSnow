
package ;

class Resource 
{

	static inline public function Get(Name:String) : String
	{
		return "assets/" + Name;
	}

	static inline public function Path(Name:String) : haxe.io.Path
	{
		return new haxe.io.Path(Get(Name));
	}

}