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

import flash.geom.Rectangle;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;

import flash.text.TextField;
import flash.text.TextFormat;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.KeyboardEvent;
import flash.events.FocusEvent;

import haxegui.events.MoveEvent;
import haxegui.events.ResizeEvent;
import haxegui.events.DragEvent;
import haxegui.events.MenuEvent;

import flash.display.Bitmap;
import flash.display.BitmapData;

import flash.filters.DropShadowFilter;
import flash.filters.BitmapFilter;
import flash.filters.BitmapFilterQuality;

import haxegui.managers.CursorManager;
import haxegui.managers.StyleManager;
import haxegui.Window;
import haxegui.controls.Button;
import haxegui.controls.Slider;
import haxegui.controls.Stepper;
import haxegui.controls.Input;

import haxegui.utils.Color;

/**
*
* ColorPicker class
*
* @version 0.1
* @author Omer Goshen <gershon@goosemoose.com>
* @author Russell Weir <damonsbane@gmail.com>
*
*/
class ColorPicker extends Window
{
	var marker : Component;
	var swatch : Component;
	var spectrum  : Image;
	var currentColor : UInt;
	var input : Input;

	public override function init(?opts:Dynamic)
	{
		super.init({name:"ColorPicker", x:x, y:y, width:width, height:height, type: WindowType.MODAL, sizeable:false, color: 0xE6D3CC});
		type = WindowType.MODAL;
		box = new Rectangle (0, 0, 460, 300);

		//
		var menubar = new MenuBar (this, "MenuBar", 10,20);
		menubar.init ();

		//
		var container = new haxegui.containers.Container (this, "Container", 10, 44);
		container.init({width: 450, height: 256, color: 0xE6D3CC});

		var shadow:DropShadowFilter = new DropShadowFilter (4, 45, DefaultStyle.DROPSHADOW, 0.5,4, 4,0.75,BitmapFilterQuality.HIGH,true,false,false);
		container.filters = [shadow];

		//
		spectrum = new Image(container, "Spectrum", 10, 10);
		spectrum.init({src: haxegui.Haxegui.baseURL+"assets/spectrum.png"});

		var self = this;
		var spec = spectrum;
		spectrum.addEventListener(Event.COMPLETE,
		function(e) {
			spec.graphics.lineStyle(4, haxegui.utils.Color.darken(self.color, 10));
			spec.graphics.beginFill(0xffffff);
			spec.graphics.drawRect(0,0,spec.width,spec.height);
			spec.graphics.endFill();
			spec.scrollRect = new Rectangle(0,0,spec.width, spec.height);
			spec.setChildIndex(spec.bitmap, 0);
			}
		);

		var shadow:DropShadowFilter = new DropShadowFilter (4, 45, DefaultStyle.DROPSHADOW, 0.5,4, 4,0.75,BitmapFilterQuality.HIGH,true,false,false);
		spectrum.filters = [shadow];

		spectrum.addEventListener(MouseEvent.MOUSE_DOWN, onMouseMoveImage, false, 0, true);
		spectrum.addEventListener(MouseEvent.MOUSE_UP, onMouseUpImage, false, 0, true);
		spectrum.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMoveImage, false, 0, true);

		marker = new Component(spec, "marker");
		marker.init();
		var shadow:DropShadowFilter = new DropShadowFilter (2, 45, DefaultStyle.DROPSHADOW, 0.5,2, 2,0.5,BitmapFilterQuality.LOW,false,false,false);
		marker.filters = [shadow];
		marker.mouseEnabled = false;
		
		//
		swatch =  new Component(container, "swatch", 180, 10);
		swatch.mouseEnabled = false;
		swatch.graphics.lineStyle(2, color - 0x141414);
		swatch.graphics.beginFill(currentColor);
		swatch.graphics.drawRect(0,0,40,30);
		swatch.graphics.endFill();

		//~ var shadow:DropShadowFilter = new DropShadowFilter (4, 45, DefaultStyle.DROPSHADOW, 0.5,4, 4,0.75,BitmapFilterQuality.HIGH,true,false,false);
		//~ swatch.filters = [shadow];

		// 
		input = new Input(container, "Input", 230, 10);
		input.init({height: 30});
		input.tf.text = "0x"+StringTools.hex(currentColor);
		input.tf.y += 4;

		var r = currentColor >> 16 ;
		var g = currentColor >> 8 & 0xFF ;
		var b = currentColor & 0xFF ;

		//
		for(i in 1...5)	{
			
			
			//
			var slider = new Slider(container, "Slider"+i);
			slider.init({width: 196, step: i==4 ? .1 : 1, max: i==4 ? 1 : 306, color: 0xE6D3CC});
			slider.move(180, 10+40*i);
			switch(i) {
			case 1: slider.handle.x = .5*r;
			case 2: slider.handle.x = .5*g;
			case 3: slider.handle.x = .5*b;
			case 4: slider.handle.x = 166;
			}
			
			//
			var stepper = new Stepper(container, "Stepper"+i);
				stepper.init({value: i==4 ? 1 : 0, step: i==4 ? .01 : 1, page: i==4 ? .01 : 5, max: i==4 ? 1 : 0xFF, color: 0xE6D3CC, repeatsPerSecond: 10});
			//~ stepper.init();
			stepper.adjustment.value = 2*slider.handle.x;
			stepper.move(388, 10+40*i);
			
			//
			var me = this;
			//~ slider.adjustment.addEventListener(Event.CHANGE, function(e:Event) { stepper.adjustment.value = i==4 ? e.target.parent.handle.x/166 : 2*e.target.parent.handle.x; stepper.dispatchEvent(new Event(Event.CHANGE)); me.updateColor(); });
			//~ stepper.adjustment.addEventListener(Event.CHANGE, function(e:Event) { slider.handle.x = i==4 ? 166*e.target.value : .5*e.target.value; me.updateColor(); });

			slider.adjustment.addEventListener(Event.CHANGE, function(e:Event) { me.updateColor(); });
			stepper.adjustment.addEventListener(Event.CHANGE, function(e:Event) { me.updateColor(); });

		}

