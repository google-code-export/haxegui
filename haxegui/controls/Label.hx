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
import flash.text.TextField;
import flash.text.TextFieldType;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;

import haxegui.Opts;
import haxegui.managers.StyleManager;
import haxegui.Component;

class Label extends Component
{

	public var tf : TextField;


	public function new (?parent:DisplayObjectContainer, ?name:String, ?x:Float, ?y:Float)
	{
		if(name==null) name="label";
		super(parent, name, x, y);
	}

	override public function init(opts : Dynamic=null)
	{
		super.init(opts);
		
		tf = new TextField();
		tf.name = "tf";
		tf.text = ( text==null ) ? name : text;
		tf.type = TextFieldType.DYNAMIC;
		tf.embedFonts = true;
		tf.multiline = true;
		tf.autoSize =  TextFieldAutoSize.LEFT;
		tf.selectable = false;
		tf.mouseEnabled = false;
		tf.tabEnabled = false;
		tf.focusRect = false;

		//~ this.mouseEnabled = false;
		this.tabEnabled = false;
		this.focusRect = false;

		tf.text = Opts.optString(opts, "innerData", text);
		tf.defaultTextFormat = DefaultStyle.getTextFormat();
		tf.setTextFormat(DefaultStyle.getTextFormat());
		this.addChild(tf);

		move(Opts.optFloat(opts,"x",0), Opts.optFloat(opts,"y",0));

	}


	public function setText(s:String)
	{
		tf.text = s;
		tf.setTextFormat(DefaultStyle.getTextFormat());
	}

	static function __init__() {
		haxegui.Haxegui.register(Label,initialize);
	}
	static function initialize() {
	}

}
