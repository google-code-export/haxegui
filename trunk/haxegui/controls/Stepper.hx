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

import flash.geom.Rectangle;
import flash.display.DisplayObjectContainer;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.KeyboardEvent;
import flash.events.TextEvent;
import flash.events.FocusEvent;

import haxegui.Component;
import haxegui.controls.Input;
import haxegui.managers.CursorManager;
import haxegui.Opts;
import haxegui.managers.StyleManager;
import haxegui.events.MoveEvent;
import haxegui.events.ResizeEvent;
import haxegui.events.DragEvent;
import haxegui.IAdjustable;


class StepperUpButton extends AbstractButton
{
	override public function init(opts:Dynamic=null) {
		super.init(opts);
		var arrow = new haxegui.toys.Arrow(this);
		arrow.init({ color: haxegui.utils.Color.darken(this.color, 20), width: .5*(cast this.parent).box.height-6, height: 8 });
		arrow.rotation = -90;
		arrow.move(6,1);
	}
	
	static function __init__() {
		haxegui.Haxegui.register(StepperUpButton);

	}
}

class StepperDownButton extends AbstractButton
{
	override public function init(opts:Dynamic=null) {
		super.init(opts);
		var arrow = new haxegui.toys.Arrow(this);
		arrow.init({ color: haxegui.utils.Color.darken(this.color, 20), width: .5*(cast this.parent).box.height-6, height: 8 });
		arrow.rotation = 90;
		arrow.move(6,1);
	}
		
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
class Stepper extends Component, implements IAdjustable
{
	public var up : StepperUpButton;
	public var down : StepperDownButton;
	public var input : Input;

	public var adjustment : Adjustment;

	override public function init(opts:Dynamic=null)
	{
		adjustment = new Adjustment(0, 0, 100, 1, 10);
		box = new Rectangle(0, 0, 40, 20);
		color = DefaultStyle.BACKGROUND;

		input = new Input(this);
		up = new StepperUpButton(this);
		down = new StepperDownButton(this);

		var aOpts = Opts.clone(opts);
		adjustment.value = Opts.optFloat(opts,"value", adjustment.value);
		adjustment.min = Opts.optFloat(opts,"min", adjustment.min);
		adjustment.max = Opts.optFloat(opts,"max", adjustment.max);
		adjustment.step = Opts.optFloat(opts,"step", adjustment.step);
		adjustment.page = Opts.optFloat(opts,"page", adjustment.page);
		Opts.removeFields(aOpts, ["value","step","min","max"]);

		super.init(aOpts);
		
		// since we removed fields, reset the initOpts
		this.initOpts = Opts.clone(opts);

		var bOpts = Opts.clone(aOpts);
		Opts.optBool(bOpts, "autoRepeat", true);
		Opts.optFloat(bOpts, "repeatsPerSecond", 50);
		Opts.optFloat(bOpts, "repeatWaitTime", .75);

		// init children
		input.init({width: box.width, height: box.height, text: Std.string(adjustment.value), disabled: this.disabled });
		up.init(bOpts);
		down.init(bOpts);

		input.setAction("focusIn", "");
		input.setAction("focusOut", "");
		
		//~ input.tf.addEventListener (KeyboardEvent.KEY_DOWN, onInput, false, 0, true);
		adjustment.addEventListener (Event.CHANGE, onChanged, false, 0, true);

	}

	//~ public function onInput(e:KeyboardEvent) {
		//~ value = Std.parseFloat(e.text);
	//~ }
	

	public function onChanged(e:Event)
	{
		input.tf.text = Std.string(adjustment.value);
	}
	
	static function __init__() {
		haxegui.Haxegui.register(Stepper);
	}

}
