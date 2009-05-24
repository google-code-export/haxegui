// Copyright (c) 2009 The haxegui developers
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of
// this software and associated documentation files (the "Software"), to deal in
// the Software without restriction, including without limitation the rights to
// use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
// the Software, and to permit persons to whom the Software is furnished to do so,
// subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
// FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
// IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

package haxegui.managers;


import flash.geom.Point;
import flash.geom.Rectangle;
import flash.geom.Transform;

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.display.MovieClip;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.MouseEvent;
import flash.events.FocusEvent;

import haxegui.events.MoveEvent;
import haxegui.events.DragEvent;
import haxegui.events.ResizeEvent;

import flash.ui.Mouse;


enum Cursor {
	ARROW;
	HAND;
	HAND2;
	DRAG;
	IBEAM;
	NESW;
	NS;
	NWSE;
	WE;
	SIZE_ALL;
	CROSSHAIR;
}


/**
*
* Cursor Manager Class (Singleton)
* 
* @version 0.1
* @author Omer Goshen <gershon@goosemoose.com>
* @author Russell Weir <damonsbane@gmail.com>
*/
class CursorManager extends EventDispatcher
{

	private static var _instance : CursorManager = null;


	///////////////////////////////////////////////////
	////              Public                       ////
	///////////////////////////////////////////////////
	public var listeners:Array<haxegui.ITraceListener>;
	public var cursor(default,__setCursor) : Cursor;
	public var visible(__getVisible,__setVisible) : Bool;
	public var _mc(default,null) : MovieClip;
	public var lock : Bool;
	
	/** Singleton private constructor **/
	private function new ()
	{
		super ();
	}

	/** Singleton access **/
	public static function getInstance ():CursorManager
	{
		if (CursorManager._instance == null)
		{
			CursorManager._instance = new CursorManager ();
		}
		return CursorManager._instance;
	}



	public override function toString () : String
	{
		return "CursorManager";
	}

	/**
	*
	*/
	public function init() {
		//~ Mouse.hide();
		cursor = Cursor.ARROW;
	}

	public static function setCursor(c:Cursor) : Void
	{
		if(getInstance().lock) return;
		getInstance().cursor = c;
	}

	private function getCursor() : MovieClip
	{
		return _mc;
	}

	public function inject(e:MouseEvent) {

		var p = new Point( e.stageX, e.stageY );

		switch(cursor)
		{
			default:
				p.offset(-10,-10);
				
			case Cursor.ARROW:
				p.offset(-6,-3);

			case Cursor.HAND, Cursor.HAND2, Cursor.DRAG:
				p.offset(-14,-2);

			case Cursor.CROSSHAIR:
				p.offset(-23,-17);
				
			case Cursor.NESW, Cursor.NWSE:
				p.offset(-18,-17);

			case Cursor.WE, Cursor.NS:
				p.offset(-23, -17);

		}

		_mc.x = p.x;
		_mc.y = p.y;
		
		showCursor();
		toTop();

		e.updateAfterEvent();

	}//inject


	public function toTop() : Void
	{
		flash.Lib.current.setChildIndex(_mc, flash.Lib.current.numChildren - 1 );
	}//toTop


	public function hideCursor() : Void
	{
		_mc.visible = false;
	}

	public function showCursor() : Void
	{
		_mc.visible = true;
	}

	///////////////////////////////////////////////////
	////             Privates                      ////
	///////////////////////////////////////////////////
	private function __getVisible() : Bool {
		return  _mc.visible;
	}

	/**
	*
	*/
	private function __setCursor(c:Cursor) : Cursor
	{
		var point : Point = new Point();
		cursor = c;

		if(_mc!=null) {
			point  = new Point(_mc.x, _mc.y);
			flash.Lib.current.removeChild(_mc);
		}

		switch(c) {
			case Cursor.ARROW:
				_mc = img_arrow;

			case Cursor.HAND:
				_mc = img_hand;

			case Cursor.HAND2:
				_mc = img_hand2;

			case Cursor.DRAG:
				_mc = img_drag;

			case Cursor.SIZE_ALL:
				_mc = img_sizeall;

			case Cursor.NESW:
				_mc = img_nesw;

			case Cursor.NS:
				_mc = img_ns;

			case Cursor.NWSE:
				_mc = img_nwse;

			case Cursor.WE:
				_mc = img_we;

			case Cursor.CROSSHAIR:
				_mc = img_crosshair;
		}

		_mc.name = "Cursor";
		_mc.mouseEnabled = false;
		_mc.focusRect = false;
		_mc.tabEnabled = false;

		_mc.width = _mc.height = 48;
		//~ _mc.x = point.x;
		//~ _mc.y = point.y;
		//~ inject( new MouseEvent(MouseEvent.MOUSE_MOVE) );

		var toColor = new flash.geom.ColorTransform(.8, 1, .9, 1, 0, 0, 0, 1);
		var t = new flash.geom.Transform(_mc);
		t.colorTransform = toColor;

		flash.Lib.current.addChild(_mc);

		//~ _mc.startDrag(true);
		return c;
	}

	private function __setVisible(v:Bool) : Bool {
		_mc.visible = v;
		return v;
	}

	//~ public function useDefault() {}
	//~ public function useCustom() {}

	/** The default arrow cursor image **/
	public static var img_arrow = flash.Lib.attach("Arrow");
	/** The hand type cursor image **/
	public static var img_hand = flash.Lib.attach("Hand");
	/** The hand press/grab image **/
	public static var img_hand2 = flash.Lib.attach("Hand2");
	/** The drag cursor image **/
	public static var img_drag = flash.Lib.attach("Drag");
	/** The All Direction resizer image **/
	public static var img_sizeall = flash.Lib.attach("SizeAll");
	/** The   resizer image **/
	public static var img_nesw = flash.Lib.attach("SizeNESW");
	/** The   resizer image **/
	public static var img_ns = flash.Lib.attach("SizeNS");
	/** The   resizer image **/
	public static var img_nwse = flash.Lib.attach("SizeNWSE");
	/** The   resizer image **/
	public static var img_we = flash.Lib.attach("SizeWE");
	/** The crosshair cursor image **/
	public static var img_crosshair = flash.Lib.attach("Crosshair");
}
