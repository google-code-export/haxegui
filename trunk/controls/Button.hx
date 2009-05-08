//      Button.hx
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
import flash.filters.BevelFilter;

import CursorManager;

import Reflect;

class Button extends Component, implements Dynamic
{

	public var label : Label;
	public var fmt : TextFormat;
	
	public var color(default, default) : UInt;

	public function new (?parent:DisplayObjectContainer, ?name:String, ?x:Float, ?y:Float)
	{
		super (parent, name, x, y);

	}

	public function init(?initObj:Dynamic)
	{
		if(color == 0)
			color = StyleManager.BACKGROUND;
		
		label = new Label();
		//~ label.init();

		if(Reflect.isObject(initObj))
		{


	for (f in Reflect.fields (initObj))
	  if (Reflect.hasField (this, f))
	    if (f!="label" && f != "width" && f != "height")
	      Reflect.setField (this, f, Reflect.field (initObj, f));
			//~ 
			//~ name = (initObj.name == null) ? name : initObj.name;
			//~ name = (initObj.id == null) ? name : initObj.id;
			label.text = (initObj.label == null) ? name : initObj.label;
			//~ label.init({text:(initObj.label == null) ? name : initObj.label});

			//~ move(initObj.x, initObj.y);
			//~ box.width = ( Math.isNaN(initObj.width) ) ? 90 : initObj.width;
			box.width = ( Math.isNaN(initObj.width) ) ? label.width : initObj.width;
			box.height = ( Math.isNaN(initObj.height) ) ? 30 : initObj.height;
			color = (initObj.color==null) ? color : initObj.color;
			disabled = (initObj.disabled==null) ? disabled : initObj.disabled;
		}


		buttonMode = true;
		tabEnabled = true;
		mouseEnabled = true;
		focusRect = true;

		if(box.isEmpty())
			box = new Rectangle(0,0,90,30);
		//~ else
		//~ if(Math.isNaN(box.width))
			//~ box.width = 90;
		//~ else
		//~ if(Math.isNaN(box.height))
			//~ box.height = 30;
			

		//~ this.graphics.clear();
		//~ this.graphics.lineStyle (2, ~StyleManager.BACKGROUND);
		//~ this.graphics.beginFill (StyleManager.BACKGROUND);
		//~ this.graphics.drawRoundRect (0, 0, box.width, box.height, 8, 8 );
		//~ this.graphics.endFill ();

		// add the drop-shadow filter
		var shadow:DropShadowFilter = new DropShadowFilter (4, 45, StyleManager.DROPSHADOW, 0.8, 4, 4, 0.65, BitmapFilterQuality.HIGH, false, false, false );
		//
		var bevel:BevelFilter = new BevelFilter( 4, 45 ,color | 0x323232 ,1 ,0x000000, .25, 2, 2, 1, BitmapFilterQuality.LOW , flash.filters.BitmapFilterType.INNER, false );

		this.filters = [shadow];
		//~ this.filters = [shadow, bevel];

		label.init();
		//~ label.init({text:name});
		//~ label.move( .5*(this.width - label.width), .5*(this.height - label.height) );
		label.move( Math.floor(.5*(this.box.width - label.width)), Math.floor(.5*(this.box.height - label.height)) );
		this.addChild(label);

		// Listeners
		this.addEventListener (MouseEvent.MOUSE_DOWN, onMouseDown);
		this.addEventListener (MouseEvent.MOUSE_UP,   onMouseUp);
		this.addEventListener (MouseEvent.ROLL_OVER, onRollOver);
		this.addEventListener (MouseEvent.ROLL_OUT,  onRollOut);
		this.addEventListener (KeyboardEvent.KEY_DOWN, onKeyDown);


		// register with focus manager
		//~ FocusManager.getInstance().addEventListener (FocusEvent.MOUSE_FOCUS_CHANGE, onFocusChanged);

		//~ if(color==null || Math.isNaN(color))
			
		redraw();
	}

	/**
	*
	*
	*/
	public function onFocusChanged (e:FocusEvent)
	{
		var color = this.hasFocus ()? StyleManager.BACKGROUND | 0x141414: StyleManager.BACKGROUND;
		redraw (color);
	}


