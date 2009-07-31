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
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.KeyboardEvent;
import flash.events.FocusEvent;

import haxegui.controls.Component;
import haxegui.controls.Component;
import haxegui.events.MoveEvent;
import haxegui.managers.CursorManager;
import haxegui.managers.FocusManager;
import haxegui.managers.ScriptManager;
import haxegui.managers.StyleManager;
import haxegui.utils.Opts;



/**
* RadioGroup Class
*
* @author Omer Goshen <gershon@goosemoose.com>
* @author Russell Weir <damonsbane@gmail.com>
**/
class RadioGroup extends Component
{
	public var buttons : Array<RadioButton>;
	
	static function __init__() {
		haxegui.Haxegui.register(RadioGroup);
	}
}


/**
* RadioButton allows the user to select only one of the predefined set of similar widgets.
*
* @author Omer Goshen <gershon@goosemoose.com>
* @author Russell Weir <damonsbane@gmail.com>
**/
class RadioButton extends AbstractButton
{
	//~ public var group : Array<RadioButton>
	public var selected(default, default) : Bool;
	public var label : Label;


	override public function init(?opts:Dynamic) {
		box = new Rectangle(0,0,20,20);
		color = DefaultStyle.BACKGROUND;

		super.init(opts);

		selected = Opts.optBool(opts, "selected", selected);

		// label on by default
		if(Opts.optString(opts, "label", name)!="false") {
			label = new Label(this);
			label.init();
			label.text = Opts.optString(opts, "label", name);
			label.move(24, 2);
		}

		if(label!=null && disabled) {
			var fmt = DefaultStyle.getTextFormat();
			fmt.color = haxegui.utils.Color.darken(DefaultStyle.BACKGROUND, 20);
			label.tf.setTextFormat(fmt);
		}

		this.filters = [new flash.filters.DropShadowFilter (1, 45, DefaultStyle.DROPSHADOW, 0.8, 2, 2, 0.65, flash.filters.BitmapFilterQuality.LOW, true, false, false )];
	}


	/**
	*
	*
	*/
	public override function onMouseClick(e:MouseEvent) {
		if(disabled) return;

		//~ for(i in 0...parent.numChildren)
		for(child in cast(parent, Component))
			{
				if(Std.is(child, RadioButton))
					untyped if(child!=this && !child.disabled) {
							child.selected = false;
							child.redraw();
							}
			}
		selected = true;
		redraw();
		
		super.onMouseClick(cast e.clone());
	}

	static function __init__() {
		haxegui.Haxegui.register(RadioButton);
	}
}
