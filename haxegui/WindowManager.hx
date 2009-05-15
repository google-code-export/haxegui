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



/**
* Haxegui Class
*
* @version 0.1
* @author Omer Goshen <gershon@goosemoose.com>
* @author Russell Weir <damonsbane@gmail.com>
*/
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

    //~ window.addEventListener( ResizeEvent.RESIZE, proxy );
    //~ window.addEventListener( MoveEvent.MOVE, proxy );
    //~ window.addEventListener( DragEvent.DRAG_START, proxy );
    //~ window.addEventListener( DragEvent.DRAG_COMPLETE, proxy );



    return window;
  }

//~ 
  //~ public function proxy(e:Dynamic) {
    		//~ for(i in 0...listeners.length) {
                //~ var listener = listeners[i];
				//~ Reflect.callMethod(listener, listener.log, [e]);
                //~ }
    //~ }

}
