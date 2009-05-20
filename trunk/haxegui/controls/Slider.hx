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

import flash.display.DisplayObjectContainer;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.FocusEvent;
import flash.filters.DropShadowFilter;
import flash.filters.BitmapFilter;
import flash.filters.BitmapFilterQuality;
import flash.filters.BevelFilter;
import flash.geom.Rectangle;
import haxegui.Component;
import haxegui.managers.CursorManager;
import haxegui.Opts;
import haxegui.managers.FocusManager;
import haxegui.managers.StyleManager;
import haxegui.events.MoveEvent;
import haxegui.events.ResizeEvent;
import haxegui.events.DragEvent;

class SliderHandle extends AbstractButton
{

	static function __init__() {
		haxegui.Haxegui.register(SliderHandle);
	}
}

class Slider extends Component
{
	public var handle : SliderHandle;
	//~ public var value : Float;
	public var max : Float;


	public function new (?parent:DisplayObjectContainer, ?name:String, ?x:Float, ?y:Float)
	{
		super(parent, name, x, y);
		max = 100;
	}

	override public function init(opts:Dynamic=null)
	{
		box = new Rectangle(0,0,140,20);
		color = DefaultStyle.BACKGROUND;

		super.init(opts);

		redraw();

		handle = new SliderHandle(this, "handle", 0, 0);
		handle.init({color: this.color});

		// add the drop-shadow filters
		var shadow:DropShadowFilter = new DropShadowFilter (4, 45, DefaultStyle.DROPSHADOW, 0.8, 4, 4, 0.65, BitmapFilterQuality.HIGH, false, false, false );
		//~ var bevel:BevelFilter = new BevelFilter( 4, 45 ,color | 0x323232 ,1 ,0x000000, .25, 2, 2, 1, BitmapFilterQuality.LOW , flash.filters.BitmapFilterType.INNER, false );

		//~ handle.filters = [shadow, bevel];
		handle.filters = [shadow];



		addEventListener (MouseEvent.MOUSE_WHEEL, onMouseWheel, false, 0, true);

		handle.addEventListener (MouseEvent.MOUSE_DOWN, onHandleMouseDown, false, 0, true);
		handle.addEventListener (MouseEvent.MOUSE_UP,   onMouseUp, false, 0, true);
		handle.addEventListener (MouseEvent.ROLL_OVER, onHandleRollOver, false, 0, true);
		handle.addEventListener (MouseEvent.ROLL_OUT,  onHandleRollOut, false, 0, true);

		handle.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp, false, 0, true);


		this.addEventListener (Event.CHANGE, onChanged, false, 0, true);

	}


	public function onChanged(?e:Event)
	{
		//~ trace(e);
		if(handle.x < 0) handle.x = 0;
		if(handle.x > (box.width - handle.width) ) handle.x = box.width - handle.width;

	}


	public function onMouseWheel(e:MouseEvent)
	{
		//trace(e);
		//~ handle.x += e.delta * 5;
		handle.x += e.delta * 5 * ((rotation > 0) ? -1 : 1);
		dispatchEvent(new Event(Event.CHANGE));
	}


	/**
	*
	*
	*/
	public function onHandleRollOver(e:MouseEvent) : Void
	{
		if(disabled) return;
		//~ redraw(DefaultStyle.BACKGROUND + 0x323232 );
//		redraw(DefaultStyle.BACKGROUND | 0x141414 );
		//~ var color = checked ? DefaultStyle.BACKGROUND - 0x202020 : DefaultStyle.BACKGROUND;
		//~ redraw(color | 0x202020 );
		redraw(color | 0x4C4C4C );

		//~ redraw(color + 0x141414 );
		CursorManager.setCursor(Cursor.HAND);

	}

	/**
	*
	*
	*/
	public function onHandleRollOut(e:MouseEvent) : Void
	{
		//~ var color = checked ? DefaultStyle.BACKGROUND - 0x202020 : DefaultStyle.BACKGROUND;
		redraw(color);
//		CursorManager.setCursor(Cursor.ARROW);
	}



	function onHandleMouseDown (e:MouseEvent) : Void
	{

		CursorManager.setCursor (Cursor.DRAG);

		redraw(color | 0x666666);


		//
		FocusManager.getInstance().setFocus (this);

		handle.startDrag(false,new Rectangle(0,e.target.y, box.width - handle.width ,0));
		//~ e.target.startDrag(false,new Rectangle(0,e.target.y, box.width - handle.width ,0));
		//~ e.target.stage.startDrag(false,new Rectangle(0,e.target.y, box.width - handle.width ,0));

		e.target.stage.addEventListener (MouseEvent.MOUSE_MOVE, onMouseMove, false, 0, true);

	}

	public function onMouseMove (e:MouseEvent)
	{
		dispatchEvent(new Event(Event.CHANGE));
		//~ onChanged();
		e.updateAfterEvent();
	}

	override public function onMouseUp (e:MouseEvent) : Void
	{
		if(hitTestObject( CursorManager.getInstance()._mc ))
			CursorManager.setCursor (Cursor.ARROW);

		handle.stopDrag();
		e.target.stage.removeEventListener (MouseEvent.MOUSE_MOVE, onMouseMove);

		redraw(color);
	}

	static function __init__() {
		haxegui.Haxegui.register(Slider);
	}

}
