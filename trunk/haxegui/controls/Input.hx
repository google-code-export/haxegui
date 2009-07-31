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

//{{{ Imports
package haxegui.controls;

import flash.geom.Rectangle;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TextEvent;
import flash.events.FocusEvent;

import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFieldAutoSize;

import haxegui.utils.Size;
import haxegui.utils.Opts;
import haxegui.managers.StyleManager;
import haxegui.controls.Component;
//}}}


/**
* Input class wraps an editable [TextField].<br/>
*
*
* @author <gershon@goosemoose.com>
* @author Russell Weir <damonsbane@gmail.com>
* @version 0.2
*/
class Input extends Component
{

	public var tf : TextField;
	public var text(getText, setText) : String;

	override public function init(?opts:Dynamic) : Void	{
		box = new Size(140, 20).toRect();

		super.init(opts);

		//~ buttonMode = false;
		mouseChildren = true;
		mouseEnabled = true;
		tabEnabled = true;

		filters = [new flash.filters.DropShadowFilter (4, 45, DefaultStyle.DROPSHADOW, 0.8, 4, 4, 0.65, flash.filters.BitmapFilterQuality.HIGH, true, false, false )];

		tf = new TextField();
		tf.name = "tf";
		tf.type = disabled ? flash.text.TextFieldType.DYNAMIC : flash.text.TextFieldType.INPUT;
		tf.text = name;
		tf.text = Opts.optString(opts, "text", tf.text);
		tf.selectable = disabled ? false : true;
		tf.background = false;
		tf.border = false;
		tf.mouseEnabled = true;
		tf.tabEnabled = false;
		tf.autoSize =  TextFieldAutoSize.NONE;
		tf.x = tf.y = 4;
		tf.embedFonts = true;
		tf.defaultTextFormat = DefaultStyle.getTextFormat();
		tf.setTextFormat(DefaultStyle.getTextFormat());
		addChild(tf);

		//addEventListener(TextEvent.TEXT_INPUT, onChanged, false, 0, true);

	}

	override private function __setDisabled(v:Bool) : Bool {
		super.__setDisabled(v);
		if(this.disabled) {
			mouseEnabled = false;
			buttonMode = false;
			if(tf!=null) {
				tf.mouseEnabled = false;
				tf.selectable = false;
			}
		}
		else {
			mouseEnabled = Opts.optBool(initOpts,"mouseEnabled",true);
			buttonMode = Opts.optBool(initOpts,"buttonMode",true);
			if(tf!=null) {
				tf.mouseEnabled = false;
				tf.selectable = true;
			}
		}
		return v;
	}

	//~ public function onChanged(e:Event) {}

	public function getText() : String {
	    return tf.text;
	}

	public function setText(s:String) : String {
	    tf.text = s;
	    dispatchEvent(new Event(Event.CHANGE));
	    return s;
	}
	
	static function __init__() {
		haxegui.Haxegui.register(Input);
	}


	//public override function onMouseClick(e:MouseEvent) {
	//tf.setSelection(0,tf.text.length);
	//super.onMouseClick(e);
	//}

	//private override function onFocusOut(e:FocusEvent) {
	//tf.setSelection(0,0);
	//super.onFocusOut(e);
	//}
}

