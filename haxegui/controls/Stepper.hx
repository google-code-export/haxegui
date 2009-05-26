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

import haxegui.Component;
import haxegui.managers.CursorManager;
import haxegui.Opts;
import haxegui.managers.StyleManager;
import haxegui.events.MoveEvent;
import haxegui.events.ResizeEvent;
import haxegui.events.DragEvent;

class StepperUpButton extends AbstractButton
{
	static function __init__() {
		haxegui.Haxegui.register(StepperUpButton);
	}
}

class StepperDownButton extends AbstractButton
{
	static function __init__() {
		haxegui.Haxegui.register(StepperDownButton);
	}
}



/**
*
* Stepper Class
*
*
* @author Omer Goshen <gershon@goosemoose.com>
* @author Russell Weir <damonsbane@gmail.com>
* @version 0.1
*/
class Stepper extends Component
{
	public var up : StepperUpButton;
	public var down : StepperDownButton;
	public var background : Sprite;
	public var tf : TextField;

	public var value(__getValue,__setValue) : Float;
	public var step : Float;
	public var min : Float;
	public var max : Float;


	public function new (?parent:DisplayObjectContainer, ?name:String, ?x:Float, ?y:Float)
	{
		super(parent, name, x, y);

		value = 0;
		step = 1;
		min = 0;
		max = 100;
		color = DefaultStyle.BACKGROUND;
		box = new Rectangle(0,0,40,20);

		tf = new TextField();
		tf.name = "tf";
		background = new Sprite();
		background.name = "background";
		this.addChild(background);
		this.addChild(tf);

		up = new StepperUpButton(this, "up");
		down = new StepperDownButton(this, "down");

		this.addEventListener (Event.CHANGE, onChanged, false, 0, true);
	}


	override public function init(opts:Dynamic=null)
	{
		var aOpts = Opts.clone(opts);
		value = Opts.optFloat(aOpts,"value", value);
		step = Opts.optFloat(aOpts,"step", step);
		min = Opts.optFloat(aOpts,"min", min);
		max = Opts.optFloat(aOpts,"max", max);
		Opts.removeFields(aOpts, ["value","step","min","max"]);

		super.init(aOpts);
		// since we removed fields, reset the initOpts
		this.initOpts = Opts.clone(opts);

		tf.type = flash.text.TextFieldType.INPUT;
		tf.selectable = true;
		tf.width = box.width - 10;
		tf.height = box.height - 2;
		tf.x = 4;
		tf.y = 2;
		tf.text = Std.string(value);
		tf.embedFonts = true;
		tf.defaultTextFormat = DefaultStyle.getTextFormat();
		tf.setTextFormat(DefaultStyle.getTextFormat());

		up.init({color: this.color});
		down.init({color: this.color});
	}

	public function onChanged(?e:Dynamic)
	{
		dirty = true;

		this.tf.text = Std.string(value);
		//~ this.tf.setTextFormat(StyleManager.getTextFormat(12));
		this.tf.setTextFormat(DefaultStyle.getTextFormat());
	}

	private function __getValue() : Float {
		return this.value;
	}

	private function __setValue(v:Float) : Float {
		if(this.value == v)
			return v;
		this.value = v;
		if(this.value > max)
			this.value = max;
		if(this.value < min)
			this.value = min;
		dispatchEvent(new Event(Event.CHANGE));
		return v;
	}

	static function __init__() {
		haxegui.Haxegui.register(Stepper);
	}

}
