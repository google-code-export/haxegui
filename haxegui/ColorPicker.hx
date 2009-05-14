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

import Type;

import flash.geom.Rectangle;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.MovieClip;
import flash.display.Graphics;
import flash.display.Shape;
import flash.display.Sprite;
import flash.display.LineScaleMode;

import flash.text.TextField;
import flash.text.TextFormat;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.KeyboardEvent;
import flash.events.FocusEvent;
import flash.events.EventDispatcher;

import flash.ui.Keyboard;

import haxegui.events.MoveEvent;
import haxegui.events.ResizeEvent;
import haxegui.events.DragEvent;
import haxegui.events.MenuEvent;

import flash.ui.Mouse;

import flash.Error;
import haxe.Timer;
//~ import flash.utils.Timer;

import flash.display.Bitmap;
import flash.display.BitmapData;

import haxegui.CursorManager;


import flash.filters.DropShadowFilter;
import flash.filters.BitmapFilter;
import flash.filters.BitmapFilterQuality;

import haxegui.StyleManager;
import haxegui.controls.Button;
import haxegui.controls.Slider;
import haxegui.controls.Stepper;
import haxegui.controls.Input;

/**
*
*
*
*
*/
class ColorPicker extends Window
{
	var colSprite : Sprite;
	var currentColor : UInt;
	var input : Input;


	/**
	*
	*/
	public function new (?parent:DisplayObjectContainer, ?x:Float, ?y:Float)
	{
		super (parent, x, y);

	}

	public override function init(?initObj:Dynamic)
	{
		super.init({name:"ColorPicker", x:x, y:y, width:width, height:height, sizeable:false, color: 0xE6D3CC});

		box = new Rectangle (0, 0, 400, 280);

		//
		var menubar = new Menubar (this, "Menubar", 10,20);
		menubar.init ();

		//
		var container = new Container (this, "Container", 10, 44);
		container.init({color: 0xE6D3CC});

		var spec = new Image(container, "Spectrum", 10, 10);
		spec.init({src: "haxegui/assets/spectrum.png"});

		var self = this;
		spec.addEventListener(Event.COMPLETE,
		function(e)
			{
			spec.graphics.lineStyle(4, self.color - 0x141414);
			spec.graphics.beginFill(0xffffff);
			spec.graphics.drawRect(0,0,spec.width,spec.height);
			spec.graphics.endFill();
			});

		var shadow:DropShadowFilter = new DropShadowFilter (4, 45, DefaultStyle.DROPSHADOW, 0.5,4, 4,0.75,BitmapFilterQuality.HIGH,true,false,false);
		spec.filters = [shadow];

		spec.addEventListener(MouseEvent.MOUSE_DOWN, onMouseMoveImage);
		spec.addEventListener(MouseEvent.MOUSE_UP, onMouseUpImage);
		spec.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMoveImage);


		colSprite =  new Sprite();
		colSprite.graphics.lineStyle(2, color - 0x141414);
		colSprite.graphics.beginFill(0);
		colSprite.graphics.drawRect(0,0,40,30);
		colSprite.graphics.endFill();
		colSprite.x = 180;
		colSprite.y = 10;

		var shadow:DropShadowFilter = new DropShadowFilter (4, 45, DefaultStyle.DROPSHADOW, 0.5,4, 4,0.75,BitmapFilterQuality.HIGH,true,false,false);
		colSprite.filters = [shadow];

		container.addChild(colSprite);


		input = new Input(container, "Input", 230, 10);
		input.init({height: 30});
		input.tf.text = "0x000000";
		input.tf.y += 4;

		//~ redraw (null);
		//~ menubar.redraw();

		//
		for(i in 1...4)
		{


			var slider = new Slider(container, "Slider"+i);
			slider.init({width: 128, color: 0xE6D3CC});
			slider.move(180, 10+40*i);

			var stepper = new Stepper(container, "Stepper"+i);
				stepper.init({step: 1, max: 255, color: 0xE6D3CC});
			//~ stepper.init();
			stepper.move(330, 10+40*i);

			var me = this;
			slider.addEventListener(Event.CHANGE, function(e:Event) { stepper.value=2*e.target.handle.x; stepper.dispatchEvent(new Event(Event.CHANGE)); me.updateColor(); });
			stepper.addEventListener(Event.CHANGE, function(e:Event) { slider.handle.x = .5*e.target.value; me.updateColor(); });

		}

