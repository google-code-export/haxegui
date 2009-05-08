package events;

class DragEvent extends flash.events.MouseEvent {
	
	public function new(type : String, ?bubbles : Bool, ?cancelable : Bool,
	// ?dragInitiator : Component, ?dragSource : mx.core.DragSource, ?action : String,
	?ctrlKey : Bool, ?altKey : Bool, ?shiftKey : Bool) : Void 
	{
		super(type, bubbles, cancelable, 0, 0, null, ctrlKey, altKey, shiftKey);
	}
	
	var action : String;
	var dragInitiator : controls.Component;
	//var dragSource : mx.core.DragSource;
	var draggedItem : Dynamic;
	public static var DRAG_COMPLETE : String = "stopDrag";
	static var DRAG_DROP : String;
	static var DRAG_ENTER : String;
	static var DRAG_EXIT : String;
	public static var DRAG_OVER : String = "dragOver";
	public static var DRAG_START : String = "startDrag";
}
