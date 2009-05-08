package events;

class ResizeEvent extends flash.events.MouseEvent {
	
	
	public function new(type : String, ?bubbles : Bool, ?cancelable : Bool, ?oldWidth : Float, ?oldHeight : Float) : Void 
	{

		if ( bubbles    == null ) bubbles       = false;
        if ( cancelable == null ) cancelable    = false;
		
		super(type, bubbles, cancelable);
		
	}
	
	public override function toString() : String {		
		return "["+"ResizeEvent"+" type=\""+type+"\" bubbles="+bubbles+" cancelable="+cancelable+" oldWidth="+oldWidth+" oldHeight="+oldHeight+"]";
	}
	
	public var oldHeight : Float;
	public var oldWidth : Float;
	public static var RESIZE : String = "Resize";
}
