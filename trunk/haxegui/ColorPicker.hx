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


//{{{ Imports
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.filters.BitmapFilter;
import flash.filters.BitmapFilterQuality;
import flash.filters.DropShadowFilter;
import flash.geom.Rectangle;
import flash.text.TextField;
import flash.text.TextFormat;
import haxegui.Window;
import haxegui.containers.Container;
import haxegui.controls.Button;
import haxegui.controls.Component;
import haxegui.controls.Image;
import haxegui.controls.Input;
import haxegui.controls.MenuBar;
import haxegui.controls.Slider;
import haxegui.controls.Stepper;
import haxegui.events.DragEvent;
import haxegui.events.MenuEvent;
import haxegui.events.MoveEvent;
import haxegui.events.ResizeEvent;
import haxegui.managers.CursorManager;
import haxegui.managers.StyleManager;
import haxegui.toys.Arrow;
import haxegui.toys.Circle;
import haxegui.utils.Color;
import haxegui.utils.Size;
//}}}


using haxegui.utils.Color;


//{{{ ColorPicker
/**
*
* ColorPicker class
*
* @version 0.1
* @author Omer Goshen <gershon@goosemoose.com>
* @author Russell Weir <damonsbane@gmail.com>
*
*/
class ColorPicker extends Window {
	//{{{ Members
	/** the current color in the swatch, 24bit rgb no alpha **/
	public var currentColor : UInt;

	/** the current alpha value, float 0-1 **/
	public var currentAlpha : Float;

	/** input shows color in flash 0xhex format **/
	public var input : Input;

	/** the swatch, shows the [currentColor] **/
	public var swatch : Component;

	/** main container **/
	var container : Container;

	/** the image for the spectrum whose [BitmapData] is picked from **/
	var spectrum  : Image;

	/** a marker to point the [currentColor] on the [spectrum] **/
	var marker : Component;
	//}}}


	//{{{ Functions
	//{{{ init
	public override function init(?opts:Dynamic) {
		super.init({name:"ColorPicker", x:x, y:y, width:width, height:height, type: WindowType.MODAL, sizeable:false, color: 0xE6D3CC});
		type = WindowType.MODAL;
		box = new Rectangle (0, 0, 480, 320);
		currentAlpha = 1;

		//
		var menubar = new MenuBar (this, "MenuBar", 10,20);
		menubar.init ();

		//
		container = new Container (this, "Container", 10, 44);
		container.init({width: 470, height: 276, color: 0xE6D3CC});

		container.filters = [new DropShadowFilter (4, 45, DefaultStyle.DROPSHADOW, 0.5,4, 4,0.75,BitmapFilterQuality.HIGH,true,false,false)];

		//
		spectrum = new Image(container, "Spectrum", 20, 26);
		spectrum.init({src: haxegui.Haxegui.baseURL+"assets/spectrum.png"});

		var self = this;
		var spec = spectrum;
		spectrum.addEventListener(Event.COMPLETE,
		function(e) {
			spec.graphics.lineStyle(4, self.color.darken(10));
			spec.graphics.beginFill(Color.WHITE);
			spec.graphics.drawRect(0,0,spec.width,spec.height);
			spec.graphics.endFill();
			spec.scrollRect = new Size(spec.width, spec.height).toRect();
			spec.setChildIndex(spec.bitmap, 0);

			var arrow = new Arrow(self.container, "topArrow");
			arrow.init();
			arrow.moveTo(spec.width/2, 10);
			arrow.rotation = 90;

			arrow = new Arrow(self.container, "bottomArrow");
			arrow.init();
			arrow.moveTo(spec.width/2, spec.height+20);
			arrow.rotation = -90;

			var arrow = new Arrow(self.container, "leftArrow");
			arrow.init();
			arrow.moveTo(10, spec.height/2);
			arrow.rotation = 0;

			var arrow = new Arrow(self.container, "rightArrow");
			arrow.init();
			arrow.moveTo(spec.width+20, spec.height/2);
			arrow.rotation = 180;
		}
		);

		spectrum.filters = [new DropShadowFilter (4, 45, DefaultStyle.DROPSHADOW, 0.5,4, 4,0.75,BitmapFilterQuality.HIGH,true,false,false)];

		spectrum.addEventListener(MouseEvent.MOUSE_DOWN, onMouseMoveImage, false, 0, true);
		spectrum.addEventListener(MouseEvent.MOUSE_UP, onMouseUpImage, false, 0, true);
		spectrum.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMoveImage, false, 0, true);


