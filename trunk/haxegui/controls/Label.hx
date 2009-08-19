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

//{{{ Imports
import flash.display.DisplayObjectContainer;
import flash.events.Event;
import flash.events.TextEvent;
import flash.geom.Rectangle;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFieldType;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import haxegui.controls.Component;
import haxegui.events.ResizeEvent;
import haxegui.managers.StyleManager;
import haxegui.utils.Align;
import haxegui.utils.Color;
import haxegui.utils.Opts;
import haxegui.utils.Size;
//}}}


/**
*
* Label class, non-interactive text component.
*
* @author Omer Goshen <gershon@goosemoose.com>
* @author Russell Weir <damonsbane@gmail.com>
* @version 0.1
*/
class Label extends Component, implements IText {

	public var tf 						: TextField;
	public var text (getText, setText)  : String;

	public var align 					: Alignment;

	//{{{ init
	override public function init(?opts:Dynamic=null) {
		if(text==null)
		text = name;
		align = { horizontal: HorizontalAlign.LEFT, vertical: VerticalAlign.CENTER };

		super.init(opts);


		description = null;

		tf = new TextField();
		tf.name = "tf";
		tf.autoSize = TextFieldAutoSize.LEFT;
		tf.defaultTextFormat = DefaultStyle.getTextFormat();
		tf.embedFonts = true;
		tf.focusRect = false;
		tf.mouseEnabled = false;
		tf.multiline = true;
		tf.selectable = false;
		tf.tabEnabled = false;
		tf.type = TextFieldType.DYNAMIC;
		tf.wordWrap = Opts.optBool(opts, "wordWrap", false);

		if(!box.isEmpty()) {
			tf.width = box.width;
			tf.height = box.height;
		}


		this.focusRect = false;
		this.tabEnabled = false;


		tf.text = Opts.optString(opts, "text", text);
		tf.setTextFormat(DefaultStyle.getTextFormat());
		this.addChild(tf);

		if(box.isEmpty())
		resize(new Size(tf.width, tf.height));
		else {
			tf.width = box.width;
			tf.height = box.height;
		}
		move(Opts.optFloat(opts,"x",0), Opts.optFloat(opts,"y",0));

		dirty = false;
	}
	//}}}


	//{{{ onResize
	public override function onResize(e:ResizeEvent) {

		switch(align.horizontal) {
			case LEFT:
			case CENTER:
			tf.x = Std.int(box.width - tf.width) >> 1;
			case RIGHT:
			case JUSTIFY:
		}

		switch(align.vertical) {
			case TOP:
			tf.y = 0;
			case CENTER:
			tf.y = Std.int(box.height - tf.height) >> 1;
			case BOTTOM:
			tf.y = box.height - tf.height;
		}

		// tf.width = box.width;
		// tf.height = box.height;

		super.onResize(e);
	}
	//}}}


	//{{{ getText
	public function getText() : String {
		if(tf==null) return null;
		return tf.text;
	}
	//}}}


	//{{{ setText
	public function setText(s:String) : String {
		if(tf==null || s==null) return null;
		tf.text = s;
		//tf.setTextFormat(DefaultStyle.getTextFormat());
		//dispatchEvent(new Event(Event.CHANGE));
		resize(new Size(tf.width, tf.height));
		return tf.text;
	}
	//}}}


	//{{{ __init__
	static function __init__() {
		haxegui.Haxegui.register(Label);
	}
	//}}}


	//{{{ redraw
	public override function redraw(opts:Dynamic=null) {
		tf.x = Std.int(tf.x);
		tf.y = Std.int(tf.y);
		// super.redraw(opts);
	}
	//}}}
}
