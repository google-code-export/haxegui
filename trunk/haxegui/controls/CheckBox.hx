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
import flash.geom.Rectangle;
import flash.events.Event;
import haxegui.managers.CursorManager;
import haxegui.managers.FocusManager;
import haxegui.managers.StyleManager;
import haxegui.utils.Opts;
import haxegui.controls.AbstractButton;
import haxegui.controls.IAdjustable;
import haxegui.controls.Button;
import haxegui.toys.Socket;
import haxegui.utils.Color;
import haxegui.utils.Size;

/**
* An on\off CheckBox, with composited Label.<br>
* use the member variable [checked] to get it's state.<br>
* You can use the dispatched event:
* <pre class="code haxe">
* var chkbox = new CheckBox();
* chkbox.init();
* chkbox.addEventListener(Event.CHANGE, function(e){...});
* </pre>
* Or you could override the default action:
* <pre class="code haxe">
* var chkbox = new CheckBox();
* chkbox.init();
* chkbox.setAction("mouseClick",
* "// this is the default code
* if(!this.disabled) {
*	this.checked = !this.checked;
*	this.redraw();
*	this.updateColorTween( new feffects.Tween(50, 0, 150, feffects.easing.Linear.easeNone) );
*   // your code here...
* }
* ");
* </pre>
* 
*
* @author Omer Goshen <gershon@goosemoose.com>
* @author Russell Weir <damonsbane@gmail.com>
**/
class CheckBox extends PushButton
{

	override public function init(opts:Dynamic=null) {
		box = new Size(20, 20).toRect();
		color = DefaultStyle.BACKGROUND;
		adjustment = new Adjustment({ value: false, min: false, max: true, step:null, page: null});
		//~ adjustment = new Adjustment({ value: 1, min: 0, max: 1, step:1, page: 1});
		super.init(opts);
		mouseChildren = true;
		
		label.box.width -= 30;
		label.center();
		label.move(30,0);
		
		if(!disabled) {
			slot = new haxegui.toys.Socket(this);
			slot.init();
			slot.moveTo(-14,Std.int(this.box.height)>>1);
	
			slot.color = Color.tint(slot.color, .5);
		}	

		adjustment.addEventListener (Event.CHANGE, onChanged, false, 0, true);
	}

	public function onChanged(e:Event) {
		trace(e+"\t"+adjustment.valueAsString());
		selected = cast adjustment.getValue();
		redraw();
	}
	
	override private function __setDisabled(v:Bool) : Bool {
		super.__setDisabled(v);
		if(this.disabled) {
			mouseEnabled = false;
			buttonMode = false;
		}
		else {
			mouseEnabled = Opts.optBool(initOpts,"mouseEnabled",true);
			buttonMode = Opts.optBool(initOpts,"buttonMode",true);
		}
		return v;
	}


	//////////////////////////////////////////////////
	////           Initialization                 ////
	//////////////////////////////////////////////////
	static function __init__() {
		haxegui.Haxegui.register(CheckBox);
	}
}
