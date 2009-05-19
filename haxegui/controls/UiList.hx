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

import haxegui.DragManager;
import haxegui.CursorManager;
import haxegui.Opts;
import haxegui.StyleManager;
import haxegui.events.DragEvent;


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

	public var tf : TextField;
	public var fmt : TextFormat;

	override public function init(opts:Dynamic=null)
	{

		super.init(opts);

		tf = new TextField();
		tf.name = "tf";
		tf.text = Opts.optString(opts, "text", tf.text);
		tf.selectable = false;
		tf.x = 4;
		tf.width = box.width - 4;
		tf.height = 20;
		tf.embedFonts = true;

		tf.mouseEnabled = false;

		tf.setTextFormat (DefaultStyle.getTextFormat());

		//~ label.move( Math.floor(.5*(this.box.width - label.width)), Math.floor(.5*(this.box.height - label.height)) );
		this.addChild(tf);
	}

	static function __init__() {
		haxegui.Haxegui.register(ListItem);
	}
}




/**
 *
 *
 *
 *
 */
class UiList extends Component
{
	public var header : Component;
	public var data : Dynamic;

	public var sortReverse : Bool;
	var dragItem : Int;

	public function new (?parent:DisplayObjectContainer, ?name:String, ?x:Float, ?y:Float)
	{
		super (parent, name, x, y);
		data = [];
		header = new Component(this, "header");
	}

	override public function init(opts : Dynamic=null)
	{
		if(Std.is(parent, Component))
			color = (cast parent).color;
		box = new Rectangle(0,0, 140, 40);

		super.init(opts);


		if(opts == null) opts = {}
		if(opts.innerData!=null) {
			data = opts.innerData.split(",");
		}
		if(opts.data!=null) {
			data = opts.data;
		}

		var idx : Int = 0;
		var me = this;
		var _addItem = function(d:Dynamic) {
			idx++;
			var item = new ListItem(me, "item" + idx, 0, 20*idx );
			var str : String = (Std.is(d, String)) ? d : Std.string(d);
			item.init({text: str, width: me.box.width, color: DefaultStyle.INPUT_BACK});

			item.addEventListener(MouseEvent.CLICK, me.onItemMouseClick, false, 0, true);

			item.addEventListener(DragEvent.DRAG_START, DragManager.getInstance ().onStartDrag, false, 0, true);
			item.addEventListener(DragEvent.DRAG_COMPLETE, DragManager.getInstance ().onStopDrag, false, 0, true);
		}

		if(Std.is(data, Array)) {
			var c : Array<Dynamic> = cast data;
			for(i in c)
				_addItem(i);
		}
		else if(Std.is(data,List)) {
			var od = data;
			data = new Array<Dynamic>();
			var c : List<Dynamic> = cast od;
			for(i in c) {
				data.push(i);
				_addItem(i);
			}
		}
		else {
			_addItem(Std.string(data));
		}

		//
		var shadow:DropShadowFilter = new DropShadowFilter (4, 45, DefaultStyle.DROPSHADOW, 0.8, 4, 4, 0.65, BitmapFilterQuality.HIGH, true, false, false );
		this.filters = [shadow];
	}

	public function onItemMouseClick(e:MouseEvent) : Void
	{
		shrink();
	}

	public function onItemDragComplete(e:MouseEvent) : Void
	{
		e.target.dispatchEvent (new DragEvent (DragEvent.DRAG_COMPLETE));
		e.target.x = 0;
		//~ e.target.y = dragItem * 20;
		//~ e.target.y = 20 + e.target.x % 20;
		e.target.y = dragItem * 20;
		setChildIndex(e.target, dragItem);

	}

	public function shrink()
	{
		for(i in 1...numChildren-1)
		{
			{
				var item = getChildAt(i);
				//~ if(item.y>20) item.y -= 20;
			}
		}
	}

	public function drawHeader(?color:UInt)
	{

		if(color == 0) color = this.color;

		header.graphics.clear();
		header.graphics.lineStyle(1, color - 0x323232);
		header.graphics.beginFill (color | 0x323232);
		header.graphics.drawRect (0, 0, box.width, 20);
		header.graphics.endFill ();

		header.graphics.beginFill (color - 0x323232);
		header.graphics.moveTo(box.width - 20, 8 +(sortReverse ? 5 : 0) );
		header.graphics.lineTo(box.width - 10, 8 +(sortReverse ? 5 : 0) );
		header.graphics.lineTo(box.width - 15, sortReverse ? 8 : 13);
		header.graphics.endFill ();


	}

	override public function redraw(opts:Dynamic=null)
	{
		drawHeader();


		var tf = new TextField ();
		tf.name = "tf";
		//~ tf.text = header.name;
		tf.selectable = false;
		//~ tf.width = 40;
		tf.autoSize = flash.text.TextFieldAutoSize.LEFT;
		tf.x = Std.int(.5*(box.width - tf.width));
		tf.y = 2;
		tf.height = 18;
		tf.embedFonts = true;
		tf.mouseEnabled = false;
		//~ tf.setTextFormat (StyleManager.getTextFormat(8, StyleManager.LABEL_TEXT, flash.text.TextFormatAlign.CENTER));
		tf.setTextFormat (DefaultStyle.getTextFormat());
		header.addChild (tf);

// 		header.addEventListener (MouseEvent.ROLL_OVER, onItemRollOver, false, 0, true);
// 		header.addEventListener (MouseEvent.ROLL_OUT, onItemRollOut, false, 0, true);
		header.addEventListener (MouseEvent.CLICK, onHeaderMouseClick, false, 0, true);
// 		header.addEventListener (MouseEvent.MOUSE_UP, onHeaderMouseUp, false, 0, true);

		//~ for(i in 0...numChildren-1)
			//~ if( Std.is( this.getChildAt(i), ListItem ))
				//~ untyped this.getChildAt(i).dirty = true;
				//~ untyped this.getChildAt(i).redraw();

	}

	public function onHeaderMouseClick(e:MouseEvent)
	{
		sortReverse = !sortReverse;
		//~ trace(data);
		drawHeader();
		data.sort(
			if(!sortReverse) {
				function(x,y)
				{
					return ( x == y ) ? 0 : ( x > y ) ? 1 : -1;
				}
			} else {
				function(x,y)
				{
					return ( x == y ) ? 0 : ( x > y ) ? -1 : 1;
				}
			}
		);
		redraw();
	}

	static function __init__() {
		haxegui.Haxegui.register(UiList);
	}

}
