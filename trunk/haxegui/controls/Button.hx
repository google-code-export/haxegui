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

import feffects.Tween;
import feffects.easing.Quint;
import feffects.easing.Sine;
import feffects.easing.Back;
import feffects.easing.Bounce;
import feffects.easing.Circ;
import feffects.easing.Cubic;
import feffects.easing.Elastic;
import feffects.easing.Expo;
import feffects.easing.Linear;
import feffects.easing.Quad;
import feffects.easing.Quart;

import flash.display.DisplayObjectContainer;
import flash.events.MouseEvent;
import flash.events.KeyboardEvent;
import flash.events.FocusEvent;
import flash.geom.Rectangle;
import flash.text.TextFormat;

import haxegui.managers.CursorManager;
import haxegui.Opts;
import haxegui.managers.StyleManager;
import haxegui.events.MoveEvent;

/**
*
* Button Class
*
* A chromed button.
*
* @version 0.1
* @author Omer Goshen <gershon@goosemoose.com>
* @author Russell Weir <damonsbane@gmail.com>
*/
class Button extends AbstractButton
{

	public var label :Label;
	//~ public var fmt : TextFormat;

	override public function init(opts:Dynamic=null)
	{
		// dont create zero sized buttons
		if(box==null || box.isEmpty()) 
			box = new Rectangle(0,0,90,30);
		
		super.init(opts);
		text = name;
		
		// Default to a no-label simple button
		if(Opts.optString(opts, "label", null)!=null) {
		//~ label = cast this.addChild(new Label());
		label = new Label(this);
		label.text = Opts.optString(opts, "label", name);
		label.init();
		}
	}

	static function __init__() {
		haxegui.Haxegui.register(Button);
	}
}

