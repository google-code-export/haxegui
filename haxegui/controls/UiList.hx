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

import flash.geom.Rectangle;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Sprite;

import flash.text.TextField;

import flash.events.Event;
import flash.events.MouseEvent;
import haxegui.events.DragEvent;

import flash.filters.DropShadowFilter;
import flash.filters.BitmapFilter;
import flash.filters.BitmapFilterQuality;
import flash.filters.BevelFilter;

import haxegui.StyleManager;
import haxegui.CursorManager;
import haxegui.DragManager;



/**
 *
 *
 *
 *
 */
class UiList extends Component
{

	public var header : Sprite;
	//~ public var data : Array<Dynamic>;
	public var data : Dynamic;

	public var sortReverse : Bool;

	var color : UInt;

	var dragItem : Int;

	public function new (?parent:DisplayObjectContainer, ?name:String, ?x:Float, ?y:Float)
	{
		super (parent, name, x, y);
		data = [];
		header = new Sprite();
		header.name = "header";
		this.addChild(header);


	}

	public function init(?initObj : Dynamic)
	{

		color = (cast parent).color;
		box = new Rectangle(0,0, 140, 40);
		if(Reflect.isObject(initObj))
		{


				for (f in Reflect.fields (initObj))
				  if (Reflect.hasField (this, f))
					if (f!="label" && f != "width" && f != "height")
					  Reflect.setField (this, f, Reflect.field (initObj, f));

			box.width = ( Math.isNaN(initObj.width) ) ? box.width : initObj.width;
			box.height = ( Math.isNaN(initObj.height) ) ? box.height : initObj.height;


			if(initObj.innerData!=null)
				data = initObj.innerData.split(",");

			if(initObj.data!=null)
				data = initObj.data;

		}





		//
		redraw();

		//
		var shadow:DropShadowFilter = new DropShadowFilter (4, 45, StyleManager.DROPSHADOW, 0.8, 4, 4, 0.65, BitmapFilterQuality.HIGH, true, false, false );
		this.filters = [shadow];


	}

	public function onMouseDown(e:MouseEvent) : Void
	{
	dragItem = getChildIndex(e.target);
	setChildIndex(e.target, numChildren-1);
	e.target.dispatchEvent (new DragEvent (DragEvent.DRAG_START));

		e.target.graphics.clear();
		e.target.graphics.lineStyle(2, color - 0x323232);
		e.target.graphics.beginFill (color);
		//~ e.target.graphics.beginFill ( getChildIndex(e.target)==0 ? color | 0x323232 : color );
		e.target.graphics.drawRect (0, 0, box.width, 20);
		e.target.graphics.endFill ();

	shrink();
	}

	public function onMouseUp(e:MouseEvent) : Void
	{
	e.target.dispatchEvent (new DragEvent (DragEvent.DRAG_COMPLETE));
	e.target.x = 0;
	//~ e.target.y = dragItem * 20;
	//~ e.target.y = 20 + e.target.x % 20;
	e.target.y = dragItem * 20;
	setChildIndex(e.target, dragItem);

	}

	public function onRollOver(e:MouseEvent) : Void
	{

		e.target.graphics.clear();
		e.target.graphics.lineStyle(2, color - 0x323232);
		e.target.graphics.beginFill (color | 0x202020);
		e.target.graphics.drawRect (0, 0, box.width, 20);
		e.target.graphics.endFill ();

	if(e.target==header) drawHeader(color | 0x202020);

		CursorManager.setCursor(Cursor.HAND);

	}

	public function onRollOut(e:MouseEvent) : Void
	{
if(this.contains(e.target))
{
		e.target.graphics.clear();
		e.target.graphics.lineStyle(2, color - 0x323232);
		//~ e.target.graphics.beginFill (color);
		e.target.graphics.beginFill ( this.getChildIndex(e.target)==0 ? color | 0x323232 : color );
		e.target.graphics.drawRect (0, 0, box.width, 20);
		e.target.graphics.endFill ();
}

if(e.target==header) drawHeader();

		CursorManager.setCursor(Cursor.ARROW);

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
		header.graphics.lineStyle(2, color - 0x323232);
		header.graphics.beginFill (color | 0x323232);
		header.graphics.drawRect (0, 0, box.width, 20);
		header.graphics.endFill ();

		header.graphics.beginFill (color - 0x323232);
		header.graphics.moveTo(box.width - 20, 8 +(sortReverse ? 5 : 0) );
		header.graphics.lineTo(box.width - 10, 8 +(sortReverse ? 5 : 0) );
		header.graphics.lineTo(box.width - 15, sortReverse ? 8 : 13);
		header.graphics.endFill ();
	}

	public function redraw()
	{
		drawHeader();


		var i = numChildren;
			while(i-- > 1)
				removeChildAt(i);


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
		tf.setTextFormat (StyleManager.getTextFormat());
		header.addChild (tf);

		header.addEventListener (MouseEvent.ROLL_OVER, onRollOver);
		header.addEventListener (MouseEvent.ROLL_OUT, onRollOut);
		header.addEventListener (MouseEvent.MOUSE_DOWN, onHeaderMouseDown);
		header.addEventListener (MouseEvent.MOUSE_UP, onHeaderMouseUp);

	for (i in 0...data.length)
      {
		var item = new Sprite();
		item.name = "item" + (i+1);
		item.graphics.lineStyle(2, color - 0x323232);
		item.graphics.beginFill (color);
		item.graphics.drawRect (0, 0, box.width, 20);
		item.graphics.endFill ();

		item.y = 20*(i+1) ;

		item.buttonMode = true;

		item.addEventListener (MouseEvent.ROLL_OVER, onRollOver);
		item.addEventListener (MouseEvent.ROLL_OUT, onRollOut);
		item.addEventListener (MouseEvent.MOUSE_DOWN, onMouseDown);
		item.addEventListener (MouseEvent.MOUSE_UP, onMouseUp);

		item.addEventListener (DragEvent.DRAG_START, DragManager.getInstance ().onStartDrag);
		item.addEventListener (DragEvent.DRAG_COMPLETE, DragManager.getInstance ().onStopDrag);


		var tf = new TextField ();
		tf.name = "tf";

		if(Std.is(data, Array))
			try
				{
				tf.text = data[i];
				}
			catch(e:flash.Error)
				{
				//~ tf.text = Std.string(new flash.Error());
				tf.text = Std.string(e);
				}

		tf.selectable = false;
		tf.x = 4;
		tf.width = box.width - 4;
		tf.height = 20;
		tf.embedFonts = true;

		tf.mouseEnabled = false;

		tf.setTextFormat (StyleManager.getTextFormat());

		item.addChild (tf);
		this.addChild (item);

		}
	}



	public function onHeaderMouseDown(e:MouseEvent)
	{


		sortReverse = ! sortReverse;

		//~ trace(data);
		drawHeader();


	}

	public function onHeaderMouseUp(e:MouseEvent)
	{
		data.sort(
			function(x,y)
			{
				//~ return if( x.charAt(0) == y.charAt(0) ) 0 else if( x.charAt(0) > y.charAt(0) ) 1 else -1;
				return ( x.charAt(0) == y.charAt(0) ) ? 0 : ( x.charAt(0) > y.charAt(0) ) ? 1 : -1;
			}
		);
		redraw();
	}

}
