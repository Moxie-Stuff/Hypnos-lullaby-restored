package meta.data;

import flixel.FlxG;
import flixel.FlxBasic;

using StringTools;

interface IScriptInterface {
    public function add(obj:FlxBasic):Dynamic;
    public function remove(obj:FlxBasic):Dynamic;
}