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

import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.KeyboardEvent;
import flash.events.FocusEvent;
import flash.filters.DropShadowFilter;
import flash.filters.BitmapFilter;
import flash.filters.BitmapFilterQuality;
import flash.geom.Rectangle;
import flash.text.TextField;

import haxe.Timer;

import haxegui.CursorManager;
import haxegui.Opts;
import haxegui.StyleManager;
import haxegui.events.MoveEvent;
import haxegui.events.ResizeEvent;
import haxegui.events.DragEvent;

class Stepper extends Component, implements Dynamic
{
	public var up : Button;
	public var down : Button;
	public var back : Sprite;
	public var tf : TextField;

	public var value : Float;
	public var step : Float;
	public var min : Float;
	public var max : Float;

	var timer : Timer;
	var delta : Float;

	var autoRepeat : Bool;
	
	
	public function new (?parent:DisplayObjectContainer, ?name:String, ?x:Float, ?y:Float)
	{
		super(parent, name, x, y);
		tf = new TextField();
		value = 0;
		step = 1;
		min = 0;
		max = 100;
	}


	override public function init(opts:Dynamic=null)
	{
		color = DefaultStyle.BACKGROUND;
		box = new Rectangle(0,0,40,20);

		super.init(opts);

		value = Opts.optFloat(opts,"value", value);
		step = Opts.optFloat(opts,"step", step);
		min = Opts.optFloat(opts,"min", min);
		max = Opts.optFloat(opts,"max", max);

		back = new Sprite();
		back.graphics.lineStyle(2, color - 0x141414);
		back.graphics.beginFill(DefaultStyle.INPUT_BACK);
		back.graphics.drawRoundRectComplex (0, 0, box.width - 10, box.height, 4, 0, 4, 0 );
		back.graphics.endFill();
		this.addChild(back);
		var shadow:DropShadowFilter = new DropShadowFilter (4, 45, DefaultStyle.DROPSHADOW, 0.8, 4, 4, 0.65, BitmapFilterQuality.HIGH, true, false, false );
		back.filters = [shadow];

		tf.name = "tf";
		tf.type = flash.text.TextFieldType.INPUT;
		tf.selectable = true;
		tf.width = box.width - 10;
		tf.height = 20;
		tf.x = 4;
		tf.y = 4;
		tf.text = Std.string(value);

		tf.embedFonts = true;
		tf.setTextFormat(StyleManager.getTextFormat());

		this.addChild(tf);




		up = new Button(this, "up");
		up.init({width: 10, height: 10, color: this.color});
		up.removeChild(up.label);
		up.move( box.width - 10, -1 );

		down = new Button(this, "down");
		down.init({width: 10, height: 10, color: this.color});
		down.removeChild(down.label);
		down.move( box.width - 10, 9 );

		// add the drop-shadow filter
		shadow = new DropShadowFilter (4, 45, DefaultStyle.DROPSHADOW, 0.8, 4, 4, 0.5, BitmapFilterQuality.HIGH, false, false, false );

		up.filters = [shadow];
		down.filters = [shadow];



		up.addEventListener (MouseEvent.MOUSE_DOWN, onBtnMouseDown, false, 0, true);
		up.addEventListener (MouseEvent.MOUSE_UP, onBtnMouseUp, false, 0, true);
		up.addEventListener (MouseEvent.ROLL_OVER, onBtnRollOver, false, 0, true);
		up.addEventListener (MouseEvent.ROLL_OUT,  onBtnRollOut, false, 0, true);

		down.addEventListener (MouseEvent.MOUSE_DOWN, onBtnMouseDown, false, 0, true);
		down.addEventListener (MouseEvent.MOUSE_UP, onBtnMouseUp, false, 0, true);
		down.addEventListener (MouseEvent.ROLL_OVER, onBtnRollOver, false, 0, true);
		down.addEventListener (MouseEvent.ROLL_OUT,  onBtnRollOut, false, 0, true);


		this.addEventListener (Event.CHANGE, onChanged, false, 0, true);
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
		//~ e.target.redraw(e.target.color | 0x202020 );
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
		//~ e.target.redraw();
//		CursorManager.setCursor(Cursor.ARROW);
	}


	/**
	*
	*/
	function onBtnMouseDown (e:MouseEvent) : Void
	{
		if (!Std.is (e.target, flash.display.DisplayObject))
		return;

		//~ FocusManager.getInstance().setFocus (this);
		switch(e.target)
		{
			case up:
			value += step;
			if(value>max)
			value = max;

			case down:
			value -= step;
			if(value<min)
			value = min;
		}

		dispatchEvent(new Event(Event.CHANGE));

		//~ e.target.redraw(color - 0x202020);
		//~ e.target.redraw(e.target.color | 0x666666);

		e.target.addEventListener(Event.ENTER_FRAME, onEnterFrame, false, 0, true);

	}


	function onEnterFrame(e:Event) : Void
	{
		//~ trace(Timer.stamp() - delta);
			//~ delta = haxe.Timer.stamp();

		switch(e.target)
		{
			case up:
			value += step;
			if(value>max)
			value = max;

			case down:
			value -= step;
			if(value<min)
			value = min;
		}
		dispatchEvent(new Event(Event.CHANGE));
		//~ onChanged();

	}



	function onBtnMouseUp (e:MouseEvent) : Void
	{


		e.target.removeEventListener(Event.ENTER_FRAME, onEnterFrame);

		e.target.redraw(color);

		//~ e.target.stopDrag();
		//~ e.target.stage.removeEventListener (MouseEvent.MOUSE_MOVE, onMouseMove);
		//~ dispatchEvent(new Event(Event.CHANGE));

		//~ dispatchEvent(new Event(Event.CHANGE));

	}


	public function onChanged(?e:Dynamic)
	{

	//~
	//~ trace(e);
		this.tf.text = Std.string(value);
		//~ this.tf.setTextFormat(StyleManager.getTextFormat(12));
		this.tf.setTextFormat(StyleManager.getTextFormat());
	}

}
