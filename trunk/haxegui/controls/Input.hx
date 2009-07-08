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
import flash.events.TextEvent;

import flash.text.TextField;
import flash.text.TextFormat;

import haxegui.Opts;
import haxegui.managers.StyleManager;
import haxegui.Component;


/**
* Input Class
*
*
* @author <gershon@goosemoose.com>
* @author Russell Weir <damonsbane@gmail.com>
* @version 0.2
*/
class Input extends Component
{

    public var tf : TextField;


	override public function init(?opts:Dynamic) : Void
	{
	    box = new Rectangle(0, 0, 140, 20);

	    super.init(opts);

	    //~ buttonMode = false;
	    mouseEnabled = true;
	    tabEnabled = true;

	    var shadow = new flash.filters.DropShadowFilter (4, 45, DefaultStyle.DROPSHADOW, 0.8, 4, 4, 0.65, flash.filters.BitmapFilterQuality.HIGH, true, false, false );
	    filters = [shadow];

	    tf = new TextField();
	    tf.name = "tf";
	    tf.type = disabled ? flash.text.TextFieldType.DYNAMIC : flash.text.TextFieldType.INPUT;
	    tf.text = name;
	    tf.text = Opts.optString(opts, "text", tf.text);
	    tf.selectable = disabled ? false : true;
	    tf.background = false;
	    tf.border = false;
	    tf.width = box.width - 4;
	    tf.height = box.height - 3;
	    tf.x = tf.y = 4;
	    tf.embedFonts = true;
	    tf.defaultTextFormat = DefaultStyle.getTextFormat();
	    tf.setTextFormat(DefaultStyle.getTextFormat());
	    addChild(tf);
	    

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

	static function __init__() {
		haxegui.Haxegui.register(Input);
	}

}

