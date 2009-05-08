//      IChildList.hx
//      
//      Copyright 2009 gershon <gershon@yellow>
//      
//      This program is free software; you can redistribute it and/or modify
//      it under the terms of the GNU General Public License as published by
//      the Free Software Foundation; either version 2 of the License, or
//      (at your option) any later version.
//      
//      This program is distributed in the hope that it will be useful,
//      but WITHOUT ANY WARRANTY; without even the implied warranty of
//      MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//      GNU General Public License for more details.
//      
//      You should have received a copy of the GNU General Public License
//      along with this program; if not, write to the Free Software
//      Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
//      MA 02110-1301, USA.

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
