//      Component.hx
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
