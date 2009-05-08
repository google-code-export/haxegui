//      RadioButton.hx
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

import controls.Component;

class RadioButton extends Component, implements Dynamic
{

  //~ public var group : 
  public var checked(default, default) : Bool;
  public var label : Label;
  public var color : UInt;

  var button : Sprite;

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
		}


		
		button = new Sprite();
		button.name="button";
		button.graphics.lineStyle (2, color - 0x202020);
		button.graphics.beginFill (color);
		button.graphics.drawCircle (15, 15, 15);
		button.graphics.endFill ();
		this.addChild(button);

		// drop-shadow filter
		//~ var shadow:DropShadowFilter = new DropShadowFilter (4, 45, StyleManager.DROPSHADOW, 0.8, 4, 4, 0.65, BitmapFilterQuality.HIGH, false, false, false );
		var shadow:DropShadowFilter = new DropShadowFilter (4, 45, StyleManager.DROPSHADOW, 0.8, 4, 4, 0.65, BitmapFilterQuality.HIGH, true, false, false );
		this.filters = [shadow];


		label = new Label();
		label.text = name;
		label.init({text: name});
		label.move(40, 6);
		//~ label.name = "label";
		//~ label.text = name;
		//~ label.selectable = false;
		//~ label.multiline = false;
		//~ label.embedFonts = true;
		//~ label.width = box.width - 40;
		//~ label.height = box.height - 6;
		//~ label.x = 40;
		//~ label.y = 6;

		//~ label.setTextFormat (StyleManager.getTextFormat(10));
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
	 */
	public  function redraw(?color:UInt) : Void {

		if(color == 0 || Math.isNaN(color))
			color = StyleManager.BACKGROUND;
			
				
		if( disabled ) 
			{
			color = StyleManager.BACKGROUND - 0x141414;
			var fmt = StyleManager.getTextFormat();
			fmt.color = color - 0x202020;
			fmt.align = flash.text.TextFormatAlign.CENTER;
			label.tf.setTextFormat(fmt);
			
			
			//~ var shadow:DropShadowFilter = new DropShadowFilter (4, 45, StyleManager.DROPSHADOW, 0.2, 4, 4, 0.65, BitmapFilterQuality.HIGH, false, false, false );
			var shadow:DropShadowFilter = new DropShadowFilter (4, 45, StyleManager.DROPSHADOW, 0.2, 4, 4, 0.65, BitmapFilterQuality.HIGH, true, false, false );
			this.filters = [shadow];
			
			}
				
			
		button.graphics.clear();
		button.graphics.lineStyle (2, color - 0x202020);
		button.graphics.beginFill (color);
		button.graphics.drawCircle (15, 15, 15);
		button.graphics.endFill ();

	}

	/**
	*
	*
	*/
	public function onRollOver(e:MouseEvent) : Void
	{
		//~ if(disabled) return;
		//~ if(!Std.is(e.target,Sprite)) return;
	
		var color : UInt= checked ? color - 0x202020 : color;
		redraw(color + 0x141414 );
		CursorManager.getInstance().setCursor(Cursor.HAND);

	}

	/**
	*
	*
	*/
	public  function onRollOut(e:MouseEvent) : Void	
	{
		var color = checked ? StyleManager.BACKGROUND - 0x202020 : StyleManager.BACKGROUND;
		redraw(color);
		CursorManager.getInstance().setCursor(Cursor.ARROW);
	}	
	
	/**
	*
	*
	*/
	public  function onMouseDown(e:MouseEvent) : Void	
	{
		//~ if(disabled) return;
		
		//~ trace(Std.string(here)+Std.string(e));
		//~ if(!this.hasFocus())
		FocusManager.getInstance().setFocus(this);

		redraw(StyleManager.BACKGROUND - 0x141414);
		
		for(i in 0...parent.numChildren)
			{
				var child = parent.getChildAt(i);
				if(Std.is(child, RadioButton))
					if(child!=this)
						{
						//~ trace(child);
						untyped
							{
							child.checked = false;
							child.redraw();
							}
						}
			}
	}

	/**
	*
	*
	*/
	public  function onMouseUp(e:MouseEvent) {
		checked = !checked;

		//~ redraw(StyleManager.BACKGROUND);
		var color = checked ? StyleManager.BACKGROUND - 0x202020 : StyleManager.BACKGROUND;
		redraw(color);
	}
	
}
