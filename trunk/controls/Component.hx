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



package controls;

import flash.geom.Rectangle;

import flash.display.Sprite;
import flash.display.MovieClip;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;

import flash.events.Event;
import flash.events.MouseEvent;

import events.MoveEvent;
import events.ResizeEvent;


class Component extends Sprite, implements IMovable, implements IToolTip, implements Dynamic
//~ implements haxe.rtti.Infos
{
	
  public var box : Rectangle;
  public var disabled : Bool;
  public var validate : Bool;
  public var text : String;
  
  public var margin : Array<Float>;
  //~ public var padding : Array<Float>;
  //~ public var getBox : Void -> Rectangle;
  
  public function new (?parent:DisplayObjectContainer, ?name:String, ?x:Float, ?y:Float)
  {
    super ();
        
    tabEnabled = mouseEnabled = buttonMode = true;
    
    if(name!=null)
        this.name = name;

   
    if(parent!=null)
        parent.addChild(this);

    box = new Rectangle();
    
    text = name;
    disabled = false;
        
    move(x,y);
    
    //~ trace("New " + this);
  }



  
	/**
	 * 
	 */
  //~ public function move (x : Float, y : Float) : Void
  public inline function move (x : Float, y : Float) : Void
  {
    var event = new MoveEvent(MoveEvent.MOVE);
    event.oldX = this.x;
    event.oldY = this.y;
    this.x += x;
    this.y += y;
    box.offset(x,y);
    dispatchEvent(event);
  }

    /**
     * 
     */
    public function setBox(b:Rectangle) : Rectangle
    {
        var event = new ResizeEvent(ResizeEvent.RESIZE);
        event.oldWidth = box.width;
        event.oldHeight = box.height;
        box = b.clone();
        dispatchEvent(event);
        //~ trace(event);
        return box;
    }
    

    
//TODO: recurse, that is check all children's children too..
  public function hasFocus ():Bool
  {
    if (FocusManager.getInstance ().getFocus () == this )
      return true;
    else
      return false;
  }

    
    
  public function isValid() : Bool
  {
      return true;
  }
  
    


}
