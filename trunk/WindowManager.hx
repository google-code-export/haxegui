//      WindowManager.hx
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

import flash.geom.Rectangle;


import flash.display.DisplayObject;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.MouseEvent;
import flash.events.FocusEvent;

import events.MoveEvent;
import events.DragEvent;
import events.ResizeEvent;

class WindowManager extends EventDispatcher
{

  public var numWindows : UInt;
  public var listeners:Array<ITraceListener>;

  public var windows : IntHash<Window>;
  
  private static var _instance : WindowManager = null;
  


  public static function getInstance ():WindowManager
  {
    if (WindowManager._instance == null)
      {
        WindowManager._instance = new WindowManager ();
      }
    return WindowManager._instance;
  }



  public function new ()
  {
    super ();
    listeners = new Array();
    windows = new IntHash();
    numWindows = 0;
  }

  public override function toString () : String
  {
    return "WindowManager";
  }


  public function addWindow(?parent:Dynamic) {
    numWindows++;
    
    if(parent==null)
        parent = flash.Lib.current;

    var window =  new Window(parent);
    windows.set(numWindows, window);
    
    window.addEventListener( ResizeEvent.RESIZE, proxy );
    window.addEventListener( MoveEvent.MOVE, proxy );    
    //~ window.addEventListener( DragEvent.DRAG_START, proxy );        
    //~ window.addEventListener( DragEvent.DRAG_COMPLETE, proxy );        

    
    
    return window;
  }
  
  
  public function proxy(e:Dynamic) {
      //~ dispatchEvent(e);
    		for(i in 0...listeners.length) {
                var listener = listeners[i];
				Reflect.callMethod(listener, listener.log, [e]);
                }
    }
  
}
