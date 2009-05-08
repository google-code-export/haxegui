package events;

class MenuEvent extends flash.events.Event {
	public function new(type : String, ?bubbles : Bool, ?cancelable : Bool,
	//~ ?menuBar : Component,
	?menuBar : flash.display.DisplayObject,
	?menu : controls.Component,
	?item : flash.display.DisplayObject,
	// ?itemRenderer : mx.controls.listClasses.IListItemRenderer,
	?label : String, ?index : Int) 
	: Void {
	super(type,bubbles,cancelable);
	}
	
	var index : Int;
	public var item : Dynamic;
	var label : String;
	public var menu : controls.Component;
	public var menuBar : controls.Component;
	static var CHANGE : String;
	public static var ITEM_CLICK : String = "itemClick";
	static var ITEM_ROLL_OUT : String;
	static var ITEM_ROLL_OVER : String;
	public static var MENU_HIDE : String = "MenuHide";
	public static var MENU_SHOW : String = "MenuShow";
}
