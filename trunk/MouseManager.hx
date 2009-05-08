//      MouseManager.hx
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


import flash.geom.Point;
import flash.geom.Rectangle;


import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.display.MovieClip;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.MouseEvent;
import flash.events.FocusEvent;

import events.MoveEvent;
import events.DragEvent;
import events.ResizeEvent;

import flash.ui.Mouse;



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
  public var listeners:Array<ITraceListener>;



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
        
        //~ CursorManager.getInstance().showCursor();      


        stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
        stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
        stage.addEventListener(Event.MOUSE_LEAVE, onMouseLeave);
    }
    
    
    public inline function onMouseMove(e:MouseEvent) : Void
    {
    //~ if(!CursorManager.getInstance().visible())
    CursorManager.getInstance().showCursor();
    //~ CursorManager.getInstance().showCursor();      
    CursorManager.getInstance().inject( e.stageX, e.stageY );    
    //~ flash.Lib.current.getChildByName("Cursor").startDrag (true);
    //~ CursorManager.getInstance().getCursor().startDrag(true);
    //~ Mouse.hide();
    e.updateAfterEvent();
    }

    
    public inline function onMouseDown(e:MouseEvent) : Void 
    {
      CursorManager.getInstance().toTop();
    }

    public inline function onMouseLeave(e:Event) : Void 
    {
      //~ trace(e);
      CursorManager.getInstance().hideCursor();      
        CursorManager.getInstance().getCursor().stopDrag();
      
    }
}