		marker = new Component(spec, "marker");
		marker.init();
		marker.filters = [new DropShadowFilter (2, 45, DefaultStyle.DROPSHADOW, 0.5,2, 2,0.5,BitmapFilterQuality.LOW,false,false,false)];
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
		input.tf.text = currentColor.toHex();
		input.tf.y += 4;

		var rgb = currentColor.toRGB();
		//
		for(i in 1...5)	{

			var isAlpha = i==4;

			//
			var slider = new Slider(container, "Slider"+i);
			slider.init({
				width: 196,
				min: 0,
				max: isAlpha ? 1 : 0xFF,
				step: isAlpha ? .1 : 1,
				showToolTip: false,
				color: this.color
			});
			slider.move(195, 10+40*i);
			switch(i) {
				case 1: slider.handle.x = rgb.r;
				case 2: slider.handle.x = rgb.g;
				case 3: slider.handle.x = rgb.b;
				case 4: slider.handle.x = currentAlpha*172;
			}

			//
			var stepper = new Stepper(container, "Stepper"+i);
			stepper.init({
				value: isAlpha ? 1 : 0,
				step: isAlpha ? .01 : 1,
				page: isAlpha? .1 : 5,
				max: isAlpha ? 1 : 0xFF,
				color: this.color,
				repeatsPerSecond: 10
			});
			//stepper.adjustment.value = 2*slider.handle.x;
			stepper.move(410, 10+40*i);

			//
			var me = this;
			var sliderToStepper = function(e) {
				if(isAlpha)
				stepper.adjustment.object.value = e.target.getValue()/172;
				else
				stepper.adjustment.object.value = Std.int(255*e.target.getValue()/172);

				stepper.adjustment.adjust(stepper.adjustment.object);
				me.updateColor();
			}

			slider.adjustment.addEventListener(Event.CHANGE, sliderToStepper);
			//~ slider.adjustment.addEventListener(Event.CHANGE, function(e:Event) { stepper.adjustment.object.value = i==4 ? e.target.parent.handle.x/166 : 2*e.target.parent.handle.x; stepper.dispatchEvent(new Event(Event.CHANGE)); me.updateColor(); });
			//~ stepper.adjustment.addEventListener(Event.CHANGE, function(e:Event) { slider.handle.x = i==4 ? 166*e.target.value : .5*e.target.value; me.updateColor(); });

			slider.adjustment.addEventListener(Event.CHANGE, function(e:Event) { me.updateColor(); });
			//stepper.adjustment.addEventListener(Event.CHANGE, function(e:Event) { me.updateColor(); });

		}

		//
		var button = new Button(container, "Ok", 180, 210);
		button.init({color: this.color, label: "Ok" });

		//
		button = new Button(container, "Cancel", 290, 210);
		button.init({color: this.color, label: "Cancel" });

		this.addEventListener(MouseEvent.ROLL_OVER, onRollOver);
		this.addEventListener(MouseEvent.ROLL_OUT, onRollOut);
		//~ this.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);

