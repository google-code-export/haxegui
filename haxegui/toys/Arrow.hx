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


import haxegui.Component;


class Arrow extends Component
{

	override public function init(?opts:Dynamic)
	{
		box = new flash.geom.Rectangle(0,0,12,12);
		color = cast Math.random() * 0xFFFFFF;
			
		super.init(opts);
					
		this.setAction("redraw",
		"
		var p = new flash.geom.Point(.5*this.box.width, .5*this.box.height);
		this.graphics.clear();
		this.graphics.lineStyle(1, Color.darken(this.color, 16));
		this.graphics.beginFill( this.color );
		this.graphics.moveTo(-p.x,-p.y);
		this.graphics.lineTo(p.x, 0);
		this.graphics.lineTo(-p.x, p.y);
		this.graphics.lineTo(-p.x,-p.y);
		this.graphics.endFill();
		"
		);

		move(.5*this.box.width, .5*this.box.height);
		

	}

	static function __init__() {
		haxegui.Haxegui.register(Arrow);
	}
	
}