	/**
	*
	*/
	public dynamic function redraw(?color:UInt) : Void
	{
		if(color == 0 || Math.isNaN(color))
			//~ color = StyleManager.BACKGROUND;
			color = this.color;


		this.graphics.clear();
		this.graphics.lineStyle (2, color - 0x141414 );		

		if( disabled ) 
			{
			color = StyleManager.BACKGROUND - 0x141414;
			this.graphics.lineStyle (2, color);		
			 
			fmt = StyleManager.getTextFormat();
			fmt.color = color - 0x202020;
			fmt.align = flash.text.TextFormatAlign.CENTER;
			label.tf.setTextFormat(fmt);
			
			var shadow:DropShadowFilter = new DropShadowFilter (4, 45, StyleManager.DROPSHADOW, 0.2, 4, 4, 0.65, BitmapFilterQuality.HIGH, false, false, false );
			//~ var bevel:BevelFilter = new BevelFilter( 4, 45 ,color | 0x202020 ,1 ,0x000000, .15, 2, 2, 1, BitmapFilterQuality.LOW , flash.filters.BitmapFilterType.INNER, false );
			//~ this.filters = [shadow, bevel];
			this.filters = [shadow];
			
			}
			

		//~ this.graphics.beginFill (color);
		
		  //~ var colors = [ color | 0x1A1A1A, color - 0x1A1A1A ];
   		  //~ var colors = [ color | 0x323232, color - 0x333333 ];
   		  var colors = [ color | 0x323232, color - 0x141414 ];
		  var alphas = [ 100, 100 ];
		  var ratios = [ 0, 0xFF ];
		  var matrix = new flash.geom.Matrix();
		  matrix.createGradientBox(box.width, box.height, Math.PI/2, 0, 0);
		  this.graphics.beginGradientFill( flash.display.GradientType.LINEAR, colors, alphas, ratios, matrix );


		
		this.graphics.drawRoundRect (0, 0, box.width, box.height, 8, 8 );
		this.graphics.endFill ();
		

	}
	/**
	*
	*
	*/
	public function onRollOver(e:MouseEvent) 
	{
		if(disabled) return;
		//~ redraw(StyleManager.BACKGROUND + 0x323232 );
//		redraw(StyleManager.BACKGROUND | 0x141414 );
		//~ redraw(color + 0x141414 );
		//~ redraw(color | 0x323232 );
		redraw(color | 0x4C4C4C );
		CursorManager.getInstance().setCursor(Cursor.HAND);

	}
	/**
	*
	*
	*/
	public function onRollOut(e:MouseEvent) : Void
	{
		if(disabled) return;
			
		redraw();
		CursorManager.getInstance().setCursor(Cursor.ARROW);
	}
	/**
	*
	*
	*/
	public function onMouseDown(e:MouseEvent) : Void 
	{
		if(disabled) return;
			
		//~ trace(Std.string(here)+Std.string(e));
		//~ if(!this.hasFocus())
		FocusManager.getInstance().setFocus(this);

		redraw(color - 0x141414);
		//~ var fmt = StyleManager.getTextFormat();
		//~ fmt.align = flash.text.TextFormatAlign.CENTER;
		//~ fmt.color = ~StyleManager.LABEL_TEXT;
		//~ label.setTextFormat (fmt);
		CursorManager.getInstance().setCursor(Cursor.HAND2);
		
	}

	/**
	*
	*
	*/
	public function onMouseUp(e:MouseEvent) : Void
	{
		if(disabled) return;
		
		redraw(color);

		//~ var fmt = new TextFormat ();
		//~ fmt.align = flash.text.TextFormatAlign.CENTER;
		//fmt.font = "FFF_FORWARD";
		//fmt.font = "Impact";
		//~ fmt.font = "FFF_Manager_Bold";
		//~ fmt.size = 12;
		//~ fmt.color = StyleManager.LABEL_TEXT ;
		//~ label.setTextFormat (fmt);
		CursorManager.getInstance().setCursor(Cursor.HAND);

	}


	public function onKeyDown(e:KeyboardEvent)
	{
		if(disabled) return;
	
		//~ trace(e);
	}


}

