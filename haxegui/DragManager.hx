//      DragManager.hx
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

package haxegui;

import flash.geom.Rectangle;

import flash.display.DisplayObject;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.MouseEvent;
import flash.events.FocusEvent;

import haxegui.events.MoveEvent;
import haxegui.events.DragEvent;
import haxegui.events.ResizeEvent;

class DragManager extends EventDispatcher
{

  private static var _instance : DragManager = null;
  public var listeners:Array<ITraceListener>;



  public static function getInstance ():DragManager
  {
	if (DragManager._instance == null)
	  {
		DragManager._instance = new DragManager ();
	  }
	return DragManager._instance;
  }



  public function new ()
  {
	super ();
  }

  public override function toString () : String
  {
	return "DragManager";
  }


   public function onStartDrag(e:DragEvent)
   {
		//~ trace(e);
		    //~ e.stopImmediatePropagation();

		e.target.startDrag();
   }

   public function onStopDrag(e:DragEvent)
   {
		//~ trace(e);
		    //~ e.stopImmediatePropagation();

		e.target.stopDrag();
		//~ flash.Lib.current.removeEventListener(MouseEvent.MOUSE_MOVE, e.target, e.target.onMouseMove);
		//~ e.target.removeEventListener(MouseEvent.MOUSE_MOVE, e.target, e.target.onMouseMove);
   }

}
