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


import flash.display.DisplayObject;
import flash.display.Sprite;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.MouseEvent;
import flash.events.FocusEvent;

import haxegui.events.MoveEvent;
import haxegui.events.DragEvent;
import haxegui.events.ResizeEvent;

import flash.ui.Mouse;

import haxegui.managers.CursorManager;


/**
*
* Mouse Manager Class (Singleton)
*
* Injects mouse position to fake cursor, leaving the real one free to drag.
*
*
*/
class MouseManager extends EventDispatcher
{

	private static var _instance : MouseManager = null;

	public var listeners:Array<haxegui.ITraceListener>;
	
	public var lastPosition : Point;
	public var delta : Point;

	public var moving : Bool;
	
	//~ public var lock : Bool;

	public static function getInstance ():MouseManager
	{
		if (MouseManager._instance == null)
		{
			MouseManager._instance = new MouseManager ();
		}
		return MouseManager._instance;
	}

	private function new ()
	{
		super ();
	}

	public override function toString () : String
	{
		return "MouseManager";
	}

	public function init() {

		var stage = flash.Lib.current.stage;

		lastPosition = new Point();
		delta = new Point();
		
		//~ CursorManager.getInstance().showCursor();
		stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseEnter, false, 0, true);
		stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseEnter, false, 0, true);
		stage.addEventListener(MouseEvent.MOUSE_UP, onMouseEnter, false, 0, true);
		//~ stage.addEventListener(MouseEvent.MOUSE_UP, function(e){ CursorManager.getInstance().setCursor(Cursor.ARROW); });
		//~ stage.addEventListener(MouseEvent.MOUSE_OUT, function(e){ CursorManager.setCursor(Cursor.ARROW); }, false, 0, true);
		stage.addEventListener(Event.MOUSE_LEAVE, onMouseLeave, false, 0, true);
	}

	public inline function onMouseEnter(e:MouseEvent) : Void {
		/** Show fake cursor **/
		//~ CursorManager.getInstance().showCursor();
		
		/** Calculate new mouse delta **/
		//~ delta = new Point( e.stageX - lastPosition.x, e.stageY - lastPosition.y );
		//~ moving = delta.equals(new Point());  
		
		/** Inject to fake cursor **/
		CursorManager.getInstance().inject(e);
		
		/** Hold to last mouse position **/
		//lastPosition = new Point( e.stageX, e.stageY );

		//~ e.updateAfterEvent();
	}

	public inline function onMouseLeave(e:Event) : Void	{
		//~ trace(e);
		CursorManager.getInstance().hideCursor();
		//~ CursorManager.getInstance()._mc.stopDrag();
	}
	

	
}
