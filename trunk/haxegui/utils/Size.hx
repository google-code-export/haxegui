/*
 * Copyright (c) 2008, The Caffeine-hx project contributors
 * Original author : Russell Weir
 * Contributors:
 * All rights reserved.
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *   - Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *   - Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in the
 *     documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE CAFFEINE-HX PROJECT CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE CAFFEINE-HX PROJECT CONTRIBUTORS
 * BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
 * THE POSSIBILITY OF SUCH DAMAGE.
 */

package haxegui.utils;

import flash.geom.Point;
import flash.geom.Rectangle;

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

	public function shift(s:Int) : Size {
		this.width >> = s;
		this.height >> = s;
		return this;
	}


	public function toRect() : Rectangle {
		return new Rectangle(0,0,width,height);
	}
}
