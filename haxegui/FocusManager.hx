//      FocusManager.hx
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

import flash.display.Sprite;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.MouseEvent;
import flash.events.FocusEvent;



class FocusManager extends EventDispatcher, implements Dynamic
{
  

  private static var _instance:FocusManager = null;
  
  private static var _focus: DisplayObject; 
  private static var _oldFocus: DisplayObject; 
  
  private static var _showFocus : Bool;
  
  
  
  public static function getInstance ():FocusManager
  {
    if (FocusManager._instance == null)
      {
        FocusManager._instance = new FocusManager ();
      }
    return FocusManager._instance;
  }



  public function new ()
  {
    super ();
    this.addEventListener (FocusEvent.MOUSE_FOCUS_CHANGE, onFocusChanged);
    this.addEventListener (FocusEvent.KEY_FOCUS_CHANGE, onFocusChanged);
    this.addEventListener (FocusEvent.FOCUS_IN, onFocusChanged);
    this.addEventListener (FocusEvent.FOCUS_OUT, onFocusChanged);
  }

  public override function toString () : String
  {
    return "FocusManager";
  }

  public function setFocus (o:DisplayObject)
  {
    if( o!=null && _focus!=o )
    {
        if(_focus!=null)
        //~ _focus.dispatchEvent (new FocusEvent (FocusEvent.FOCUS_OUT, false, true));
        _focus.dispatchEvent (new FocusEvent (FocusEvent.FOCUS_OUT));
        
        _oldFocus = _focus;
        _focus = o;
        
        //~ this.dispatchEvent (new FocusEvent (FocusEvent.MOUSE_FOCUS_CHANGE, false, false, cast(o,flash.display.InteractiveObject)));
        this.dispatchEvent (new FocusEvent (FocusEvent.MOUSE_FOCUS_CHANGE));
        this.dispatchEvent (new FocusEvent (FocusEvent.KEY_FOCUS_CHANGE));
        
        _focus.addEventListener (FocusEvent.FOCUS_OUT, onFocusChanged);
        _focus.addEventListener (FocusEvent.FOCUS_IN, onFocusChanged);
        _focus.dispatchEvent (new FocusEvent (FocusEvent.FOCUS_IN, false, false));
        
    }
  }

    


  public function getFocus ():DisplayObject
  {
    return _focus;
  }

  public function onFocusChanged(e:FocusEvent) : Void {
    //~ trace(e.type+" "+e.target+"::"+e.target.name);
/*
   if(e.type==FocusEvent.FOCUS_IN) {
   
    var focusRect = new Sprite();
    focusRect.name = "_focusRect";
    
    var com = cast(_focus, Component);    
    var rect = com.box.clone();
    focusRect.graphics.lineStyle(2, 0xffff00, .5);
    focusRect.graphics.drawRect(-5, -5, rect.width+10, rect.height+10);
    
    var obj = cast(_focus, DisplayObjectContainer);
    if(obj.numChildren>=1)
        obj.addChildAt(focusRect, obj.numChildren-1);
    else
        obj.addChild(focusRect);
    //~ flash.Lib.current.addChildAt(focusRect, _focus.numChildren-1);
    }
   if(e.type==FocusEvent.FOCUS_OUT) {
    var obj = cast(_focus, DisplayObjectContainer);
    if(obj.numChildren>=1)
    if(obj.getChildByName("_focusRect")!=null)
        obj.removeChild(obj.getChildByName("_focusRect"));
    
    //~ dispatchEvent (new FocusEvent (FocusEvent.MOUSE_FOCUS_CHANGE));
    }
*/   
  }//onFocusChanged
  
}//FocusManager
