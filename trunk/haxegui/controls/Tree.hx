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

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.filters.DropShadowFilter;
import flash.filters.BitmapFilter;
import flash.filters.BitmapFilterQuality;
import flash.filters.BevelFilter;
import flash.geom.Rectangle;
import flash.text.TextField;
import flash.text.TextFormat;

import haxegui.Component;
import haxegui.controls.Expander;
import haxegui.managers.DragManager;
import haxegui.managers.CursorManager;
import haxegui.Opts;
import haxegui.managers.StyleManager;
import haxegui.events.ResizeEvent;
import haxegui.events.DragEvent;


/**
*
* Tree Class
*
* @version 0.1
* @author <gershon@goosemoose.com>
* @author Russell Weir'
*
*/
class Tree extends Component {
	
	override public function init(opts:Dynamic=null) {
		
		color = DefaultStyle.INPUT_BACK;
		box = new Rectangle(0,0,140,200);
		super.init(opts);

		var last = Std.int(box.height/20);
		for(i in 0...last)
		{
			var item = new Expander(this, "item"+i, 0, 20*i);
			item.init();

			for(j in 0...4) {
				var subitem = new Expander(item, "subitem"+i, 20, 20+20*j);
				subitem.init({visible: false});
				}
			if(i>0)
			{
				var self = this;
				var prev = cast this.getChildAt(i-1);
				prev.addEventListener(Event.CHANGE, function(e)
					{ 
						for(k in i...last)
						self.getChildAt(k).y -= prev.expanded ? -80 : 80; 
						
					});
			}
			
		}
		
		this.setAction("redraw",
		
		"
		this.graphics.lineStyle(1, this.color, 1);
		this.graphics.beginFill(DefaultStyle.INPUT_BACK);
		this.graphics.drawRect(0,0, this.box.width, this.box.height);
		this.graphics.endFill();
		"
		);

	}


	static function __init__() {
		haxegui.Haxegui.register(Tree);
	}


	

}