		//
		var button = new Button(container, "Ok", 180, 210);
		button.init({color: 0xE6D3CC, label: "Ok" });

	
		//
		var button = new Button(container, "Cancel", 290, 210);
		button.init({color: 0xE6D3CC, label: "Cancel" });



		this.addEventListener(MouseEvent.ROLL_OVER, onRollOver);
		this.addEventListener(MouseEvent.ROLL_OUT, onRollOut);
		//~ this.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);

		//~ redraw(null);
		dispatchEvent(new ResizeEvent(ResizeEvent.RESIZE));
	}



	public override function onResize (e:ResizeEvent) {

		super.onResize(e);

		e.stopImmediatePropagation ();


		if( this.getChildByName("MenuBar")!=null )	{
		var menubar = untyped this.getChildByName("MenuBar");
		menubar.onResize(e);
		}
	}



	public override function onRollOver(e:MouseEvent) {
		CursorManager.setCursor(Cursor.HAND);
	}

	public override function onRollOut(e:MouseEvent) {
	}


	public  function onMouseUpImage(e:MouseEvent) {
		if(e.target.hitTestObject( CursorManager.getInstance()._mc ))
			CursorManager.setCursor(Cursor.HAND);
	}



	public function onMouseMoveImage(e:MouseEvent) {

		if(!Std.is(e.target, Image) || !e.buttonDown ) return;

			marker.graphics.clear();
			marker.graphics.lineStyle(2,0xFFFFFF);
			marker.graphics.beginFill(0xFFFFFF, .1);
			marker.graphics.drawCircle(e.localX,e.localY,10);
			marker.graphics.endFill();
			marker.graphics.moveTo(e.localX-1, e.localY);
			marker.graphics.lineTo(e.localX+1, e.localY);
			marker.graphics.moveTo(e.localX, e.localY-1);
			marker.graphics.lineTo(e.localX, e.localY+1);
		
			CursorManager.setCursor(Cursor.CROSSHAIR);
			//~ trace(e.target.getChildAt(0).bitmapData.getPixel(e.localX, e.localY));
			currentColor = (cast spectrum.getChildAt(0)).bitmapData.getPixel(e.localX, e.localY);

			untyped this.getChildByName("Container").getChildByName("Slider1").handle.x = .5*Color.toRGB(currentColor).r ;
			//~ untyped this.getChildByName("Container").getChildByName("Slider1").dispatchEvent(new Event(Event.CHANGE));

			untyped this.getChildByName("Container").getChildByName("Slider2").handle.x = .5* Color.toRGB(currentColor).g;
			//~ untyped this.getChildByName("Container").getChildByName("Slider2").dispatchEvent(new Event(Event.CHANGE));

			untyped this.getChildByName("Container").getChildByName("Slider3").handle.x = .5*Color.toRGB(currentColor).b;
			//~ untyped this.getChildByName("Container").getChildByName("Slider3").dispatchEvent(new Event(Event.CHANGE));

			updateColor();
	}

	public function updateColor()
	{
		var r = 1 + 2 * untyped this.getChildByName("Container").getChildByName("Slider1").handle.x ;
		var g = 1 + 2 * untyped this.getChildByName("Container").getChildByName("Slider2").handle.x ;
		var b = 1 + 2 * untyped this.getChildByName("Container").getChildByName("Slider3").handle.x ;
		var a = untyped this.getChildByName("Container").getChildByName("Stepper4").adjustment.value ;

		//currentColor = r | g | b;
		currentColor  = (r << 16) | (g << 8) | b;

	    var matrix = new flash.geom.Matrix(); 
		var bmpd:BitmapData = new BitmapData(20,20);
		var rect1:Rectangle = new Rectangle(0,  0, 10, 10);
		var rect2:Rectangle = new Rectangle(0, 10, 10, 20);
		var rect3:Rectangle = new Rectangle(10, 0, 20, 10);
		var rect4:Rectangle = new Rectangle(10,10, 20, 20);
		bmpd.fillRect(rect1, 0xFFBFBFBF);
		bmpd.fillRect(rect2, 0xFFDDDDDD);
		bmpd.fillRect(rect3, 0xFFDDDDDD);
		bmpd.fillRect(rect4, 0xFFBFBFBF);

		swatch.graphics.clear();
		swatch.graphics.lineStyle(2, color - 0x141414);

		swatch.graphics.beginBitmapFill(bmpd, matrix, true, true);
		swatch.graphics.drawRect(0,0,40,30);
		swatch.graphics.endFill();


		swatch.graphics.beginFill(currentColor, a);
		swatch.graphics.drawRect(0,0,40,30);
		swatch.graphics.endFill();

		updateInput();

	}


	public function updateInput() {
		input.tf.text = "0x"+StringTools.hex(currentColor);
		input.tf.setTextFormat( DefaultStyle.getTextFormat() );
	}
	
	
	public override function destroy() {
		
		if(spectrum.hasEventListener(MouseEvent.MOUSE_UP))
			spectrum.removeEventListener(MouseEvent.MOUSE_UP, onMouseUpImage);

		if(spectrum.hasEventListener(MouseEvent.MOUSE_MOVE))
			spectrum.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMoveImage);

		//~ for(i in 0...numChildren-1)
			//~ getChildAt(i).removeEventListener()
		
		super.destroy();
	}
		

}
