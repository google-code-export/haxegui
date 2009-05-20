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
import flash.filters.DropShadowFilter;
import flash.filters.BitmapFilterQuality;
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
	/**
	*  @see Label
	*/
	public var label :Label;
	public var fmt : TextFormat;

	override public function init(opts:Dynamic=null)
	{
		super.init(opts);

		label = new Label();
		label.text = Opts.optString(opts, "label", name);
		label.init();
		this.addChild(label);
	}

	static function __init__() {
		haxegui.Haxegui.register(Button);
	}
}

