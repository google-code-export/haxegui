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


package haxegui.utils;

import flash.geom.Point;
import flash.geom.Rectangle;

/**
* R^2 Dimensional class, rounds floats to integers.
*
*
* @author <gershon@goosemoose.com>
* @author Russell Weir <damonsbane@gmail.com>
* @version 0.1
*/
class Size {
	public var width : Int;
	public var height : Int;

	public function new(?w:Float, ?h:Float) {
		this.width = Std.int(w);
		this.height = Std.int(h);
	}

	public function clone() {
		return new Size(width,height);
	}

	public function setAtLeastZero() {
		width = Std.int(Math.max(0, width));
		height = Std.int(Math.max(0, height));
		return this;
	}

	public function toString() : String {
		return "["+Std.string(width)+"x"+Std.string(height)+"]";
	}

	public static function equal(s1, s2) : Bool {
		if(s1 == null || s2 == null) {
			if(s1 == s2)
				return true;
			return false;
		}
		if(s1.width == s2.width && s1.height == s2.height)
			return true;
		return false;
	}
	
	public function empty() : Bool {
		return equal(this, new Size());
	}
	
	public function add(s:Size) : Size {
		if(s.empty()) return this;
		this.width += s.width;
		this.height += s.height;
		return this;
	}

	public function subtract(s:Size) : Size {
		this.width -= s.width;
		this.height -= s.height;
		return this;
	}

	/**
	* Bit-shift both components of input size
	* <pre class="code haxe">
	* // returns [50x50]
	* new Size(100,100).shift(1);
	* </pre>
	* @return Shifted size
	**/
	public function shift(s:Int) : Size {
		this.width >> = s;
		this.height >> = s;
		return this;
	}

	public static function fromRect(r:Rectangle) : Size {
		return new Size(r.width,r.height);
	}

	public function toRect() : Rectangle {
		return new Rectangle(0,0,width,height);
	}
}
