package events;

class MoveEvent extends flash.events.Event {

	public function new(type : String, ?bubbles : Bool, ?cancelable : Bool, ?oldX : Float, ?oldY : Float) : Void 
	{
		super(type, bubbles, cancelable);
	}
	
	public override function toString():String {
		return "["+"MoveEvent"+" type=\""+type+"\" bubbles="+bubbles+" cancelable="+cancelable+" oldX="+oldX+" oldY="+oldY+"]";
	}
	
	public var relatedObject : flash.display.InteractiveObject;
	public var oldX : Float;
	public var oldY : Float;
	public static var MOVE : String = "Move";
}
