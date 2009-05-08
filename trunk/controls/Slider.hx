//      Slider.hx
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
import flash.display.DisplayObjectContainer;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.FocusEvent;

import events.MoveEvent;
import events.ResizeEvent;
import events.DragEvent;



import flash.filters.DropShadowFilter;
import flash.filters.BitmapFilter;
import flash.filters.BitmapFilterQuality;
import flash.filters.BevelFilter;


import CursorManager;
import StyleManager;

class Slider extends Component, implements Dynamic
{
	
  public var handle : Component;
  public var color : UInt;
  //~ public var value : Float;
  public var maxValue : Float;
  

  public function new (?parent:DisplayObjectContainer, ?name:String, ?x:Float, ?y:Float)
	{
		super(parent, name, x, y);
		maxValue = 100;
	}


  /**
   * 
   * 
   * 
   * 
   */
  public function init(?initObj:Dynamic)
	{
		//super.init(initObj);

		box = new Rectangle(0,0,145,30);
		color = StyleManager.BACKGROUND;
		
		if(Reflect.isObject(initObj))
		{
			//~ name = (initObj.name == null) ? name : initObj.name;
			//~ move(initObj.x, initObj.y);
			//~ box.width = ( Math.isNaN(initObj.width) ) ? 30 : initObj.width;
			//~ box.height = ( Math.isNaN(initObj.height) ) ? 30 : initObj.height;
			for(f in Reflect.fields(initObj))
				if(Reflect.hasField(this, f))
					Reflect.setField(this, f, Reflect.field(initObj, f));
			disabled = (initObj.disabled==null) ? disabled : initObj.disabled;
		}

		
		this.graphics.clear();
		this.graphics.lineStyle(4, color - 0x323232);
		this.graphics.moveTo(0, 15);
		this.graphics.lineTo(box.width, 15);

		//~ this.graphics.lineStyle(2, color - 0x202020);
		//~ var s = Std.int(box.width/20);
		//~ for(i in 1...20)
		//~ {
		//~ this.graphics.moveTo(i*s, box.height-10);
		//~ this.graphics.lineTo(i*s, box.height);
		//~ }
		
		this.graphics.lineStyle(0,0,0);
		this.graphics.beginFill(0,0);
		this.graphics.drawRect(0,0,box.width,box.height);
		this.graphics.endFill();
		
	
		handle = new Component(this, "handle");

		handle.graphics.lineStyle(2, color - 0x141414);
		
       		  var colors = [ color | 0x323232, color - 0x141414 ];
		  var alphas = [ 100, 100 ];
		  var ratios = [ 0, 0xFF ];
		  //~ var matrix = { a:200, b:0, c:0, d:0, e:200, f:0, g:200, h:200, i:1 };
		  var matrix = new flash.geom.Matrix();
		  matrix.createGradientBox(15, 30, Math.PI/2, 0, 0);
		  handle.graphics.beginGradientFill( flash.display.GradientType.LINEAR, colors, alphas, ratios, matrix );


		//~ handle.graphics.beginFill(color);
		handle.graphics.drawRoundRect(0,0,15,30,4,4);
		//~ handle.move(0,-15);
		
		// add the drop-shadow filters
		var shadow:DropShadowFilter = new DropShadowFilter (4, 45, StyleManager.DROPSHADOW, 0.8, 4, 4, 0.65, BitmapFilterQuality.HIGH, false, false, false );
		//~ var bevel:BevelFilter = new BevelFilter( 4, 45 ,color | 0x323232 ,1 ,0x000000, .25, 2, 2, 1, BitmapFilterQuality.LOW , flash.filters.BitmapFilterType.INNER, false );

		//~ handle.filters = [shadow, bevel];
		handle.filters = [shadow];


		
		addEventListener (MouseEvent.MOUSE_WHEEL, onMouseWheel);
		
		handle.addEventListener (MouseEvent.MOUSE_DOWN, onMouseDown);
		handle.addEventListener (MouseEvent.MOUSE_UP,   onMouseUp);
		handle.addEventListener (MouseEvent.ROLL_OVER, onRollOver);
		handle.addEventListener (MouseEvent.ROLL_OUT,  onRollOut);
		
		handle.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);	
	
		
		this.addEventListener (Event.CHANGE, onChanged);
	
	}
	
	
	public function onChanged(?e:Event)
	{
	    //~ trace(e);
	    if(handle.x < 0) handle.x = 0;
	    if(handle.x > (box.width - handle.width) ) handle.x = box.width - handle.width;

	}
	

	public function onMouseWheel(e:MouseEvent)
	{
	    //trace(e);
	    handle.x += e.delta * 5;
	    dispatchEvent(new Event(Event.CHANGE));
	}
	

	/**
	*
	*
	*/
	public function onRollOver(e:MouseEvent) : Void
	{
		if(disabled) return;
		//~ redraw(StyleManager.BACKGROUND + 0x323232 );
//		redraw(StyleManager.BACKGROUND | 0x141414 );
		//~ var color = checked ? StyleManager.BACKGROUND - 0x202020 : StyleManager.BACKGROUND;
		//~ redraw(color | 0x202020 );
		redraw(color | 0x4C4C4C );
		
		//~ redraw(color + 0x141414 );
		CursorManager.getInstance().setCursor(Cursor.HAND);

	}

	/**
	*
	*
	*/
	public  function onRollOut(e:MouseEvent) : Void	
	{
		//~ var color = checked ? StyleManager.BACKGROUND - 0x202020 : StyleManager.BACKGROUND;
		redraw(color);
		CursorManager.getInstance().setCursor(Cursor.ARROW);
	}			
	


    public function redraw(color:UInt)
    {
	if(color==0) color = this.color;
		    handle.graphics.clear();
    		handle.graphics.lineStyle(2, color - 0x141414);
		
       		  var colors = [ color | 0x323232, color - 0x141414 ];
		  var alphas = [ 100, 100 ];
		  var ratios = [ 0, 0xFF ];
		  //~ var matrix = { a:200, b:0, c:0, d:0, e:200, f:0, g:200, h:200, i:1 };
		  var matrix = new flash.geom.Matrix();
		  matrix.createGradientBox(15, 30, Math.PI/2, 0, 0);
		  handle.graphics.beginGradientFill( flash.display.GradientType.LINEAR, colors, alphas, ratios, matrix );


		//~ handle.graphics.beginFill(color);
		handle.graphics.drawRoundRect(0,0,15,30,4,4);
		handle.graphics.endFill();
    }
    

  /**
   *
   */
  function onMouseDown (e:MouseEvent) : Void
  {
    
    redraw(color | 0x666666);


    //
    FocusManager.getInstance().setFocus (this);

	handle.startDrag(false,new Rectangle(0,e.target.y, box.width - handle.width ,0));
	//~ e.target.startDrag(false,new Rectangle(0,e.target.y, box.width - handle.width ,0));
	//~ e.target.stage.startDrag(false,new Rectangle(0,e.target.y, box.width - handle.width ,0));

	e.target.stage.addEventListener (MouseEvent.MOUSE_MOVE, onMouseMove);

	}

  public function onMouseMove (e:MouseEvent)
	{
	
	dispatchEvent(new Event(Event.CHANGE));
	//~ onChanged();
	e.updateAfterEvent();
	}
	
  function onMouseUp (e:MouseEvent) : Void
  {
	handle.stopDrag();
	//~ e.target.stopDrag();
	//~ e.target.stage.stopDrag();
	e.target.stage.removeEventListener (MouseEvent.MOUSE_MOVE, onMouseMove);
	
	redraw(color);

  }


}
