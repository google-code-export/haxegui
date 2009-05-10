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



package haxegui.controls;

import flash.geom.Rectangle;
import flash.geom.Transform;
import flash.geom.ColorTransform;

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

import haxegui.events.MoveEvent;

import flash.filters.DropShadowFilter;
import flash.filters.BitmapFilter;
import flash.filters.BitmapFilterQuality;
import flash.filters.BevelFilter;

import haxegui.StyleManager;
import haxegui.CursorManager;

import Reflect;

import haxegui.controls.Label;


import feffects.Tween;
import feffects.easing.Quint;
import feffects.easing.Sine;
import feffects.easing.Back;
import feffects.easing.Bounce;
import feffects.easing.Circ;
import feffects.easing.Cubic;
import feffects.easing.Elastic;
import feffects.easing.Expo;
import feffects.easing.Linear;
import feffects.easing.Quad;
import feffects.easing.Quart;



/**
 * 
 * Button Class
 * 
 * @version 0.1
 * @author <gershon@goosemoose.com>
 * 
 */
class Button extends Component, implements Dynamic
{

	public var label :Label;
	public var fmt : TextFormat;
	
	public var color(default, default) : UInt;

	public function new (?parent:DisplayObjectContainer, ?name:String, ?x:Float, ?y:Float)
	{
		super (parent, name, x, y);

	}


	/**
	 * Init Function
	 * 
	 * 
	 * @param initObj Dynamic object
	 * 
	 */
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
		var shadow:DropShadowFilter = new DropShadowFilter (4, 45, StyleManager.DROPSHADOW, 0.5, 4, 4, 0.5, BitmapFilterQuality.HIGH, false, false, false );
		//~ var bevel:BevelFilter = new BevelFilter( 4, 45 ,color | 0x323232 ,1 ,0x000000, .25, 2, 2, 1, BitmapFilterQuality.LOW , flash.filters.BitmapFilterType.INNER, false );
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

		var colorTrans: ColorTransform  = new ColorTransform();

		var r = new Tween(0, 50, 350, colorTrans, "redOffset", Expo.easeOut );
		var g = new Tween(0, 50, 350, colorTrans, "greenOffset", Expo.easeOut );
		var b = new Tween(0, 50, 350, colorTrans, "blueOffset", Expo.easeOut );
		//~ 
		r.start();
		g.start();
		b.start();
		
		var self = this;
		r.setTweenHandlers( function ( e ) { self.transform.colorTransform = colorTrans; }  );

		//~ redraw(color | 0x4C4C4C );

		CursorManager.getInstance().setCursor(Cursor.HAND);

	}
	/**
	*
	*
	*/
	public function onRollOut(e:MouseEvent) : Void
	{
		if(disabled) return;
		
		var colorTrans: ColorTransform  = new ColorTransform();
		
		var c = e.buttonDown ? -50 : 50;
		
		var r = new Tween(c, 0, 350, colorTrans, "redOffset", Linear.easeOut );
		var g = new Tween(c, 0, 350, colorTrans, "greenOffset", Linear.easeOut );
		var b = new Tween(c, 0, 350, colorTrans, "blueOffset", Linear.easeOut );
		//~ 
		r.start();
		g.start();
		b.start();
		
		var self = this;
		r.setTweenHandlers( function ( e ) { self.transform.colorTransform = colorTrans; }  );

		
//		CursorManager.getInstance().setCursor(Cursor.ARROW);
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
		//~ FocusManager.getInstance().setFocus(this);

		//~ redraw(color - 0x141414);
		
		var colorTrans: ColorTransform  = new ColorTransform();
			
		var r = new Tween(50, -50, 500, colorTrans, "redOffset", Linear.easeOut );
		var g = new Tween(50, -50, 500, colorTrans, "greenOffset", Linear.easeOut );
		var b = new Tween(50, -50, 500, colorTrans, "blueOffset", Linear.easeOut );
		//~ 
		r.start();
		g.start();
		b.start();
		
		var self = this;
		r.setTweenHandlers( function ( e ) { self.transform.colorTransform = colorTrans; }  );

		
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

		var colorTrans: ColorTransform  = new ColorTransform();
			
		var r = new Tween(-50, 0, 150, colorTrans, "redOffset", Linear.easeNone );
		var g = new Tween(-50, 0, 150, colorTrans, "greenOffset", Linear.easeNone );
		var b = new Tween(-50, 0, 150, colorTrans, "blueOffset", Linear.easeNone );

		
	if(hitTestObject( CursorManager.getInstance().getCursor() ))
		{
		//~ redraw(color | 0x4C4C4C );
		
		r = new Tween(-50, 50, 350, colorTrans, "redOffset", Linear.easeNone );
		g = new Tween(-50, 50, 350, colorTrans, "greenOffset", Linear.easeNone );
		b = new Tween(-50, 50, 350, colorTrans, "blueOffset", Linear.easeNone );

		
		CursorManager.getInstance().setCursor(Cursor.HAND);
		}


		//~ 
		r.start();
		g.start();
		b.start();
		
		var self = this;
		r.setTweenHandlers( function ( e ) { self.transform.colorTransform = colorTrans; }  );


	}


	public function onKeyDown(e:KeyboardEvent)
	{
		if(disabled) return;
	
		//~ trace(e);
	}


}

