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
import haxegui.Opts;
import haxegui.managers.DragManager;
import haxegui.managers.CursorManager;
import haxegui.managers.StyleManager;

import haxegui.events.DragEvent;
import haxegui.events.ListEvent;
import haxegui.events.ResizeEvent;

import haxegui.toys.Arrow;

import haxegui.DataSource;
import haxegui.IData;

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
		
	override public function init(opts:Dynamic=null) {
		if(!Std.is(parent, UiList)) throw parent+" not a UiList";

		mouseChildren = false;

		super.init(opts);
		
		label = new Label(this);
		label.init({innerData : name});
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
	public var selected : Bool;

	override public function init(opts:Dynamic=null) {
		if(!Std.is(parent, UiList)) throw parent+" not a UiList";
		
		color = DefaultStyle.INPUT_BACK;
		
		super.init(opts);

		label = new Label(this);
		var txt = Opts.optString(opts, "label", name);
		label.init({innerData: txt, color: DefaultStyle.INPUT_TEXT });
		label.text = null;
		label.move(4,4);
		label.mouseEnabled = false;
		
		text = null;
		
		// add the drop-shadow filter
		//~ var shadow:DropShadowFilter = new DropShadowFilter (4, 45, DefaultStyle.DROPSHADOW, 0.5, 4, 4, 0.5, BitmapFilterQuality.HIGH, true, false, false );
		//~ this.filters = [shadow];
		parent.addEventListener(ResizeEvent.RESIZE, onParentResize, false, 0, true);
		
		//~ setAction("mouseOver", "");
		//~ setAction("mouseOut", "");
		
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
class UiList extends Component, implements IData
{

	public var header : ListHeader;

	public var data : Dynamic;
	public var dataSource( default, __setDataSource ) : DataSource;
	
	public var sortReverse : Bool;
	var dragItem : Int;


	public override function init(opts : Dynamic=null) {
		box = new Rectangle(0,0, 140, 100);
		color = DefaultStyle.BACKGROUND;
		sortReverse = false;
		
		if(Std.is(parent, Component))
			color = (cast parent).color;
		
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
		
	
		if(Std.is(data, Array)) {
			data = cast(data, Array<Dynamic>);
			for (i in 0...data.length) {
				var item = new ListItem(this);
				item.init({ width: this.box.width,
							color: DefaultStyle.INPUT_BACK,
							label: data[i]
							});
				//item.label.mouseEnabled = false;
				item.move(0,20+20*i+1);
				}
		}
		else
		if(Std.is(data, List)) {
			var j=0;
			data = cast(data, List<Dynamic>);
			var items : Iterator<Dynamic> = data.iterator();
			for(i in items) {
				var item = new ListItem(this);
				item.init({ color: DefaultStyle.INPUT_BACK,
							label: i
							});
				//item.label.mouseEnabled = false;
				item.move(0,20+20*j+1);			
				j++;
			}
		}

		for(i in this) {
			untyped box.width = i.box.width = Math.max(box.width, i.label.tf.width);
			(cast i).dirty=true;
		}
		
		parent.addEventListener(ResizeEvent.RESIZE, onParentResize, false, 0, true);
/*
		setAction("mouseClick",
		"
		if(this.dataSource!=null) {
			trace(this.dataSource);
			if(Std.is(this.dataSource.data, List)) {
				var l = this.dataSource.data;
				l.add('Item'+l.length);
				this.dataSource.__setData(l);
				var item = new haxegui.controls.ListItem(this, 'Item'+l.length);
				item.color = DefaultStyle.INPUT_BACK;
				item.init();
				item.moveTo(0,20*l.length);
				this.box.height += 20;
				this.dirty=true;
				}
			trace(this.dataSource.data);
			}
		trace(this.data);
		"
		);
*/		
	}

	public function __setDataSource(d:DataSource) : DataSource {
		dataSource = d;
		dataSource.addEventListener(Event.CHANGE, onData, false, 0, true);
		trace(this.dataSource+" => "+this);
		#if debug
			trace(this.dataSource+": "+dataSource.data);
		#end
		if(Std.is(dataSource.data, List)) {
			var j=0;
			data = cast(dataSource.data, List<Dynamic>);
			var items : Iterator<Dynamic> = data.iterator();
			for(i in items) {
				var item = new ListItem(this);
				item.init({ color: DefaultStyle.INPUT_BACK,
							text: i
							});
				box.width = item.box.width = Math.max(box.width, item.label.tf.width);
				item.label.mouseEnabled = false;
				item.move(0,header==null ? 0 : 20+20*j+1);			
				j++;
			}
		}		
		return dataSource;
	}


	public function onData(e:Event) {
		trace(e);
		data = dataSource.data;
		dirty = true;
	}
	
	
	public function onParentResize(e:ResizeEvent) : Void {
		dispatchEvent(new ResizeEvent(ResizeEvent.RESIZE));
	}
	
	
	public function onItemMouseUp(e:MouseEvent) : Void {
		e.target.dispatchEvent (new DragEvent (DragEvent.DRAG_COMPLETE));
		e.target.x = 0;
		//~ e.target.y = dragItem * 20;
		//~ e.target.y = 20 + e.target.x % 20;
		e.target.y = dragItem * 20;
		setChildIndex(e.target, dragItem);

	}



	override public function redraw(opts:Dynamic=null) {
		super.redraw();

		/* Draw the frame */
		this.graphics.clear();
		this.graphics.lineStyle(1, haxegui.utils.Color.darken(DefaultStyle.BACKGROUND, 20), 1);
		//~ this.graphics.beginFill(this.color);
		this.graphics.beginFill(DefaultStyle.INPUT_BACK);
		if(header!=null)
			this.graphics.drawRect(-1,header.box.height-1, box.width+1, box.height-header.box.height+1 );
		else
			this.graphics.drawRect(-1,-1, box.width+1, box.height+1 );

		this.graphics.endFill();
	}


	public override function destroy() {
		parent.removeEventListener(ResizeEvent.RESIZE, onParentResize);
		super.destroy();
	}
	

	static function __init__() {
		haxegui.Haxegui.register(UiList);
	}



}
