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
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.events.Event;
import flash.events.TextEvent;

import haxegui.controls.Component;

import haxegui.StyleManager;


import flash.filters.DropShadowFilter;
import flash.filters.BitmapFilter;
import flash.filters.BitmapFilterQuality;

class Input extends Component
{

    public var tf : TextField;


	public function new(?parent : DisplayObjectContainer, ?name:String, ?x:Float, ?y:Float)
	{
	    super(parent, name, x, y);
	}

	override public function init(?opts:Dynamic) : Void
	{
	    box = new Rectangle(0, 0, 140, 20);
		super.init(opts);

	    //~ buttonMode = false;
	    mouseEnabled = true;
	    tabEnabled = true;

	    graphics.lineStyle (2, DefaultStyle.BACKGROUND - 0x202020);
	    graphics.beginFill (DefaultStyle.INPUT_BACK);
	    graphics.drawRoundRect(0, 0, box.width, box.height, 8, 8 );
	    graphics.endFill ();

	    var shadow:DropShadowFilter = new DropShadowFilter (4, 45, DefaultStyle.DROPSHADOW, 0.8, 4, 4, 0.65, BitmapFilterQuality.HIGH, true, false, false );
	    filters = [shadow];

	    tf = new TextField();
	    tf.name = "tf";
	    tf.type = flash.text.TextFieldType.INPUT;
	    tf.text = name;
	    tf.background = false;
	    tf.border = false;
	    tf.height = box.height - 3;
	    tf.x = tf.y = 4;
	    tf.embedFonts = true;

	    tf.setTextFormat(DefaultStyle.getTextFormat());
	    addChild(tf);

	}

}

