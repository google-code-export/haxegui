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

package haxegui.controls;

import flash.display.Sprite;
import flash.display.MovieClip;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.KeyboardEvent;
import flash.events.FocusEvent;
import flash.filters.DropShadowFilter;
import flash.filters.BitmapFilter;
import flash.filters.BitmapFilterQuality;
import flash.geom.Rectangle;
import flash.text.TextField;
import flash.text.TextFormat;

import haxegui.CursorManager;
import haxegui.FocusManager;
import haxegui.Opts;
import haxegui.StyleManager;
import haxegui.events.MoveEvent;

class CheckBox extends Component, implements Dynamic
{
	public var checked(default, default) : Bool;
	public var label : Label;
	//~ public var button : Button;
	public var button : Sprite;


	public function new (?parent:DisplayObjectContainer, ?name:String, ?x:Float, ?y:Float)
	{
		super(parent, name, x, y);
	}

	override public function init(opts:Dynamic=null)
	{
		box = new Rectangle(0,0,140,20);
		color = DefaultStyle.BACKGROUND;

		super.init(opts);

		//~ this.graphics.clear();
		button = new Sprite();
		button.name = "button";
		button.graphics.lineStyle (2, color - 0x141414);
		button.graphics.beginFill (color);
		button.graphics.drawRoundRect (0, 0, 20, box.height, 8, 8 );
		button.graphics.endFill ();
		this.addChild(button);

		// add the drop-shadow filter
		//~ var shadow:DropShadowFilter = new DropShadowFilter (4, 45, DefaultStyle.DROPSHADOW, 0.5, 4, 4, 0.5, BitmapFilterQuality.HIGH, false, false, false );
		var shadow:DropShadowFilter = new DropShadowFilter (4, 45, DefaultStyle.DROPSHADOW, 0.5, 4, 4, 0.5, BitmapFilterQuality.HIGH, true, false, false );
		this.filters = [shadow];


		label = new Label();
		label.init({text: name});
		label.move(24, 2);
		this.addChild(label);


		// Listeners
		button.addEventListener (MouseEvent.MOUSE_DOWN, onBtnMouseDown,false,0,true);
		button.addEventListener (MouseEvent.MOUSE_UP,   onBtnMouseUp,false,0,true);
		button.addEventListener (MouseEvent.ROLL_OVER, onBtnRollOver,false,0,true);
		button.addEventListener (MouseEvent.ROLL_OUT,  onBtnRollOut,false,0,true);

		this.addEventListener (Event.ACTIVATE, onEnabled,false,0,true);
		this.addEventListener (Event.DEACTIVATE, onDisabled,false,0,true);

		if(disabled)
			dispatchEvent(new Event(Event.DEACTIVATE));
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

	override public function redraw(opts:Dynamic=null) : Void {
		if( disabled )
		{
			//~ color = DefaultStyle.BACKGROUND - 0x141414;
			//~ color = DefaultStyle.BACKGROUND ;
			var fmt = DefaultStyle.getTextFormat();
			fmt.color = color - 0x202020;
			//~ fmt.align = flash.text.TextFormatAlign.CENTER;
			label.tf.setTextFormat(fmt);

			//~ var shadow:DropShadowFilter = new DropShadowFilter (4, 45, DefaultStyle.DROPSHADOW, 0.2, 4, 4, 0.65, BitmapFilterQuality.HIGH, false, false, false );
			var shadow:DropShadowFilter = new DropShadowFilter (4, 45, DefaultStyle.DROPSHADOW, 0.2, 4, 4, 0.65, BitmapFilterQuality.HIGH, true, false, false );
			this.filters = [shadow];
		}


		button.graphics.clear();
		button.graphics.lineStyle (2, disabled ? color - 0x141414 : color - 0x282828 );

		if(checked)
		{
		//~ button.graphics.lineStyle (2, color - 0x202020);

			var colors = [ color | 0x323232, color - 0x141414 ];
			var alphas = [ 100, 0 ];
			var ratios = [ 0, 0xFF ];
			var matrix = new flash.geom.Matrix();
			matrix.createGradientBox(20, 20, Math.PI/2, 0, 0);
			button.graphics.beginGradientFill( flash.display.GradientType.LINEAR, colors, alphas, ratios, matrix );
			button.graphics.drawRoundRect (0, 0, 20, box.height, 8, 8 );


			button.graphics.lineStyle (4, color - 0x282828);
			button.graphics.moveTo (6, 6);
			button.graphics.lineTo (14, 14);
			button.graphics.moveTo (14, 6);
			button.graphics.lineTo (6, 14);

		}
		else
		{
			//~ button.graphics.lineStyle (2, color - 0x202020);
			var colors = [ color - 0x141414, color | 0x323232 ];
			var alphas = [ 100, 0 ];
			var ratios = [ 0, 0xFF ];
			var matrix = new flash.geom.Matrix();
			matrix.createGradientBox(20, 20, Math.PI/2, 0, 0);
			button.graphics.beginGradientFill( flash.display.GradientType.LINEAR, colors, alphas, ratios, matrix );

			//~ button.graphics.beginFill (color);
			button.graphics.drawRoundRect (0, 0, 20, box.height, 8, 8 );
		}

		button.graphics.endFill ();
	}

	/**
	*
	*
	*/
	public function onBtnRollOver(e:MouseEvent) : Void
	{
		if(disabled) return;
		//~ redraw(DefaultStyle.BACKGROUND + 0x323232 );
//		redraw(DefaultStyle.BACKGROUND | 0x141414 );
		//~ var color = checked ? DefaultStyle.BACKGROUND - 0x202020 : DefaultStyle.BACKGROUND;
		//~ redraw();
		//~ redraw(color + 0x141414 );
		CursorManager.setCursor(Cursor.HAND);

	}

	/**
	*
	*
	*/
	public  function onBtnRollOut(e:MouseEvent) : Void
	{
		//~ var color = checked ? DefaultStyle.BACKGROUND - 0x202020 : DefaultStyle.BACKGROUND;
		//~ redraw(color);
//		CursorManager.setCursor(Cursor.ARROW);
	}

	/**
	*
	*
	*/
	public  function onBtnMouseDown(e:MouseEvent) : Void
	{
		if(disabled) return;

		//~ trace(Std.string(here)+Std.string(e));
		//~ if(!this.hasFocus())
		FocusManager.getInstance().setFocus(this);

		redraw();

	}

	/**
	*
	*
	*/
	public  function onBtnMouseUp(e:MouseEvent) {
		checked = !checked;

		//~ redraw(DefaultStyle.BACKGROUND);
		//~ var color = checked ? DefaultStyle.BACKGROUND - 0x202020 : DefaultStyle.BACKGROUND;

		redraw();
	}

}
