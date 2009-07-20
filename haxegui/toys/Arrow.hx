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

package haxegui.toys;

import flash.geom.Rectangle;

import haxegui.managers.StyleManager;

import haxegui.utils.Size;
import haxegui.utils.Color;

import haxegui.controls.Component;

enum ArrowType {
	LINE;
	SOLID;
	CIRCLE;
	DIAMOND;
}

/**
* Simple arrowhead used by many widgets
*/
class Arrow extends Component
{

	override public function init(?opts:Dynamic) {
		box = new Size(12,12).toRect();
		color = cast Math.random() * 0xFFFFFF;
			
		super.init(opts);
					
		this.setAction("redraw",
		"
		var s = Size.fromRect(this.box).shift(1);
		var p = new flash.geom.Point(s.width, s.height);
		this.graphics.clear();
		this.graphics.lineStyle(1, Color.darken(this.color, 16), 1, true,
				    flash.display.LineScaleMode.NONE,
				    flash.display.CapsStyle.ROUND,
				    flash.display.JointStyle.ROUND);

		this.graphics.beginFill( this.color );

		this.graphics.moveTo(-p.x,-p.y);
		this.graphics.lineTo(p.x, 0);
		this.graphics.lineTo(-p.x, p.y);
		this.graphics.lineTo(-p.x,-p.y);

		this.graphics.endFill();
		"
		);

		move(Std.int(box.width)>>1, Std.int(box.height)>>1);
		

	}

	static function __init__() {
		haxegui.Haxegui.register(Arrow);
	}
	
}
