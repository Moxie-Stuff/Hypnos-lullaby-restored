package meta.data;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.graphics.tile.FlxGraphicsShader;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import gameObjects.Character;
import gameObjects.userInterface.notes.Note;
import gameObjects.userInterface.notes.Strumline;
import meta.data.ScriptHandler;
import meta.state.PlayState;
import openfl.filters.ShaderFilter;
import openfl.utils.Assets;
#if sys
import sys.FileSystem;
#end

using StringTools;

typedef PlacedEvent = {
    var timestamp:Float;
    var params:Array<Dynamic>;
    var eventName:String;
}; 

class Events {
	public static var eventList:Array<String> = [];

	public static var loadedModules:Map<String, ForeverModule> = [];

	public static function obtainEvents() {
		loadedModules.clear();
		eventList = [];
		#if (sys && !html5)
		var tempEventArray:Array<String> = FileSystem.readDirectory('assets/events');
		#elseif html5
		var tempEventArray:Array<String> = Assets.getText('assets/events');
		#end
		//
		var futureEvents:Array<String> = [];
		var futureSubEvents:Array<String> = [];
		for (event in tempEventArray) {
			if (event.contains('.')) {
				event = event.substring(0, event.indexOf('.', 0));
				loadedModules.set(event, ScriptHandler.loadModule('events/$event'));
				futureEvents.push(event);
			} else {
				if (PlayState.SONG != null && CoolUtil.spaceToDash(PlayState.SONG.song.toLowerCase()) == event) {
					#if (sys && !html5)
					var internalEvents:Array<String> = FileSystem.readDirectory('assets/events/$event');
					#elseif html5
					var internalEvents:Array<String> = Assets.getText('assets/events/$event');
					#end
					for (subEvent in internalEvents)
					{
						subEvent = subEvent.substring(0, subEvent.indexOf('.', 0));
						loadedModules.set(subEvent, ScriptHandler.loadModule('events/$event/$subEvent'));
						futureSubEvents.push(subEvent);
					}
					//
				} 
			}
		}
		futureEvents.sort(function(a, b) return Reflect.compare(a.toLowerCase(), b.toLowerCase()));
		futureSubEvents.sort(function(a, b) return Reflect.compare(a.toLowerCase(), b.toLowerCase()));

		for (i in futureSubEvents)
			eventList.push(i);
		futureEvents.insert(0, '');
		for (i in futureEvents)
			eventList.push(i);

		futureEvents = [];
		futureSubEvents = [];
		
		eventList.insert(0, '');
	}

	public static function returnDescription(event:String):String {
		if (loadedModules.get(event) != null) {
			var module:ForeverModule = loadedModules.get(event);
			if (module.exists('returnDescription'))
				return module.get('returnDescription')();
		}
		return '';
	}
}