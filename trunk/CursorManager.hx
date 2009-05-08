// 
// The MIT License
// 
// Copyright (c) 2004 - 2006 Paul D Turner & The CEGUI Development Team
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

import events.MoveEvent;
import events.DragEvent;
import events.ResizeEvent;

import flash.ui.Mouse;


enum Cursor {
    ARROW;
    HAND;
    HAND2;
    DRAG;
    IBEAM;
    NE;
    NW;
    SIZE_ALL;
}


/**
 * 
 * Cursor Manager Class (Singleton)
 * 
 * 
 * 
 * 
 */
class CursorManager extends EventDispatcher
{
  
  private static var _instance : CursorManager = null;
  
  public var listeners:Array<ITraceListener>;
  public var _cursor : Cursor;
  public var _mc : MovieClip;


  public static function getInstance ():CursorManager
  {
    if (CursorManager._instance == null)
      {
        CursorManager._instance = new CursorManager ();
      }
    return CursorManager._instance;
  }



  private function new ()
  {
    super ();
  }

  public override function toString () : String
  {
    return "CursorManager";
  }

/**
 * 
 * 
 * 
 */
  public function init() {

    Mouse.hide();

    setCursor(Cursor.ARROW);

   
    }
  

    public function getCursor() : MovieClip
    {
        return _mc;
    }
    

    public function inject(x:Float, y:Float) {

        _mc.x = x - 10;
        _mc.y = y - 10;

        switch(_cursor)
        {
            case Cursor.ARROW:
                _mc.x = x - 4;
                _mc.y = y - 2;
            case Cursor.HAND:
                _mc.x = x - 10;
                _mc.y = y - 2;
        }
        
      //~ flash.Lib.current.setChildIndex(_mc, flash.Lib.current.numChildren - 1 );
      toTop();
      
    }//inject

    
    public function toTop() : Void 
    {
      flash.Lib.current.setChildIndex(_mc, flash.Lib.current.numChildren - 1 );
    }//toTop



    /**
     * 
     * 
     * 
     */
    public function setCursor(c:Cursor) {
  
      var point : Point = new Point();
      _cursor = c;
      
      if(_mc!=null) {
        point  = new Point(_mc.x, _mc.y);
        flash.Lib.current.removeChild(_mc);
        }
    
      switch(c) {
        case Cursor.ARROW:
            _mc = load_arrow;

        case Cursor.HAND:
            _mc = load_hand;

        case Cursor.HAND2:
            _mc = load_hand2;

        case Cursor.DRAG:
            _mc = load_drag;

        case Cursor.NE:
            _mc = load_ne;

        case Cursor.NW:
            _mc = load_nw;

        case Cursor.SIZE_ALL:
            _mc = load_sizeall;
      }

    _mc.name = "Cursor";
    _mc.mouseEnabled = false;
    _mc.focusRect = false;
    _mc.tabEnabled = false;

    _mc.width = _mc.height = 48;
    _mc.x = point.x;
    _mc.y = point.y;
  
    var toColor = new flash.geom.ColorTransform(.8, 1, .9, 1, 0, 0, 0, 1);
    var t = new flash.geom.Transform(_mc);
    t.colorTransform = toColor;
    
    flash.Lib.current.addChild(_mc);
     
    //~ _mc.startDrag(true);

 
    }
    
    public function hideCursor() : Void
    {
        _mc.visible = false;
    }

    public function showCursor() : Void
    {
        _mc.visible = true;
    }
    
    public function visible() : Bool
    {
        return  _mc.visible;
    }
    
    
    //~ public function useDefault() {}
    //~ public function useCustom() {}
    
  
   static inline var load_arrow = flash.Lib.attach("Arrow");
   static inline var load_hand = flash.Lib.attach("Hand");
   static inline var load_hand2 = flash.Lib.attach("Hand2");
   static inline var load_drag = flash.Lib.attach("Drag");
   static inline var load_ne = flash.Lib.attach("AngleNE");
   static inline var load_nw = flash.Lib.attach("AngleNW");
   static inline var load_sizeall = flash.Lib.attach("SizeAll");


}
