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

package haxegui.windowClasses;

import flash.display.DisplayObjectContainer;
import flash.events.MouseEvent;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.filters.DropShadowFilter;
import flash.filters.BitmapFilterQuality;
import haxegui.events.ResizeEvent;
import haxegui.managers.CursorManager;
import haxegui.Opts;
import haxegui.managers.ScriptManager;
import haxegui.managers.StyleManager;
import haxegui.Component;
import haxegui.controls.AbstractButton;

/**
*
* StatusBar Class
*
* @version 0.1
* @author Omer Goshen <gershon@goosemoose.com>
* @author Russell Weir <damonsbane@gmail.com>
*/
class StatusBar extends Component
{
	public function new(?parent:DisplayObjectContainer, ?name:String, ?x:Float, ?y:Float) {
		super (parent, name, x, y);
	}
	
	override public function init(?opts:Dynamic) {

		this.box = (cast parent).box.clone();
		this.color = (cast parent).color;
		
		super.init(opts);

		parent.addEventListener(ResizeEvent.RESIZE, onParentResize);
		
		var shadow:DropShadowFilter = new DropShadowFilter (4, 45, DefaultStyle.DROPSHADOW, 0.5, 4, 4, 0.5,BitmapFilterQuality.HIGH,true,false,false);
		this.filters = [shadow];
		
	}	

	static function __init__() {
		haxegui.Haxegui.register(WindowFrame);
	}
	

	public function onParentResize(e:ResizeEvent)
	{
		/*
		var mazk = new flash.display.Sprite();
		mazk.graphics.beginFill(0xf0);
		mazk.graphics.drawRect(0,0,(cast parent).box.width,20);
		mazk.graphics.endFill();
		this.mask = mazk;
		*/
		untyped {
			var b = parent.box.clone();
			b.width -= 10;
			b.height = 20;
			this.scrollRect = b;
		}
		
		redraw();
	}

}
