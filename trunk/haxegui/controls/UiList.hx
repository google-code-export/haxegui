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
class ListItem extends AbstractButton, implements Dynamic
{
	
	public var tf : TextField;
	public var fmt : TextFormat;

	override public function init(opts:Dynamic=null)
	{

		super.init(opts);
		

		tf = new TextField();
		tf.name = "tf";
		//~ label.text = Opts.optString(opts, "label", name);
		tf.text = name;
		
		//~ label.move( Math.floor(.5*(this.box.width - label.width)), Math.floor(.5*(this.box.height - label.height)) );
		this.addChild(tf);

		// add the drop-shadow filter
		var shadow:DropShadowFilter = new DropShadowFilter (4, 45, DefaultStyle.DROPSHADOW, 0.5, 4, 4, 0.5, BitmapFilterQuality.HIGH, false, false, false );
		//~ var bevel:BevelFilter = new BevelFilter( 4, 45 ,color | 0x323232 ,1 ,0x000000, .25, 2, 2, 1, BitmapFilterQuality.LOW , flash.filters.BitmapFilterType.INNER, false );
		this.filters = [shadow];
		//~ this.filters = [shadow, bevel];

		// register with focus manager
		//~ FocusManager.getInstance().addEventListener (FocusEvent.MOUSE_FOCUS_CHANGE, onFocusChanged);

		action_redraw =
			"
			this.graphics.clear();
			var colors = [ color | 0x323232, color - 0x141414 ];
			var alphas = [ 100, 100 ];
			var ratios = [ 0, 0xFF ];
			var matrix = new flash.geom.Matrix();
			matrix.createGradientBox(this.box.width, this.box.height, Math.PI/2, 0, 0);
            this.graphics.lineStyle(2);
			this.graphics.lineGradientStyle (flash.display.GradientType.LINEAR, [ color, color - 0x202020 ], alphas, ratios, matrix);
			this.graphics.beginGradientFill( flash.display.GradientType.LINEAR, colors, alphas, ratios, matrix );
			this.graphics.drawRoundRect (0, 0, this.box.width, this.box.height, 8, 8 );
			this.graphics.endFill ();
			";

		redraw();

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

	public var header : Sprite;
	//~ public var data : Array<Dynamic>;
	public var data : Dynamic;

	public var sortReverse : Bool;

	var dragItem : Int;

	public function new (?parent:DisplayObjectContainer, ?name:String, ?x:Float, ?y:Float)
	{
		super (parent, name, x, y);
		data = [];
		header = new Sprite();
		header.name = "header";
		this.addChild(header);


	}

	override public function init(opts : Dynamic=null)
	{
		if(Std.is(parent, Component))
			color = (cast parent).color;
		box = new Rectangle(0,0, 140, 40);

		super.init(opts);


		if(opts == null) opts = {}
		if(opts.innerData!=null)
			data = opts.innerData.split(",");
		if(opts.data!=null)
			data = opts.data;

		//
		var shadow:DropShadowFilter = new DropShadowFilter (4, 45, DefaultStyle.DROPSHADOW, 0.8, 4, 4, 0.65, BitmapFilterQuality.HIGH, true, false, false );
		this.filters = [shadow];
	}

	public function onItemMouseDown(e:MouseEvent) : Void
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

	public function onItemMouseUp(e:MouseEvent) : Void
	{
		e.target.dispatchEvent (new DragEvent (DragEvent.DRAG_COMPLETE));
		e.target.x = 0;
		//~ e.target.y = dragItem * 20;
		//~ e.target.y = 20 + e.target.x % 20;
		e.target.y = dragItem * 20;
		setChildIndex(e.target, dragItem);

	}

	public function onItemRollOver(e:MouseEvent) : Void
	{

		//~ e.target.graphics.clear();
		//~ e.target.graphics.lineStyle(2, color - 0x323232);
		//~ e.target.graphics.beginFill (color | 0x202020);
		//~ e.target.graphics.drawRect (0, 0, box.width, 20);
		//~ e.target.graphics.endFill ();
//~ 
	//~ if(e.target==header) drawHeader(color | 0x202020);

		CursorManager.setCursor(Cursor.HAND);

	}

	public function onItemRollOut(e:MouseEvent) : Void
	{
		//~ if(this.contains(e.target))
		//~ {
				//~ e.target.graphics.clear();
				//~ e.target.graphics.lineStyle(2, color - 0x323232);
				//~ e.target.graphics.beginFill ( this.getChildIndex(e.target)==0 ? color | 0x323232 : color );
				//~ e.target.graphics.drawRect (0, 0, box.width, 20);
				//~ e.target.graphics.endFill ();
		//~ }
		//~ if(e.target==header) drawHeader();

		//~ CursorManager.setCursor(Cursor.ARROW);

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

	override public function redraw(opts:Dynamic=null)
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
		tf.setTextFormat (DefaultStyle.getTextFormat());
		header.addChild (tf);

		header.addEventListener (MouseEvent.ROLL_OVER, onItemRollOver, false, 0, true);
		header.addEventListener (MouseEvent.ROLL_OUT, onItemRollOut, false, 0, true);
		header.addEventListener (MouseEvent.MOUSE_DOWN, onHeaderMouseDown, false, 0, true);
		header.addEventListener (MouseEvent.MOUSE_UP, onHeaderMouseUp, false, 0, true);

		for (i in 0...data.length)
		{
			var item = new ListItem();
			item.name = "item" + (i+1);
			item.graphics.lineStyle(2, color - 0x323232);
			item.graphics.beginFill (color);
			item.graphics.drawRect (0, 0, box.width, 20);
			item.graphics.endFill ();

			item.y = 20*(i+1) ;

			item.buttonMode = true;

			item.addEventListener (MouseEvent.ROLL_OVER, onItemRollOver, false, 0, true);
			item.addEventListener (MouseEvent.ROLL_OUT, onItemRollOut, false, 0, true);
			item.addEventListener (MouseEvent.MOUSE_DOWN, onItemMouseDown, false, 0, true);
			item.addEventListener (MouseEvent.MOUSE_UP, onItemMouseUp, false, 0, true);

			item.addEventListener (DragEvent.DRAG_START, DragManager.getInstance ().onStartDrag, false, 0, true);
			item.addEventListener (DragEvent.DRAG_COMPLETE, DragManager.getInstance ().onStopDrag, false, 0, true);


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

			tf.setTextFormat (DefaultStyle.getTextFormat());

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