		//~ redraw(null);
		dispatchEvent(new ResizeEvent(ResizeEvent.RESIZE));
	}
	//}}}

	//{{{ onResize
	public override function onResize (e:ResizeEvent) {
		super.onResize(e);

		e.stopImmediatePropagation ();

		if( this.getChildByName("MenuBar")==null )	return;
		var menubar = untyped this.getChildByName("MenuBar");
		menubar.onResize(e);
	} //}}}

	//{{{ onMouseUpImage

	public  function onMouseUpImage(e:MouseEvent) {
		if(e.target.hitTestObject( CursorManager.getInstance()._mc ))
		CursorManager.setCursor(Cursor.HAND);
	}

	//}}}

	//{{{ onMouseMoveImage
	public function onMouseMoveImage(e:MouseEvent) {

		if(!Std.is(e.target, Image) || !e.buttonDown ) return;

		var arrow = container.getChildByName("topArrow");
		arrow.x = e.localX + 20;

		arrow = container.getChildByName("bottomArrow");
		arrow.x = e.localX + 20;

		arrow = container.getChildByName("leftArrow");
		arrow.y = e.localY + 20;

		arrow = container.getChildByName("rightArrow");
		arrow.y = e.localY + 20;

		var ix = Std.int(e.localX);
		var iy = Std.int(e.localY);

		marker.graphics.clear();
		marker.graphics.lineStyle(2, Color.WHITE);
		marker.graphics.beginFill(Color.WHITE, .1);
		marker.graphics.drawCircle(e.localX,e.localY,10);
		marker.graphics.endFill();
		marker.graphics.moveTo(e.localX-1, e.localY);
		marker.graphics.lineTo(e.localX+1, e.localY);
		marker.graphics.moveTo(e.localX, e.localY-1);
		marker.graphics.lineTo(e.localX, e.localY+1);

		CursorManager.setCursor(Cursor.CROSSHAIR);
		//~ trace(e.target.getChildAt(0).bitmapData.getPixel(e.localX, e.localY));
		//~ currentColor = (cast spectrum.getChildAt(0)).bitmapData.getPixel(e.localX, e.localY);
		currentColor = spectrum.bitmap.bitmapData.getPixel(ix, iy);


		var cc = currentColor.toRGB();

		untyped container.getChildByName("Slider1").handle.x = cc.r/255*172 ;
		untyped container.getChildByName("Slider2").handle.x = cc.g/255*172 ;
		untyped container.getChildByName("Slider3").handle.x = cc.b/255*172 ;


		untyped container.getChildByName("Slider1").adjustment.object.value = cc.r;
		untyped container.getChildByName("Slider1").adjustment.adjust(container.getChildByName("Slider1").adjustment.object);

		untyped container.getChildByName("Slider2").adjustment.object.value = cc.g ;
		untyped container.getChildByName("Slider2").adjustment.adjust(container.getChildByName("Slider2").adjustment.object);

		untyped container.getChildByName("Slider3").adjustment.object.value = cc.b ;
		untyped container.getChildByName("Slider3").adjustment.adjust(container.getChildByName("Slider3").adjustment.object);

		updateColor();

	}
	//}}}

	//{{{ updateColor

	public function updateColor()
	{
		var r =  untyped container.getChildByName("Slider1").adjustment.getValue();
		var g =  untyped container.getChildByName("Slider2").adjustment.getValue();
		var b =  untyped container.getChildByName("Slider3").adjustment.getValue();
		var a =  untyped container.getChildByName("Stepper4").adjustment.getValue();

		currentColor = Color.rgb(r, g, b);
		currentAlpha = a;

		redrawSwatch();

		updateInput();

	}

	//}}}

	//{{{ redrawSwatch
	public function redrawSwatch() {
		/** checkered swatch background **/
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
		swatch.graphics.lineStyle(2, this.color.darken(20));

		swatch.graphics.beginBitmapFill(bmpd, matrix, true, true);
		swatch.graphics.drawRect(0,0,40,30);
		swatch.graphics.endFill();

		/** swatch color **/
		swatch.graphics.beginFill(currentColor, currentAlpha);
		swatch.graphics.drawRect(0,0,40,30);
		swatch.graphics.endFill();
	}
	//}}}

	//{{{ updateInput
	public function updateInput() {
		input.tf.text = currentColor.toHex();
	}

	//}}}

	//{{{ destroy
	public override function destroy() {

		if(spectrum.hasEventListener(MouseEvent.MOUSE_UP))
		spectrum.removeEventListener(MouseEvent.MOUSE_UP, onMouseUpImage);

		if(spectrum.hasEventListener(MouseEvent.MOUSE_MOVE))
		spectrum.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMoveImage);

		super.destroy();
	}
	//}}}
	//}}}
}
//}}}