		var button = new Button(container, "Ok", 180, 190);
		button.init({color: 0xE6D3CC});

		var button = new Button(container, "Cancel", 290, 190);
		button.init({color: 0xE6D3CC});


		if(isSizeable())
		{
			bl.y = frame.height - 32;
			br.x = frame.width - 32;
			br.y = frame.height - 32;
		}


		this.addEventListener(MouseEvent.ROLL_OVER, onRollOver);
		this.addEventListener(MouseEvent.ROLL_OUT, onRollOut);
		//~ this.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);

		//~ redraw(null);
		dispatchEvent(new ResizeEvent(ResizeEvent.RESIZE));
	}



	public override function onResize (e:ResizeEvent) : Void
	{


		super.onResize(e);

		e.stopImmediatePropagation ();
		//~ e.stopPropagation ();


		//~ if( this.getChildByName("Container")!=null )
		//~ {
		//~ var container = cast this.getChildByName("Container");
		//~ container.onResize(e);
		//~ }


		if( this.getChildByName("Menubar")!=null )
		{
		var menubar = untyped this.getChildByName("Menubar");
		menubar.onResize(e);
		//~ menubar.dispatchEvent(e.clone());
		}

		//~ dispatchEvent(new ResizeEvent(ResizeEvent.RESIZE));
	}



	public override function onRollOver(e:MouseEvent)  : Void
	{
		CursorManager.setCursor(Cursor.HAND);
	}

	public override function onRollOut(e:MouseEvent)
	{
	}


	public  function onMouseUpImage(e:MouseEvent)  : Void
	{
		if(e.target.hitTestObject( CursorManager.getInstance()._mc ))
			CursorManager.setCursor(Cursor.HAND);
	}



	public function onMouseMoveImage(e:MouseEvent)
	{

		if(!Std.is(e.target, Image) || !e.buttonDown ) return;


			CursorManager.setCursor(Cursor.CROSSHAIR);
			//~ trace(e.target.getChildAt(0).bitmapData.getPixel(e.localX, e.localY));
			currentColor = e.target.getChildAt(0).bitmapData.getPixel(e.localX, e.localY);

			var r = currentColor >> 16 ;
			var g = currentColor >> 8 & 0xFF ;
			var b = currentColor & 0xFF ;

			untyped this.getChildByName("Container").getChildByName("Slider1").handle.x = .5*r ;
			untyped this.getChildByName("Container").getChildByName("Slider1").dispatchEvent(new Event(Event.CHANGE));

			untyped this.getChildByName("Container").getChildByName("Slider2").handle.x = .5*g;
			untyped this.getChildByName("Container").getChildByName("Slider2").dispatchEvent(new Event(Event.CHANGE));

			untyped this.getChildByName("Container").getChildByName("Slider3").handle.x = .5*b;
			untyped this.getChildByName("Container").getChildByName("Slider3").dispatchEvent(new Event(Event.CHANGE));

			//~ colSprite.graphics.clear();
			//~ colSprite.graphics.lineStyle(2, 0);
			//~ colSprite.graphics.beginFill(currentColor);
			//~ colSprite.graphics.drawRect(0,0,40,30);
			//~ colSprite.graphics.endFill();

	}

	public function updateColor()
	{
		var r = 1 + 2 * untyped this.getChildByName("Container").getChildByName("Slider1").handle.x ;
		var g = 1 + 2 * untyped this.getChildByName("Container").getChildByName("Slider2").handle.x ;
		var b = 1 + 2 * untyped this.getChildByName("Container").getChildByName("Slider3").handle.x ;

		//~ r = r & 0xFF >> 16 ;
		//~ g = g & 0x00FF >> 8 ;
		//~ b = b   ;
		//~ trace(r+","+g+","+b);

		currentColor = r | g | b;
		currentColor  = (r << 16) | (g << 8) | b;
		colSprite.graphics.clear();
		colSprite.graphics.lineStyle(2, color - 0x141414);
		colSprite.graphics.beginFill(currentColor);
		colSprite.graphics.drawRect(0,0,40,30);
		colSprite.graphics.endFill();

		updateInput();

	}

	public function updateInput()
	{
		input.tf.text = "0x"+StringTools.hex(currentColor);
		input.tf.setTextFormat( DefaultStyle.getTextFormat() );
	}

}
