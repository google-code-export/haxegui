//      CheckBox.hx
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

import flash.text.TextField;
import flash.text.TextFormat;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.KeyboardEvent;
import flash.events.FocusEvent;

import events.MoveEvent;

import flash.filters.DropShadowFilter;
import flash.filters.BitmapFilter;
import flash.filters.BitmapFilterQuality;

import CursorManager;
import StyleManager;

class CheckBox extends Component, implements Dynamic
{

  public var checked(default, default) : Bool;
  public var label : TextField;
  //~ public var button : Button;
  public var button : Sprite;
  public var color : UInt;


  public function new (?parent:DisplayObjectContainer, ?name:String, ?x:Float, ?y:Float)
	{
		super(parent, name, x, y);
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

		box = new Rectangle(0,0,140,30);
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
			//~ disabled = (initObj.disabled==null) ? disabled : initObj.disabled;
		}


		//~ this.graphics.clear();
		button = new Sprite();
		button.name = "button";
		button.graphics.lineStyle (2, color - 0x202020);
		button.graphics.beginFill (color);
		button.graphics.drawRoundRect (0, 0, 30, box.height, 8, 8 );
		button.graphics.endFill ();
		this.addChild(button);
		
		// add the drop-shadow filter
		var shadow:DropShadowFilter = new DropShadowFilter (4, 45, StyleManager.DROPSHADOW, 0.5, 4, 4, 0.5, BitmapFilterQuality.HIGH, true, false, false );
		this.filters = [shadow];


		label = new TextField();
		label.name = "label";
		label.text = name;
		label.selectable = false;
		label.multiline = false;
		label.embedFonts = true;
		label.width = box.width - 40;
		label.height = box.height - 6;
		label.x = 40;
		label.y = 6;
		
		label.mouseEnabled = false;
		label.tabEnabled = false;
		label.focusRect = false;

		label.setTextFormat (StyleManager.getTextFormat());

		this.addChild(label);


		// Listeners
		button.addEventListener (MouseEvent.MOUSE_DOWN, onMouseDown);
		button.addEventListener (MouseEvent.MOUSE_UP,   onMouseUp);
		button.addEventListener (MouseEvent.ROLL_OVER, onRollOver);
		button.addEventListener (MouseEvent.ROLL_OUT,  onRollOut);
		//~ this.addEventListener (KeyboardEvent.KEY_DOWN, onKeyDown);

		this.addEventListener (Event.ACTIVATE, onEnabled);
		this.addEventListener (Event.DEACTIVATE, onDisabled);
		
		if(disabled)
			dispatchEvent(new Event(Event.DEACTIVATE));


		redraw();

	}

	/**
	 * 
	 * 
	 */
	public function onDisabled(e:Event)
	{
		button.mouseEnabled = false;
		button.buttonMode = false;
		//~ tabEnabled = false;
		redraw();
	}
	
	/**
	 * 
	 * 
	 */
	public function onEnabled(e:Event)
	{
		button.mouseEnabled = true;
		button.buttonMode = true;
		//~ tabEnabled = false;
		redraw();
	}

	/**
	 *
	 * 
	 */
	public function redraw(?color:UInt) : Void {

		
		if(color==0 || Math.isNaN(color))
			color = StyleManager.BACKGROUND;
				//~ color = checked ? StyleManager.BACKGROUND - 0x202020 : StyleManager.BACKGROUND;
	

		if( disabled ) 
			{
			//~ color = StyleManager.BACKGROUND - 0x141414;
			//~ color = StyleManager.BACKGROUND ;
			var fmt = StyleManager.getTextFormat();
			fmt.color = color - 0x202020;
			fmt.align = flash.text.TextFormatAlign.CENTER;
			label.setTextFormat(fmt);
			
			//~ var shadow:DropShadowFilter = new DropShadowFilter (4, 45, StyleManager.DROPSHADOW, 0.2, 4, 4, 0.65, BitmapFilterQuality.HIGH, false, false, false );
			var shadow:DropShadowFilter = new DropShadowFilter (4, 45, StyleManager.DROPSHADOW, 0.2, 4, 4, 0.65, BitmapFilterQuality.HIGH, true, false, false );
			this.filters = [shadow];
			}
				
			
		button.graphics.clear();
		button.graphics.lineStyle (2, disabled ? color - 0x191919 : color - 0x333333 );

		if(checked)
		{
		//~ button.graphics.lineStyle (2, color - 0x202020);

			var colors = [ color | 0x323232, color - 0x141414 ];
			var alphas = [ 100, 0 ];
			var ratios = [ 0, 0xFF ];
			var matrix = new flash.geom.Matrix();
			matrix.createGradientBox(30, 30, Math.PI/2, 0, 0);
			button.graphics.beginGradientFill( flash.display.GradientType.LINEAR, colors, alphas, ratios, matrix );    
			button.graphics.drawRoundRect (0, 0, 30, box.height, 8, 8 );
		

		button.graphics.lineStyle (4, color - 0x333333);
		button.graphics.moveTo (8, 8);
		button.graphics.lineTo (22, 22);
		button.graphics.moveTo (22, 8);
		button.graphics.lineTo (8, 22);		

		}
		else
		{
		//~ button.graphics.lineStyle (2, color - 0x202020);

			var colors = [ color - 0x141414, color | 0x323232 ];
			var alphas = [ 100, 0 ];
			var ratios = [ 0, 0xFF ];
			var matrix = new flash.geom.Matrix();
			matrix.createGradientBox(30, 30, Math.PI/2, 0, 0);
			button.graphics.beginGradientFill( flash.display.GradientType.LINEAR, colors, alphas, ratios, matrix );    
		
		//~ button.graphics.beginFill (color);
		button.graphics.drawRoundRect (0, 0, 30, box.height, 8, 8 );
		
		}


		button.graphics.endFill ();
		

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
		redraw(color | 0x202020 );
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
	
	/**
	*
	*
	*/
	public  function onMouseDown(e:MouseEvent) : Void	
	{
		if(disabled) return;
		
		//~ trace(Std.string(here)+Std.string(e));
		//~ if(!this.hasFocus())
		FocusManager.getInstance().setFocus(this);

		redraw(StyleManager.BACKGROUND - 0x141414);
	
	}

	/**
	*
	*
	*/
	public  function onMouseUp(e:MouseEvent) {
		checked = !checked;

		//~ redraw(StyleManager.BACKGROUND);
		//~ var color = checked ? StyleManager.BACKGROUND - 0x202020 : StyleManager.BACKGROUND;
		redraw(color);
	}
	
}
