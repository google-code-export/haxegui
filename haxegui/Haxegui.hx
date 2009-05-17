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

package haxegui;

import haxegui.StyleManager;
import haxegui.controls.Component;

/**
* Haxegui Class
*
* @version 0.1
* @author Omer Goshen <gershon@goosemoose.com>
* @author Russell Weir <damonsbane@gmail.com>
*/
class Haxegui {


	private static var initializers : List<{c:Class<Dynamic>, f:Void->Void}>;
	private static var dirtyList : List<Component> = new List();

	/** Public **/


	public static function init() {
		for(o in initializers) {
			trace("Initializing " + Type.getClassName(o.c));
			o.f();
		}

		// Setup mouse and cursor
		MouseManager.getInstance().init();
		CursorManager.getInstance().init();

		// load the default style
		trace("loading style");
		StyleManager.loadStyles(Xml.parse(haxe.Resource.getString("default_style")));
		StyleManager.setStyle("default");


		trace("complete");

		var t = new haxe.Timer(300);
		t.run = onInterval;
	}

	private static function onInterval() {
		for(c in dirtyList) {
			if(c.dirty) {
				c.redraw({});
				c.dirty = false;
			}
			dirtyList.remove(c);
		}
	}

	/**
	* Component registration. Used during the boot process to register
	* all components.
	*/
	public static function register(c:Class<Dynamic>, f:Void->Void) : Void {
		if(initializers == null)
			initializers = new List();
		initializers.add({c:c, f:f});
	}

	public static function setDirty(c : Component) : Void {
		dirtyList.add(c);
	}



}
