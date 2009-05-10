package haxegui;

interface IChildList {
	function addChild(child : flash.display.DisplayObject) : flash.display.DisplayObject;
	function addChildAt(child : flash.display.DisplayObject, index : Int) : flash.display.DisplayObject;
	function contains(child : flash.display.DisplayObject) : Bool;
	function getChildAt(index : Int) : flash.display.DisplayObject;
	function getChildByName(name : String) : flash.display.DisplayObject;
	function getChildIndex(child : flash.display.DisplayObject) : Int;
	//function getObjectsUnderPoint(point : flash.geom.Point) : Array<Dynamic>;
	//var numChildren(default,null) : Int;
	function removeChild(child : flash.display.DisplayObject) : flash.display.DisplayObject;
	function removeChildAt(index : Int) : flash.display.DisplayObject;
	function setChildIndex(child : flash.display.DisplayObject, newIndex : Int) : Void;
}
