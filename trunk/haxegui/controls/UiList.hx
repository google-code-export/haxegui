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

import flash.geom.Rectangle;
import flash.text.TextField;
import flash.text.TextFormat;

import haxegui.Component;
import haxegui.managers.DragManager;
import haxegui.managers.CursorManager;
import haxegui.Opts;
import haxegui.managers.StyleManager;
import haxegui.events.ResizeEvent;
import haxegui.events.DragEvent;

import haxegui.toys.Arrow;

/**
*
* ListItem Class
*
* @version 0.1
* @author <gershon@goosemoose.com>
* @author Russell Weir'
*
*/
class ListHeader extends AbstractButton
{
	public var label : Label;
	public var arrow : Arrow;
		
	override public function init(opts:Dynamic=null)
	{
		super.init(opts);
		
		label = new Label(this);
		label.init();
		label.text = null;
		label.moveTo(4,4);
		
		arrow = new Arrow(this);
		arrow.init({ width: 8, height: 8, color: haxegui.utils.Color.darken(this.color, 20)});
		arrow.rotation = (cast parent).sortReverse ? -90 : 90;
		arrow.moveTo((cast parent).box.width - 10, 10);
		
		parent.addEventListener(ResizeEvent.RESIZE, onParentResize, false, 0, true);
	}


	static function __init__() {
		haxegui.Haxegui.register(ListHeader);
	}
	
	public function onParentResize(e:ResizeEvent) {
		this.box = (cast parent).box.clone();
		dirty = true;
	}
	
}




/**
*
* ListItem Class
*
* @version 0.1
* @author <gershon@goosemoose.com>
* @author Russell Weir'
*
*/
class ListItem extends AbstractButton
{

	public var label : Label;

	
	override public function init(opts:Dynamic=null)
	{
		super.init(opts);

		label = new Label(this);
		var text = Opts.optString(opts, "text", name);
		label.init({innerData: text, color: DefaultStyle.INPUT_TEXT });
		label.text = null;
		label.mouseEnabled = false;
		label.move(4,4);
		
		// add the drop-shadow filter
		//~ var shadow:DropShadowFilter = new DropShadowFilter (4, 45, DefaultStyle.DROPSHADOW, 0.5, 4, 4, 0.5, BitmapFilterQuality.HIGH, true, false, false );
		//~ this.filters = [shadow];
		parent.addEventListener(ResizeEvent.RESIZE, onParentResize, false, 0, true);

	}

	static function __init__() {
		haxegui.Haxegui.register(ListItem);
	}
	
	public function onParentResize(e:ResizeEvent) {
		this.box = (cast parent).box.clone();
		dirty = true;
	}

	
}




/**
*
* Sortable List Class
*
* @version 0.1
* @author <gershon@goosemoose.com>
* @author Russell Weir'
*
*/
class UiList extends Component
{

	public var header : ListHeader;
	public var data : Array<Dynamic>;

	public var sortReverse : Bool;
	var dragItem : Int;


	public override function init(opts : Dynamic=null)
	{
		this.color = DefaultStyle.BACKGROUND;
		sortReverse = false;
		if(Std.is(parent, Component))
			color = (cast parent).color;
		box = new Rectangle(0,0, 140, 100);
		if(data==null)
			data = [];
		
		super.init(opts);

		if(opts == null) opts = {}
		if(opts.innerData!=null)
			data = opts.innerData.split(",");
		if(opts.data!=null)
			data = opts.data;


		header = new ListHeader(this);
		header.init({color: this.color, width: this.box.width});


  		var n = 1;
		if(data!=null && data.length > 0) n = data.length+1;
		for (i in 1...n) {
			var item = new ListItem(this);
			item.init({width: this.box.width, color: DefaultStyle.INPUT_BACK});
			//item.label.text = null;
			item.label.mouseEnabled = false;
			item.move(0,20*i+1);
		}

		parent.addEventListener(ResizeEvent.RESIZE, onParentResize, false, 0, true);


	}


	public function onParentResize(e:ResizeEvent) : Void {
		dispatchEvent(new ResizeEvent(ResizeEvent.RESIZE));
	}
	
	
	public function onItemMouseUp(e:MouseEvent) : Void
	{
		e.target.dispatchEvent (new DragEvent (DragEvent.DRAG_COMPLETE));
		e.target.x = 0;
		//~ e.target.y = dragItem * 20;
		//~ e.target.y = 20 + e.target.x % 20;
		e.target.y = dragItem * 20;
		setChildIndex(e.target, dragItem);

	}



	override public function redraw(opts:Dynamic=null)
	{
		super.redraw();
		
		//~ var self = this;
		//~ data.sort(function(a,b) { if(a < b) return self.sortReverse ? 1 : -1; return 0;	});
		
		//~ header.redraw();
		
		// if all children are here just redraw them
		//~ if(numChildren <= data.length ) 
			//~ for(i in 0...numChildren) {
				//~ var item = cast this.getChildAt(i);
				//~ item.box.width = this.box.width;
				//~ item.redraw();
			//~ }
		//~ 

		// if children were'nt yet created 
		//~ else
		//~ {
			//~ var n = Std.int((this.box.height)/20);
			//~ var n = Std.int((this.box.height)/20);
			//~ for (i in numChildren...n)
			//~ {
				//~ var item = new ListItem(this);
				//~ item.init({width: this.box.width, color: DefaultStyle.INPUT_BACK});
				//~ item.move(0, 20*(i+1)+1 );
			//~ }
		//~ }
		
		
		/* Draw the frame */
		this.graphics.clear();
		this.graphics.lineStyle(1, DefaultStyle.BACKGROUND - 0x202020);
		//~ this.graphics.beginFill(this.color);
		this.graphics.beginFill(DefaultStyle.INPUT_BACK);
		this.graphics.drawRect(-1,-1,this.box.width+1, this.box.height+1 );
		this.graphics.endFill();
	}



	static function __init__() {
		haxegui.Haxegui.register(UiList);
	}



}
